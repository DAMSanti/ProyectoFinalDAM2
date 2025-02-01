package com.example.api.controllers;

import com.example.api.models.EmpTransporte;
import com.example.api.repositories.EmpTransporteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/empTransporte")
public class EmpTransporteController {

    @Autowired
    private EmpTransporteRepository empTransporteRepository;

    @GetMapping
    public List<EmpTransporte> getAllEmpTransporte() {
        return empTransporteRepository.findAll();
    }

    @GetMapping("/{id}")
    public EmpTransporte getEmpTransporteById(@PathVariable Integer id) {
        Optional<EmpTransporte> emp = empTransporteRepository.findById(id);
        return emp.orElse(null);
    }

    @PostMapping
    public EmpTransporte createEmpTransporte(@RequestBody EmpTransporte nuevaEmpTransporte) {
        return empTransporteRepository.save(nuevaEmpTransporte);
    }

    @PutMapping("/{id}")
    public EmpTransporte updateEmpTransporte(@PathVariable Integer id, @RequestBody EmpTransporte empActualizado) {
        return empTransporteRepository.findById(id)
                .map(emp -> {
                    emp.setNombre(empActualizado.getNombre());
                    emp.setCif(empActualizado.getCif());
                    emp.setDireccion(empActualizado.getDireccion());
                    emp.setCp(empActualizado.getCp());
                    emp.setLocalidad(empActualizado.getLocalidad());
                    emp.setContacto(empActualizado.getContacto());
                    return empTransporteRepository.save(emp);
                })
                .orElseGet(() -> {
                    empActualizado.setId(id);
                    return empTransporteRepository.save(empActualizado);
                });
    }

    @DeleteMapping("/{id}")
    public void deleteEmpTransporte(@PathVariable Integer id) {
        empTransporteRepository.deleteById(id);
    }
}

