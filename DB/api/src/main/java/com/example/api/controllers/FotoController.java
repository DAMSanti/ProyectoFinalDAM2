package com.example.api.controllers;

import com.example.api.models.Actividad;
import com.example.api.models.Foto;
import com.example.api.repositories.ActividadRepository;
import com.example.api.repositories.FotoRepository;
import com.example.api.services.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/foto")
public class FotoController {

    public final String URL_FOTOS = "/imagenes/actividad/";
    private FileService fileService=new FileService();
    @Autowired
    private FotoRepository fotoRepository;

    @Autowired
    private ActividadRepository actividadRepository;

    @GetMapping
    public List<Foto> getAllFoto() {
        return fotoRepository.findAll();
    }

    @GetMapping("/{id}")
    public Foto getFotoById(@PathVariable Integer id) {
        Optional<Foto> foto = fotoRepository.findById(id);
        return foto.orElse(null);
    }

    @PutMapping("/{id}")
    public Foto updateFoto(@PathVariable Integer id, @RequestBody Foto fotoActualizada) {
        return fotoRepository.findById(id)
                .map(foto -> {
                    foto.setUrlFoto(fotoActualizada.getUrlFoto());
                    foto.setDescripcion(fotoActualizada.getDescripcion());
                    foto.setActividad(fotoActualizada.getActividad());
                    return fotoRepository.save(foto);
                })
                .orElseGet(() -> {
                    fotoActualizada.setId(id);
                    return fotoRepository.save(fotoActualizada);
                });
    }
    @DeleteMapping("/{id}")
    public void deleteFoto(@PathVariable Integer id) {
        fotoRepository.deleteById(id);
    }
    @GetMapping("/poractividad")
    public ResponseEntity<List<org.springframework.core.io.Resource>> getFotosResources(@RequestParam("id") int id) {
        List<org.springframework.core.io.Resource> fotos= fileService.getArchivoFotosActividad(id);
        if (fotos==null){
            return ResponseEntity.notFound().build();
        }
        String texto = "";
        for (org.springframework.core.io.Resource foto : fotos) {
            texto += "attachment; filename=\"" + foto.getFilename() + "\"";
        }
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, texto)
                .body(fotos);


    }
    @PostMapping("/upload")
    public ResponseEntity uploadFiles(@RequestParam("fotos") MultipartFile[] files,
                                      @RequestParam("idActividad") int idActividad,
                                      @RequestParam("descripcion") String descripcion) {

        for (MultipartFile file : files) {
            try {
                Actividad actividad = actividadRepository.findById(idActividad).get();
                int sanitizedTitle = actividad.getId();
                //.replaceAll("\\s+", "_");

                String path = "C:\\"+ URL_FOTOS+sanitizedTitle+"\\"+file.getOriginalFilename(); // Ruta relativa de recursos
                File directory = new File(path);
                if (!directory.exists()) {
                    directory.mkdirs();
                }

                String uploadDir = path;

                // Guardar el archivo en la carpeta especificada
                File dest = new File(uploadDir);
                file.transferTo(dest);

                Foto foto = new Foto();
                foto.setUrlFoto(uploadDir);

                if(descripcion != null) {foto.setDescripcion(descripcion);}
                else {foto.setDescripcion(actividad.getTitulo());}

                foto.setActividad(actividad);
                fotoRepository.save(foto);

            } catch (IOException e) {
                return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                        .body(e.getMessage());
            }
        }
        return ResponseEntity.ok("Fotos subidas con éxito");
    }

}