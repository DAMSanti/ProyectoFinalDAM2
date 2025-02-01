package com.example.api.controllers;

import com.example.api.models.Curso;
import com.example.api.repositories.CursoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/cursos")
public class CursoController {

    @Autowired
    private CursoRepository cursosRepository;

    @GetMapping
    public List<Curso> getAllCursos() {
        return cursosRepository.findAll();
    }

    @GetMapping("/{id}")
    public Curso getCursoById(@PathVariable Integer id) {
        Optional<Curso> curso = cursosRepository.findById(id);
        return curso.orElse(null);
    }

    @PostMapping
    public Curso createCurso(@RequestBody Curso nuevoCurso) {
        return cursosRepository.save(nuevoCurso);
    }

    @PutMapping("/{id}")
    public Curso updateCurso(@PathVariable Integer id, @RequestBody Curso cursoActualizado) {
        return cursosRepository.findById(id)
                .map(curso -> {
                    curso.setCodCurso(cursoActualizado.getCodCurso());
                    curso.setTitulo(cursoActualizado.getTitulo());
                    curso.setEtapa(cursoActualizado.getEtapa());
                    curso.setNivel(cursoActualizado.getNivel());
                    curso.setActivo(cursoActualizado.getActivo());
                    return cursosRepository.save(curso);
                })
                .orElseGet(() -> {
                    cursoActualizado.setId(id);
                    return cursosRepository.save(cursoActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteCurso(@PathVariable Integer id) {
        cursosRepository.deleteById(id);
    }
}

