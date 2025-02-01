package com.example.api.models;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "contratos")
public class Contrato implements java.io.Serializable {
    @Id
    @Column(name = "id", nullable = false)
    private Integer id;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "actividad_id", nullable = false)
    private Actividad actividad;

    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "emp_transporte_id", nullable = false)
    private EmpTransporte empTransporte;

    @Column(name = "contratada", nullable = false)
    private Byte contratada;

    @Column(name = "importe", nullable = false, precision = 6, scale = 2)
    private BigDecimal importe;

    @Lob
    @Column(name = "url_presupuesto")
    private String urlPresupuesto;

    @Lob
    @Column(name = "url_factura")
    private String urlFactura;

    public Integer getId() {
        return id;
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public Actividad getActividad() {
        return actividad;
    }

    public void setActividad(Actividad actividad) {
        this.actividad = actividad;
    }

    public EmpTransporte getEmpTransporte() {
        return empTransporte;
    }

    public void setEmpTransporte(EmpTransporte empTransporte) {
        this.empTransporte = empTransporte;
    }

    public Byte getContratada() {
        return contratada;
    }

    public void setContratada(Byte contratada) {
        this.contratada = contratada;
    }

    public BigDecimal getImporte() {
        return importe;
    }

    public void setImporte(BigDecimal importe) {
        this.importe = importe;
    }

    public String getUrlPresupuesto() {
        return urlPresupuesto;
    }

    public void setUrlPresupuesto(String urlPresupuesto) {
        this.urlPresupuesto = urlPresupuesto;
    }

    public String getUrlFactura() {
        return urlFactura;
    }

    public void setUrlFactura(String urlFactura) {
        this.urlFactura = urlFactura;
    }

}