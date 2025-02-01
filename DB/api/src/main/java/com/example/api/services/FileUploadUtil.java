package com.example.api.services;

import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;

public class FileUploadUtil {
    public static void guardarFichero(String directorioSubida, String nombreFichero,
                                      MultipartFile multipartFile) throws IOException {
        Path rutaSubida = Paths.get(directorioSubida);

        // Verifica si el directorio de subida existe, si no, lo crea
        if (!Files.exists(rutaSubida)) {
        try {
            Files.createDirectories(rutaSubida);
        } catch (IOException e) {
            System.out.println("Error al crear el directorio de subida " + e.getMessage());
        }        }
    // Guarda el archivo en el directorio especificado
    try (InputStream input = multipartFile.getInputStream()) {
    Path rutaDelFichero = rutaSubida.resolve(nombreFichero);
            Files.copy(input, rutaDelFichero, StandardCopyOption.REPLACE_EXISTING);
} catch (IOException e) {
        System.out.println("No se pudo guardar el fichero: " + nombreFichero + " ERROR: " + e.getMessage());
        }
        }
}
