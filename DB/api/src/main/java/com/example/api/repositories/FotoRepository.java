package com.example.api.repositories;

import com.example.api.models.Actividad;
import com.example.api.models.Foto;
import org.springframework.data.repository.ListCrudRepository;

import java.util.List;

public interface FotoRepository extends ListCrudRepository<Foto, Integer> {
    List<Foto> findAllByActividad(Actividad actividad);
}