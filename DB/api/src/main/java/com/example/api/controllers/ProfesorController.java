package com.example.api.controllers;

import com.example.api.models.Profesor;
import com.example.api.repositories.ProfesorRepository;
import com.example.api.services.FileService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.Resource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/profesor")
public class ProfesorController {

    @Autowired
    private ProfesorRepository ProfesorRepository;
    private FileService fileservice=new FileService();
    @GetMapping
    public List<Profesor> getAllProfesore() {
        return ProfesorRepository.findAll();
    }

    @GetMapping("/{uuid}")
    public Profesor getProfesorByUuid(@PathVariable String uuid) {
        Optional<Profesor> profesor = ProfesorRepository.findById(uuid);
        return profesor.orElse(null);
    }

    @GetMapping("/dni/{dni}")
    public Profesor getProfesorByDni(@PathVariable String dni) {
        Optional<Profesor> profesor = ProfesorRepository.findProfesoresByDni(dni);
        return profesor.orElse(null);
    }

    @PostMapping
    public Profesor createProfesor(@RequestBody Profesor nuevoProfesor) {
        if(nuevoProfesor.getUuid()==null){
            nuevoProfesor.setUuid(java.util.UUID.randomUUID().toString());
        }
        return ProfesorRepository.save(nuevoProfesor);
    }
    @GetMapping("foto")
    public ResponseEntity<Resource> getFoto(@RequestParam("correo") String correo) {
        Resource resource=fileservice.getArchivoFotoprofesor(correo);
        if(resource==null) {
            return ResponseEntity.notFound().build();
        }
        String texto = "";

        texto += "attachment; filename=\"" + resource.getFilename() + "\"";

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, texto)
                .body(resource);

    }

    @PutMapping("/{uuid}")
    public Profesor updateProfesor(@PathVariable String uuid, @RequestBody Profesor profesorActualizado) {
        return ProfesorRepository.findById(uuid)
                .map(profesor -> {
                    profesor.setDni(profesorActualizado.getDni());
                    profesor.setNombre(profesorActualizado.getNombre());
                    profesor.setApellidos(profesorActualizado.getApellidos());
                    profesor.setCorreo(profesorActualizado.getCorreo());
                    profesor.setPassword(profesorActualizado.getPassword());
                    profesor.setRol(profesorActualizado.getRol());
                    profesor.setUrlFoto(profesorActualizado.getUrlFoto());
                    profesor.setActivo(profesorActualizado.getActivo());
                    profesor.setEsJefeDep(profesorActualizado.getEsJefeDep());
                    profesor.setDepart(profesorActualizado.getDepart());
                    return ProfesorRepository.save(profesor);
                })
                .orElseGet(() -> {
                    profesorActualizado.setUuid(uuid);
                    return ProfesorRepository.save(profesorActualizado);
                });
    }

    @DeleteMapping("/{uuid}")
    public void deleteProfesor(@PathVariable String uuid) {
        ProfesorRepository.deleteById(uuid);
    }
}