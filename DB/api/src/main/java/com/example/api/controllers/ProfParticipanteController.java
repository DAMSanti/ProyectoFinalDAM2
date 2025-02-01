package com.example.api.controllers;

import com.example.api.models.ProfParticipante;
import com.example.api.repositories.ProfParticipanteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/profParticipante")
public class ProfParticipanteController {

    @Autowired
    private ProfParticipanteRepository ProfParticipanteRepository;

    @GetMapping
    public List<ProfParticipante> getAllProfParticipante() {
        return ProfParticipanteRepository.findAll();
    }
    @GetMapping("/actividad/{id}")
    public List<ProfParticipante> getAllProfParticipanteByidActividad(@PathVariable Integer id) {
        return ProfParticipanteRepository.findAllByActividad_Id((id));
    }
    @GetMapping("/{id}")
    public ProfParticipante getProfParticipanteById(@PathVariable Integer id) {
        Optional<ProfParticipante> pp = ProfParticipanteRepository.findById(id);
        return pp.orElse(null);
    }

    @PostMapping
    public ProfParticipante createProfParticipante(@RequestBody ProfParticipante nuevoPP) {
        return ProfParticipanteRepository.save(nuevoPP);
    }

    @PutMapping("/{id}")
    public ProfParticipante updateProfParticipante(@PathVariable Integer id, @RequestBody ProfParticipante ppActualizado) {
        return ProfParticipanteRepository.findById(id)
                .map(pp -> {
                    pp.setActividad(ppActualizado.getActividad());
                    pp.setProfesor(ppActualizado.getProfesor());
                    return ProfParticipanteRepository.save(pp);
                })
                .orElseGet(() -> {
                    ppActualizado.setId(id);
                    return ProfParticipanteRepository.save(ppActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteProfParticipante(@PathVariable Integer id) {
        ProfParticipanteRepository.deleteById(id);
    }
}

