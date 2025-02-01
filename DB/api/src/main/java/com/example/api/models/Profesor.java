package com.example.api.models;

import jakarta.persistence.*;
import org.hibernate.annotations.ColumnDefault;

@Entity
@Table(name = "profesores")
public class Profesor implements java.io.Serializable {
    @Id
    @Column(name = "uuid", nullable = false, length = 36)
    private String uuid;

    @Column(name = "dni", nullable = false, length = 9)
    private String dni;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "apellidos", nullable = false, length = 45)
    private String apellidos;

    @Lob
    @Column(name = "correo", nullable = false)
    private String correo;

    @Column(name = "password", nullable = false, length = 32)
    private String password;

    @ColumnDefault("'PROF'")
    @Lob
    @Column(name = "rol", nullable = false)
    private String rol;

    @ColumnDefault("1")
    @Column(name = "activo", nullable = false)
    private Byte activo;

    @Lob
    @Column(name = "url_foto")
    private String urlFoto;

    @ColumnDefault("0")
    @Column(name = "es_jefe_dep")
    private Byte esJefeDep;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "depart_id", nullable = false)
    private Departamento depart;

    public String getUuid() {
        return uuid;
    }

    public void setUuid(String uuid) {
        this.uuid = uuid;
    }

    public String getDni() {
        return dni;
    }

    public void setDni(String dni) {
        this.dni = dni;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String nombre) {
        this.nombre = nombre;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String apellidos) {
        this.apellidos = apellidos;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String correo) {
        this.correo = correo;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getRol() {
        return rol;
    }

    public void setRol(String rol) {
        this.rol = rol;
    }

    public Byte getActivo() {
        return activo;
    }

    public void setActivo(Byte activo) {
        this.activo = activo;
    }

    public String getUrlFoto() {
        return urlFoto;
    }

    public void setUrlFoto(String urlFoto) {
        this.urlFoto = urlFoto;
    }

    public Byte getEsJefeDep() {
        return esJefeDep;
    }

    public void setEsJefeDep(Byte esJefeDep) {
        this.esJefeDep = esJefeDep;
    }

    public Departamento getDepart() {
        return depart;
    }

    public void setDepart(Departamento depart) {
        this.depart = depart;
    }

}