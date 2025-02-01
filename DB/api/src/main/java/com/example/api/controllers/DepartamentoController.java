package com.example.api.controllers;

import com.example.api.models.Departamento;
import com.example.api.repositories.DepartamentoRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/departamento")
public class DepartamentoController {

    @Autowired
    private DepartamentoRepository DepartamentoRepository;

    @GetMapping
    public List<Departamento> getAllDepartamento() {
        return DepartamentoRepository.findAll();
    }

    @GetMapping("/{id}")
    public Departamento getDepartamentoById(@PathVariable Integer id) {
        Optional<Departamento> departamento = DepartamentoRepository.findById(id);
        return departamento.orElse(null);
    }

    @PostMapping
    public Departamento createDepartamento(@RequestBody Departamento nuevoDepartamento) {
        return DepartamentoRepository.save(nuevoDepartamento);
    }

    @PutMapping("/{id}")
    public Departamento updateDepartamento(@PathVariable Integer id, @RequestBody Departamento departamentoActualizado) {
        return DepartamentoRepository.findById(id)
                .map(departamento -> {
                    departamento.setCodigo(departamentoActualizado.getCodigo());
                    departamento.setNombre(departamentoActualizado.getNombre());
                    return DepartamentoRepository.save(departamento);
                })
                .orElseGet(() -> {
                    departamentoActualizado.setId(id);
                    return DepartamentoRepository.save(departamentoActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteDepartamento(@PathVariable Integer id) {
        DepartamentoRepository.deleteById(id);
    }
}

