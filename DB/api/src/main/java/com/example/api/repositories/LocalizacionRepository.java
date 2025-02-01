package com.example.api.repositories;

import com.example.api.models.Localizacion;
import org.springframework.data.repository.ListCrudRepository;

public interface LocalizacionRepository extends ListCrudRepository<Localizacion, Integer> {
}