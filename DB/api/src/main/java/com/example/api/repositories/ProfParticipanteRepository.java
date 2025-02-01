package com.example.api.repositories;

import com.example.api.models.ProfParticipante;
import org.springframework.data.repository.ListCrudRepository;

import java.util.List;

public interface ProfParticipanteRepository extends ListCrudRepository<ProfParticipante, Integer> {
    List<ProfParticipante> findAllByActividad_Id(Integer actividadId);
}