package com.example.api.controllers;

import com.example.api.models.ProfResponsable;
import com.example.api.repositories.ProfResponsableRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/profResponsable")
public class ProfResponsableController {

    @Autowired
    private ProfResponsableRepository ProfResponsableRepository;

    @GetMapping
    public List<ProfResponsable> getAllProfResponsable() {
        return ProfResponsableRepository.findAll();
    }

    @GetMapping("/{id}")
    public ProfResponsable getProfResponsableById(@PathVariable Integer id) {
        Optional<ProfResponsable> pr = ProfResponsableRepository.findById(id);
        return pr.orElse(null);
    }

    @PostMapping
    public ProfResponsable createProfResponsable(@RequestBody ProfResponsable nuevoPR) {
        return ProfResponsableRepository.save(nuevoPR);
    }

    @PutMapping("/{id}")
    public ProfResponsable updateProfResponsable(@PathVariable Integer id, @RequestBody ProfResponsable prActualizado) {
        return ProfResponsableRepository.findById(id)
                .map(pr -> {
                    pr.setActividad(prActualizado.getActividad());
                    pr.setProfesor(prActualizado.getProfesor());
                    return ProfResponsableRepository.save(pr);
                })
                .orElseGet(() -> {
                    prActualizado.setId(id);
                    return ProfResponsableRepository.save(prActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteProfResponsable(@PathVariable Integer id) {
        ProfResponsableRepository.deleteById(id);
    }
}

