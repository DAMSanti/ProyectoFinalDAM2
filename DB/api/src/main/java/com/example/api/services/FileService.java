package com.example.api.services;

import com.example.api.models.Actividad;
import com.example.api.models.Contrato;
import com.example.api.models.Foto;
import com.example.api.models.Profesor;
import com.example.api.repositories.ActividadRepository;
import com.example.api.repositories.ContratoRepository;
import com.example.api.repositories.FotoRepository;
import com.example.api.repositories.ProfesorRepository;
import org.apache.commons.io.FilenameUtils;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.ResponseEntity;
import org.springframework.util.StringUtils;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;


public class FileService {

    public ContratoRepository contratoRepository;
    public ActividadRepository actividadRepository;
    public ProfesorRepository profesorRepository;
    public FotoRepository fotoRepository;

    public final String URL_PRESUPUESTO = "C:/documents/presupuestos/";
    public final String URL_FACTURA = "C:/documents/facturas/";
    public final String URL_FOLLETOS = "C:/documents/folletos/";
    public final String URL_FOTOS = "C:/imagenes/actividad/";
    public final String URL_FOTOS_PROF = "C:/imagenes/profesores/";

    public boolean saveArchivo(int id, MultipartFile multipartFile, String tipo) {
        // Verificación de que el archivo no está vacío
        if (multipartFile.isEmpty()) {
            return false;
        }

        String nombreArchivo = StringUtils.cleanPath(Objects.requireNonNull(multipartFile.getOriginalFilename()));
        String uploadDirectory = "";

        File directory;
        switch (tipo.toLowerCase()) {
            case "presupuesto" -> {
                Contrato contrato = contratoRepository.findById(id).orElse(null);

                uploadDirectory = URL_PRESUPUESTO + contrato.getActividad().getId();

                directory = new File(uploadDirectory);

                if (!directory.exists()) {
                    directory.mkdirs();
                }

                String extension = FilenameUtils.getExtension(nombreArchivo).toLowerCase();

                // Validar si el archivo es una imagen o un PDF
                boolean esPDF = extension.equals("pdf");

                if (esPDF) {
                    if (contrato != null) {
                        try {
                            multipartFile.transferTo(directory);
                            contrato.setUrlPresupuesto(nombreArchivo);
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                        contratoRepository.save(contrato);
                        return true;
                    }
                }
            }

            case "factura" -> {
                Contrato contrato = contratoRepository.findById(id).orElse(null);
                uploadDirectory = URL_FACTURA+contrato.getActividad().getId();

                directory = new File(uploadDirectory);
                if (!directory.exists()) {
                    directory.mkdirs();
                }

                String extension = FilenameUtils.getExtension(nombreArchivo).toLowerCase();

                // Validar si el archivo es una imagen o un PDF
                boolean esPDF = extension.equals("pdf");

                if (esPDF) {
                    if (contrato != null) {
                        try {
                            multipartFile.transferTo(directory);
                            contrato.setUrlFactura(nombreArchivo);
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                        contratoRepository.save(contrato);
                        return true;
                    }
                }
            }
            case "folleto" -> {
                Actividad actividad = actividadRepository.findById(id).orElse(null);
                uploadDirectory = URL_FOLLETOS + actividad.getId();

                directory = new File(uploadDirectory);
                if (!directory.exists()) {
                    directory.mkdirs();
                }
                String extension = FilenameUtils.getExtension(nombreArchivo).toLowerCase();

                // Validar si el archivo es una imagen o un PDF
                boolean esPDF = extension.equals("pdf");
                if (esPDF) {
                    if (actividad != null) {
                        try {
                            multipartFile.transferTo(directory);
                            actividad.setUrlFolleto(nombreArchivo);
                        } catch (IOException e) {
                            throw new RuntimeException(e);
                        }
                        actividadRepository.save(actividad);
                        return true;
                    }
                }
            }
        }
        return false;
    }


    public ResponseEntity<String> saveFotoProfesor(MultipartFile multipartFile,
                                                   String correo) {
        // Verificación de que el archivo no está vacío
        if (multipartFile.isEmpty()) {
            return ResponseEntity.badRequest().body("No se ha seleccionado un archivo.");
        }

        String nombreArchivo = StringUtils.cleanPath(Objects.requireNonNull(multipartFile.getOriginalFilename()));
        String uploadDirectory = "";

        File directory;

        uploadDirectory = URL_FOTOS_PROF;

        directory = new File(uploadDirectory);

        if (!directory.exists()) {
            directory.mkdirs();
        }

        Profesor profesor = profesorRepository.findProfesorsByCorreo(correo).orElse(null);

        String extension = FilenameUtils.getExtension(nombreArchivo).toLowerCase();

        // Validar si el archivo es una imagen o un PDF
        boolean esImagen = extension.equals("jpg") || extension.equals("jpeg") || extension.equals("png");


        if (esImagen) {
            if (profesor != null) {
                profesor.setUrlFoto(nombreArchivo);
            }

            profesorRepository.save(profesor);

            return ResponseEntity.ok("Foto subida correctamente del profesor " + profesor.getNombre());
        }
        return ResponseEntity.badRequest().body("Error al subir el archivo");
    }


    public Resource getArchivoPDF(@RequestParam("id") int id,@RequestParam(value = "tipo", required = false) String tipo) {

        String nombreArchivo = null;
        switch (tipo.toLowerCase()) {
            case "factura" -> {
                Contrato contrato = contratoRepository.findById(id).orElse(null);

                if (contrato != null) {
                    nombreArchivo = contrato.getUrlFactura();

                } else {
                }
            }
            case "presupuesto" -> {
                Contrato contrato = contratoRepository.findById(id).orElse(null);
                if (contrato != null) {
                    nombreArchivo = contrato.getUrlPresupuesto();
                } else {
                }
            }
            case "folleto" -> {
                Actividad actividad = actividadRepository.findById(id).orElse(null);
                if (actividad != null) {
                    nombreArchivo = actividad.getUrlFolleto();
                } else {

                }
            }

        }
        if (nombreArchivo == null || nombreArchivo.isEmpty()) {
            return null;
        }


        try {
            // Ruta al archivo almacenado
            Path filePath = Paths.get(tipo.equalsIgnoreCase("folleto") ? URL_FOLLETOS+actividadRepository.findById(id).get().getId() : tipo.equalsIgnoreCase("factura") ? URL_FACTURA+contratoRepository.findById(id).get().getActividad().getId() : URL_PRESUPUESTO+contratoRepository.findById(id).get().getActividad().getId()).resolve(nombreArchivo);

            Resource resource = new UrlResource(filePath.toUri());

            // Verificar si el archivo existe y es legible
            if (!resource.exists() || !resource.isReadable()) {
                return null;
            }

            return resource;
        } catch (Exception e) {
            System.out.println("Error al bajar el archivo");;
        }

        return null;
    }

    public Resource getArchivoFotoprofesor(@RequestParam("correo") String correo) {

        String nombreArchivo = null;
        Profesor profesor = profesorRepository.findProfesorsByCorreo(correo).orElse(null);

        if (profesor != null) {
            nombreArchivo = profesor.getUrlFoto();
        }
        if (nombreArchivo == null || nombreArchivo.isEmpty()) {
            return null;
        }


        try {
            // Ruta al archivo almacenado
            Path filePath = Paths.get(URL_FOTOS_PROF+correo).resolve(nombreArchivo);
            Resource resource = new UrlResource(filePath.toUri());

            // Verificar si el archivo existe y es legible
            if (!resource.exists() || !resource.isReadable()) {
                return null;
            }
            return resource;

        } catch (Exception e) {
            return null;
        }
    }

    public List<Resource> getArchivoFotosActividad(int id) {
        List<Resource> fotos = new ArrayList<>();
        String nombreArchivo = null;
        Actividad actividad = actividadRepository.findById(id).orElse(null);
        if (actividad != null) {
            List<Foto> allfotos = fotoRepository.findAllByActividad(actividad);
            for (Foto foto : allfotos) {
                nombreArchivo = foto.getUrlFoto();
                try {
                    // Ruta al archivo almacenado
                    Path filePath = Paths.get(URL_FOTOS+actividad.getId()).resolve(nombreArchivo);
                    Resource resource = new UrlResource(filePath.toUri());

                    // Verificar si el archivo existe y es legible
                    if (!resource.exists() || !resource.isReadable()) {
                        return null;
                    }

                    fotos.add(resource);

                } catch (Exception e) {
                    System.out.println("Error al bajar el fichero");
                }

            }
        }



        return fotos;

    }


}


