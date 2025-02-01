package com.example.api.repositories;

import com.example.api.models.Grupo;
import org.springframework.data.repository.ListCrudRepository;

public interface GrupoRepository extends ListCrudRepository<Grupo, Integer> {
}