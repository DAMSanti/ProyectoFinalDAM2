package com.example.api.models;

import jakarta.persistence.*;

@Entity
@Table(name = "cursos")
public class Curso implements java.io.Serializable {
    @Id
    @Column(name = "id_curso", nullable = false)
    private Integer id;

    @Column(name = "cod_curso", nullable = false, length = 8)
    private String codCurso;

    @Lob
    @Column(name = "titulo", nullable = false)
    private String titulo;

    @Lob
    @Column(name = "etapa", nullable = false)
    private String etapa;

    @Column(name = "nivel", nullable = false)
    private Character nivel;

    @Column(name = "activo", nullable = false)
    private Byte activo;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCodCurso() {
        return codCurso;
    }

    public void setCodCurso(String codCurso) {
        this.codCurso = codCurso;
    }

    public String getTitulo() {
        return titulo;
    }

    public void setTitulo(String titulo) {
        this.titulo = titulo;
    }

    public String getEtapa() {
        return etapa;
    }

    public void setEtapa(String etapa) {
        this.etapa = etapa;
    }

    public Character getNivel() {
        return nivel;
    }

    public void setNivel(Character nivel) {
        this.nivel = nivel;
    }

    public Byte getActivo() {
        return activo;
    }

    public void setActivo(Byte activo) {
        this.activo = activo;
    }

}