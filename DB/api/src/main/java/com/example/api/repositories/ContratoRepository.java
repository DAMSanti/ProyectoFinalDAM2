package com.example.api.repositories;

import com.example.api.models.Contrato;
import org.springframework.data.repository.ListCrudRepository;

public interface ContratoRepository extends ListCrudRepository<Contrato, Integer> {
}