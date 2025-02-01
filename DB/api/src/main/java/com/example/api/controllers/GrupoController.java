package com.example.api.controllers;

import com.example.api.models.Grupo;
import com.example.api.repositories.GrupoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/grupo")
public class GrupoController {

    @Autowired
    private GrupoRepository GrupoRepository;

    @GetMapping
    public List<Grupo> getAllGrupo() {
        return GrupoRepository.findAll();
    }

    @GetMapping("/{id}")
    public Grupo getGrupoById(@PathVariable Integer id) {
        Optional<Grupo> grupo = GrupoRepository.findById(id);
        return grupo.orElse(null);
    }

    @PostMapping
    public Grupo createGrupo(@RequestBody Grupo nuevoGrupo) {
        return GrupoRepository.save(nuevoGrupo);
    }

    @PutMapping("/{id}")
    public Grupo updateGrupo(@PathVariable Integer id, @RequestBody Grupo grupoActualizado) {
        return GrupoRepository.findById(id)
                .map(grupo -> {
                    grupo.setCurso(grupoActualizado.getCurso());
                    grupo.setCodGrupo(grupoActualizado.getCodGrupo());
                    grupo.setNumAlumnos(grupoActualizado.getNumAlumnos());
                    grupo.setActivo(grupoActualizado.getActivo());
                    grupo.setTutor(grupoActualizado.getTutor());
                    return GrupoRepository.save(grupo);
                })
                .orElseGet(() -> {
                    grupoActualizado.setId(id);
                    return GrupoRepository.save(grupoActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteGrupo(@PathVariable Integer id) {
        GrupoRepository.deleteById(id);
    }
}

