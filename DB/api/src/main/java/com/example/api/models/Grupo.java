package com.example.api.models;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;

@Entity
@Table(name = "grupos")
public class Grupo implements java.io.Serializable {
    @Id
    @Column(name = "id_grupo", nullable = false)
    private Integer id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "curso_id", nullable = false)
    private Curso curso;

    @Column(name = "cod_grupo", nullable = false, length = 8)
    private String codGrupo;

    @Column(name = "num_alumnos", nullable = false)
    private Integer numAlumnos;

    @Column(name = "activo", nullable = false)
    private Byte activo;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "tutor_id", nullable = false)
    private Profesor tutor;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Curso getCurso() {
        return curso;
    }

    public void setCurso(Curso curso) {
        this.curso = curso;
    }

    public String getCodGrupo() {
        return codGrupo;
    }

    public void setCodGrupo(String codGrupo) {
        this.codGrupo = codGrupo;
    }

    public Integer getNumAlumnos() {
        return numAlumnos;
    }

    public void setNumAlumnos(Integer numAlumnos) {
        this.numAlumnos = numAlumnos;
    }

    public Byte getActivo() {
        return activo;
    }

    public void setActivo(Byte activo) {
        this.activo = activo;
    }

    public Profesor getTutor() {
        return tutor;
    }

    public void setTutor(Profesor tutor) {
        this.tutor = tutor;
    }

}