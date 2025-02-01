package com.example.api.models;

import jakarta.persistence.*;

@Entity
@Table(name = "emp_transporte")
public class EmpTransporte implements java.io.Serializable {
    @Id
    @Column(name = "id", nullable = false)
    private Integer id;

    @Column(name = "nombre", nullable = false, length = 60)
    private String nombre;

    @Column(name = "cif", nullable = false, length = 9)
    private String cif;

    @Lob
    @Column(name = "direccion")
    private String direccion;

    @Column(name = "cp", length = 5)
    private String cp;

    @Column(name = "localidad", length = 45)
    private String localidad;

    @Lob
    @Column(name = "contacto")
    private String contacto;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getCif() {
        return cif;
    }

    public void setCif(String cif) {
        this.cif = cif;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String direccion) {
        this.direccion = direccion;
    }

    public String getCp() {
        return cp;
    }

    public void setCp(String cp) {
        this.cp = cp;
    }

    public String getLocalidad() {
        return localidad;
    }

    public void setLocalidad(String localidad) {
        this.localidad = localidad;
    }

    public String getContacto() {
        return contacto;
    }

    public void setContacto(String contacto) {
        this.contacto = contacto;
    }

}