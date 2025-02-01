package com.example.api.repositories;

import com.example.api.models.Profesor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ProfesorRepository extends JpaRepository<Profesor, String> {
    Optional<Profesor> findProfesoresByDni(String dni);

    Optional<Profesor> findProfesorsByCorreo(String correo);
}