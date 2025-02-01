package com.example.api.models;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name = "departamentos")
public class Departamento implements java.io.Serializable  {
    @Id
    @Column(name = "id_depar", nullable = false)
    private Integer id;

    @Column(name = "codigo", nullable = false, length = 3)
    private String codigo;

    @Column(name = "nombre", nullable = false, length = 100)
    private String nombre;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getCodigo() {
        return codigo;
    }

    public void setCodigo(String codigo) {
        this.codigo = codigo;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

}