package com.example.api.repositories;

import com.example.api.models.Actividad;
import org.springframework.data.repository.ListCrudRepository;

public interface ActividadRepository extends ListCrudRepository<Actividad, Integer> {
  }