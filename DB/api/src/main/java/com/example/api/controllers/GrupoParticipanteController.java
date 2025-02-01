package com.example.api.controllers;

import com.example.api.models.GrupoParticipante;
import com.example.api.repositories.GrupoParticipanteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/grupoParticipante")
public class GrupoParticipanteController {

    @Autowired
    private GrupoParticipanteRepository GrupoParticipanteRepository;

    @GetMapping
    public List<GrupoParticipante> getAllGruposParticipante() {
        return GrupoParticipanteRepository.findAll();
    }

    @GetMapping("/{id}")
    public GrupoParticipante getGruposParticipanteById(@PathVariable Integer id) {
        Optional<GrupoParticipante> gp = GrupoParticipanteRepository.findById(id);
        return gp.orElse(null);
    }

    @PostMapping
    public GrupoParticipante createGruposParticipante(@RequestBody GrupoParticipante nuevoGP) {
        return GrupoParticipanteRepository.save(nuevoGP);
    }

    @PutMapping("/{id}")
    public GrupoParticipante updateGruposParticipante(@PathVariable Integer id, @RequestBody GrupoParticipante gpActualizado) {
        return GrupoParticipanteRepository.findById(id)
                .map(gp -> {
                    gp.setActividades(gpActualizado.getActividades());
                    gp.setGrupo(gpActualizado.getGrupo());
                    gp.setNumParticipantes(gpActualizado.getNumParticipantes());
                    gp.setComentario(gpActualizado.getComentario());
                    return GrupoParticipanteRepository.save(gp);
                })
                .orElseGet(() -> {
                    gpActualizado.setId(id);
                    return GrupoParticipanteRepository.save(gpActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteGruposParticipante(@PathVariable Integer id) {
        GrupoParticipanteRepository.deleteById(id);
    }
}

