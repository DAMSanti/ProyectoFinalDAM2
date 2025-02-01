package com.example.api.repositories;

import com.example.api.models.Departamento;
import org.springframework.data.repository.ListCrudRepository;

public interface DepartamentoRepository extends ListCrudRepository<Departamento, Integer> {
}