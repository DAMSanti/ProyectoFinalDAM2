package com.example.api.controllers;

import com.example.api.models.Localizacion;
import com.example.api.repositories.LocalizacionRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/localizacion")
public class LocalizacionController {

    @Autowired
    private LocalizacionRepository localizacionRepository;

    @GetMapping
    public List<Localizacion> getAllLocalizaciones() {
        return localizacionRepository.findAll();
    }

    @GetMapping("/{id}")
    public Localizacion getLocalizacionById(@PathVariable Integer id) {
        Optional<Localizacion> gp = localizacionRepository.findById(id);
        return gp.orElse(null);
    }

    @PostMapping
    public Localizacion createLocalizacion(@RequestBody Localizacion nuevaLocalizacion) {
        return localizacionRepository.save(nuevaLocalizacion);
    }

    @PutMapping("/{id}")
    public Localizacion updateLocalizacion(@PathVariable Integer id, @RequestBody Localizacion localizacion) {
        return localizacionRepository.findById(id)
                .map(loc -> {
                    loc.setComentario(localizacion.getComentario());
                    loc.setLatitud(localizacion.getLatitud());
                    loc.setLongitud(localizacion.getLongitud());
                    loc.setIdActividad(localizacion.getIdActividad());
                    return localizacionRepository.save(loc);
                })
                .orElseGet(() -> {
                    localizacion.setId(id);
                    return localizacionRepository.save(localizacion);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteGruposParticipante(@PathVariable Integer id) {
        localizacionRepository.deleteById(id);
    }
}