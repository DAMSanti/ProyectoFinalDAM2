package com.example.api.controllers;


import com.example.api.models.Actividad;
import com.example.api.models.Contrato;
import com.example.api.repositories.ActividadRepository;
import com.example.api.services.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.InputStreamResource;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.*;
import java.util.List;
import java.util.Optional;


@RestController
@RequestMapping("/api/actividad")
public class ActividadController {

    @Autowired
    private ActividadRepository ActividadRepository;
    private FileService fileService = new FileService();

    @GetMapping
    public List<Actividad> getAllActividades() {
        return ActividadRepository.findAll();
    }

    @GetMapping("/{id}")
    public Actividad getActividadById(@PathVariable Integer id) {
        Optional<Actividad> actividad = ActividadRepository.findById(id);
        return actividad.orElse(null);
    }

    @PostMapping
    public Actividad createActividad(@RequestBody Actividad nuevaActividad, @RequestBody MultipartFile folleto ) {
        boolean guardado = false;
        Actividad actividad = ActividadRepository.save(nuevaActividad);

        /*if (actividad != null) {
            if (folleto == null) {
                guardado = true;
            } else {
                //guardado = fileService.saveArchivo(actividad.getId(), folleto, "folleto");
            }
        }*/
        return actividad;
    }

    @PutMapping("/{id}")
    public Actividad updateActividad(@PathVariable Integer id, @RequestBody Actividad actividadActualizada, @RequestBody MultipartFile folleto) {
        return ActividadRepository.findById(id)
                .map(actividad -> {
                    actividad.setTitulo(actividadActualizada.getTitulo());
                    actividad.setTipo(actividadActualizada.getTipo());
                    actividad.setDescripcion(actividadActualizada.getDescripcion());
                    actividad.setFini(actividadActualizada.getFini());
                    actividad.setFfin(actividadActualizada.getFfin());
                    actividad.setHini(actividadActualizada.getHini());
                    actividad.setHfin(actividadActualizada.getHfin());
                    actividad.setPrevistaIni(actividadActualizada.getPrevistaIni());
                    actividad.setTransporteReq(actividadActualizada.getTransporteReq());
                    actividad.setComentTransporte(actividadActualizada.getComentTransporte());
                    actividad.setAlojamientoReq(actividadActualizada.getAlojamientoReq());
                    actividad.setComentAlojamiento(actividadActualizada.getComentAlojamiento());
                    actividad.setComentarios(actividadActualizada.getComentarios());
                    actividad.setEstado(actividadActualizada.getEstado());
                    actividad.setComentEstado(actividadActualizada.getComentEstado());
                    actividad.setIncidencias(actividadActualizada.getIncidencias());
                    actividad.setImportePorAlumno(actividadActualizada.getImportePorAlumno());

                    if (folleto != null) {
                        boolean guardado = fileService.saveArchivo(id, folleto, "folleto");
                        if (guardado) {
                            System.out.println("Folleto guardado");
                        }
                    }
                    return ActividadRepository.save(actividad);
                })
                .orElseGet(() -> {
                    actividadActualizada.setId(id);
                    return ActividadRepository.save(actividadActualizada);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteActividad(@PathVariable Integer id) {
        ActividadRepository.deleteById(id);
    }

    @GetMapping("/authorization/{id}")
    public ResponseEntity<InputStreamResource> getExcelAuthorization(@PathVariable Integer id) {

        Optional<Actividad> actividad = ActividadRepository.findById(id);


        ClassPathResource plantillaResource = new ClassPathResource("documents/plantilla_autorizacion.xlsx");

        try (
                InputStream plantillaStream = plantillaResource.getInputStream();
                Workbook workbook = new XSSFWorkbook(plantillaStream);
                ByteArrayOutputStream bos = new ByteArrayOutputStream()
        ) {
            Sheet sheet = workbook.getSheetAt(0);

            sheet.getRow(5).getCell(4).setCellValue(actividad.get().getTitulo());
            sheet.getRow(10).getCell(9).setCellValue(actividad.get().getImportePorAlumno().toString());
            sheet.getRow(13).getCell(9).setCellValue(actividad.get().getFini().toString());
            sheet.getRow(15).getCell(9).setCellValue(actividad.get().getHini().toString());
            sheet.getRow(15).getCell(25).setCellValue(actividad.get().getHfin().toString());
            sheet.getRow(20).getCell(3).setCellValue(actividad.get().getDescripcion());
            sheet.getRow(27).getCell(3).setCellValue(actividad.get().getComentarios());

            workbook.write(bos);

            ByteArrayInputStream in = new ByteArrayInputStream(bos.toByteArray());

            HttpHeaders headers = new HttpHeaders();
            headers.setContentDisposition(
                    ContentDisposition.attachment().filename("authorization.xlsx").build()
            );
            headers.setContentType(
                    MediaType.parseMediaType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet")
            );

            return ResponseEntity.ok()
                    .headers(headers)
                    .body(new InputStreamResource(in));

        } catch (IOException e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).build();

        }
    }


    @GetMapping("/documentos")
    public ResponseEntity<Resource> getArchivoPDF(@RequestParam("id") int id, @RequestParam(value = "tipo", required = false) String tipo) {

        Resource resource = fileService.getArchivoPDF(id, tipo);

        if (resource == null) {
            return ResponseEntity.notFound().build();
        }
        String texto = "";

        texto += "attachment; filename=\"" + resource.getFilename() + "\"";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, texto)
                .body(resource);

    }
}