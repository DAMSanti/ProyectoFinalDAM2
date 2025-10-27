using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using SixLabors.ImageSharp.Formats.Jpeg;

namespace ACEXAPI.Services;

public interface IFileStorageService
{
    Task<(string url, string? thumbnailUrl, long size)> UploadImageAsync(IFormFile file, string containerName);
    Task<string> UploadFileAsync(IFormFile file, string containerName);
    Task<bool> DeleteFileAsync(string fileUrl);
    Task<Stream?> DownloadFileAsync(string fileUrl);
}

public class AzureBlobStorageService : IFileStorageService
{
    private readonly BlobServiceClient _blobServiceClient;
    private readonly ILogger<AzureBlobStorageService> _logger;

    public AzureBlobStorageService(BlobServiceClient blobServiceClient, ILogger<AzureBlobStorageService> logger)
    {
        _blobServiceClient = blobServiceClient;
        _logger = logger;
    }

    public async Task<(string url, string? thumbnailUrl, long size)> UploadImageAsync(IFormFile file, string containerName)
    {
        var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
        await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var blobClient = containerClient.GetBlobClient(fileName);

        // Optimizar imagen principal
        using var memoryStream = new MemoryStream();
        using (var image = await Image.LoadAsync(file.OpenReadStream()))
        {
            // Redimensionar si es muy grande
            if (image.Width > 1920 || image.Height > 1080)
            {
                image.Mutate(x => x.Resize(new ResizeOptions
                {
                    Mode = ResizeMode.Max,
                    Size = new Size(1920, 1080)
                }));
            }

            await image.SaveAsync(memoryStream, new JpegEncoder { Quality = 85 });
        }

        memoryStream.Position = 0;
        await blobClient.UploadAsync(memoryStream, new BlobHttpHeaders { ContentType = "image/jpeg" });

        // Crear thumbnail
        var thumbnailFileName = $"thumb_{fileName}";
        var thumbnailBlobClient = containerClient.GetBlobClient(thumbnailFileName);

        using var thumbnailStream = new MemoryStream();
        file.OpenReadStream().Position = 0;
        using (var thumbnailImage = await Image.LoadAsync(file.OpenReadStream()))
        {
            thumbnailImage.Mutate(x => x.Resize(new ResizeOptions
            {
                Mode = ResizeMode.Max,
                Size = new Size(300, 300)
            }));

            await thumbnailImage.SaveAsync(thumbnailStream, new JpegEncoder { Quality = 75 });
        }

        thumbnailStream.Position = 0;
        await thumbnailBlobClient.UploadAsync(thumbnailStream, new BlobHttpHeaders { ContentType = "image/jpeg" });

        return (blobClient.Uri.ToString(), thumbnailBlobClient.Uri.ToString(), memoryStream.Length);
    }

    public async Task<string> UploadFileAsync(IFormFile file, string containerName)
    {
        var containerClient = _blobServiceClient.GetBlobContainerClient(containerName);
        await containerClient.CreateIfNotExistsAsync(PublicAccessType.Blob);

        // Conservar el nombre original con timestamp para evitar colisiones
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var originalFileName = Path.GetFileNameWithoutExtension(file.FileName);
        var extension = Path.GetExtension(file.FileName);
        var fileName = $"{timestamp}_{originalFileName}{extension}";
        var blobClient = containerClient.GetBlobClient(fileName);

        using var stream = file.OpenReadStream();
        await blobClient.UploadAsync(stream, new BlobHttpHeaders { ContentType = file.ContentType });

        return blobClient.Uri.ToString();
    }

    public async Task<bool> DeleteFileAsync(string fileUrl)
    {
        try
        {
            var uri = new Uri(fileUrl);
            var blobClient = new BlobClient(uri);
            await blobClient.DeleteIfExistsAsync();
            return true;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar archivo {FileUrl}", fileUrl);
            return false;
        }
    }

    public async Task<Stream?> DownloadFileAsync(string fileUrl)
    {
        try
        {
            var uri = new Uri(fileUrl);
            var blobClient = new BlobClient(uri);
            var response = await blobClient.DownloadAsync();
            return response.Value.Content;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al descargar archivo {FileUrl}", fileUrl);
            return null;
        }
    }
}

// Implementaci�n local para desarrollo
public class LocalFileStorageService : IFileStorageService
{
    private readonly IWebHostEnvironment _environment;
    private readonly ILogger<LocalFileStorageService> _logger;
    private const string UploadsFolder = "uploads";

    public LocalFileStorageService(IWebHostEnvironment environment, ILogger<LocalFileStorageService> logger)
    {
        _environment = environment;
        _logger = logger;

        // Crear carpeta de uploads si no existe
        var uploadsPath = Path.Combine(_environment.WebRootPath, UploadsFolder);
        if (!Directory.Exists(uploadsPath))
        {
            Directory.CreateDirectory(uploadsPath);
        }
    }

    public async Task<(string url, string? thumbnailUrl, long size)> UploadImageAsync(IFormFile file, string containerName)
    {
        var containerPath = Path.Combine(_environment.WebRootPath, UploadsFolder, containerName);
        if (!Directory.Exists(containerPath))
        {
            Directory.CreateDirectory(containerPath);
        }

        var fileName = $"{Guid.NewGuid()}{Path.GetExtension(file.FileName)}";
        var filePath = Path.Combine(containerPath, fileName);

        // Optimizar imagen principal
        using (var image = await Image.LoadAsync(file.OpenReadStream()))
        {
            if (image.Width > 1920 || image.Height > 1080)
            {
                image.Mutate(x => x.Resize(new ResizeOptions
                {
                    Mode = ResizeMode.Max,
                    Size = new Size(1920, 1080)
                }));
            }

            await image.SaveAsync(filePath, new JpegEncoder { Quality = 85 });
        }

        // Crear thumbnail
        var thumbnailFileName = $"thumb_{fileName}";
        var thumbnailPath = Path.Combine(containerPath, thumbnailFileName);

        file.OpenReadStream().Position = 0;
        using (var thumbnailImage = await Image.LoadAsync(file.OpenReadStream()))
        {
            thumbnailImage.Mutate(x => x.Resize(new ResizeOptions
            {
                Mode = ResizeMode.Max,
                Size = new Size(300, 300)
            }));

            await thumbnailImage.SaveAsync(thumbnailPath, new JpegEncoder { Quality = 75 });
        }

        var fileInfo = new FileInfo(filePath);
        var url = $"/{UploadsFolder}/{containerName}/{fileName}";
        var thumbnailUrl = $"/{UploadsFolder}/{containerName}/{thumbnailFileName}";

        return (url, thumbnailUrl, fileInfo.Length);
    }

    public async Task<string> UploadFileAsync(IFormFile file, string containerName)
    {
        var containerPath = Path.Combine(_environment.WebRootPath, UploadsFolder, containerName);
        if (!Directory.Exists(containerPath))
        {
            Directory.CreateDirectory(containerPath);
        }

        // Conservar el nombre original con timestamp para evitar colisiones
        var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
        var originalFileName = Path.GetFileNameWithoutExtension(file.FileName);
        var extension = Path.GetExtension(file.FileName);
        var fileName = $"{timestamp}_{originalFileName}{extension}";
        var filePath = Path.Combine(containerPath, fileName);

        using var stream = new FileStream(filePath, FileMode.Create);
        await file.CopyToAsync(stream);

        return $"/{UploadsFolder}/{containerName}/{fileName}";
    }

    public Task<bool> DeleteFileAsync(string fileUrl)
    {
        try
        {
            var filePath = Path.Combine(_environment.WebRootPath, fileUrl.TrimStart('/'));
            if (File.Exists(filePath))
            {
                File.Delete(filePath);
                return Task.FromResult(true);
            }
            return Task.FromResult(false);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al eliminar archivo {FileUrl}", fileUrl);
            return Task.FromResult(false);
        }
    }

    public Task<Stream?> DownloadFileAsync(string fileUrl)
    {
        try
        {
            var filePath = Path.Combine(_environment.WebRootPath, fileUrl.TrimStart('/'));
            if (File.Exists(filePath))
            {
                return Task.FromResult<Stream?>(new FileStream(filePath, FileMode.Open, FileAccess.Read));
            }
            return Task.FromResult<Stream?>(null);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error al descargar archivo {FileUrl}", fileUrl);
            return Task.FromResult<Stream?>(null);
        }
    }
}
