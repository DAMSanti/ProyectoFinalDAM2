package com.example.api.repositories;

import com.example.api.models.Curso;
import org.springframework.data.repository.ListCrudRepository;

public interface CursoRepository extends ListCrudRepository<Curso, Integer> {
}