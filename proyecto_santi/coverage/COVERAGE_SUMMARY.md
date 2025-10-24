# 📊 Reporte de Cobertura de Tests

## 🎯 Resumen General

Tu proyecto actualmente tiene **13 tests unitarios** que cubren las siguientes áreas:

### ✅ Archivos con Cobertura

#### 1. **`lib/models/actividad.dart`** 
- **Cobertura: 98.04%** (50/51 líneas)
- ✅ Creación desde JSON
- ✅ Conversión a JSON
- ✅ Manejo de campos nulos

#### 2. **`lib/services/api_service.dart`**
- **Cobertura: 8.62%** (15/174 líneas)
- ✅ Inicialización básica
- ⚠️ Necesita más tests para endpoints específicos

#### 3. **`lib/config.dart`**
- **Cobertura: 3.13%** (1/32 líneas)
- ⚠️ Configuración básica cubierta

### ❌ Archivos Sin Cobertura (0%)

Los siguientes archivos **no tienen tests aún**:

- `lib/models/profesor.dart` (27 líneas)
- `lib/models/departamento.dart` (11 líneas)
- `lib/models/photo.dart` (18 líneas)
- Y otros modelos...

---

## 📈 Estadísticas

| Métrica | Valor |
|---------|-------|
| **Tests Totales** | 13 |
| **Tests Pasando** | ✅ 13 (100%) |
| **Tests Fallando** | ❌ 0 (0%) |
| **Cobertura Principal** | ~5-10% |

---

## 🎓 Cómo Ver la Cobertura Visual en VS Code

### Opción 1: Con Coverage Gutters (Recomendado)

1. **Instala la extensión** (click en el botón instalar arriba)

2. **Abre un archivo de tu código** (por ejemplo, `actividad.dart`)

3. **Activa Coverage Gutters:**
   - Presiona `Ctrl + Shift + P`
   - Escribe "Coverage Gutters: Display Coverage"
   - O usa el atajo: `Ctrl + Shift + 7`

4. **Verás:**
   - 🟢 Líneas verdes = Cubiertas por tests
   - 🔴 Líneas rojas = NO cubiertas por tests
   - 🟡 Líneas amarillas = Parcialmente cubiertas

### Opción 2: Reporte HTML

Para generar un reporte HTML visual (requiere herramientas adicionales):

```powershell
# Instalar lcov (con Chocolatey en Windows)
choco install lcov

# Generar HTML
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
perl C:\ProgramData\chocolatey\lib\lcov\tools\bin\genhtml coverage\lcov.info -o coverage\html

# Abrir en navegador
start coverage\html\index.html
```

---

## 💡 Recomendaciones para Mejorar Cobertura

### Alta Prioridad 🔴

1. **Modelos de datos** (fácil, alto impacto)
   - `profesor.dart`
   - `departamento.dart`
   - `photo.dart`
   
2. **Servicios API** (medio, alto impacto)
   - Más tests para `api_service.dart`
   - Tests para diferentes endpoints

### Media Prioridad 🟡

3. **Utilidades y helpers**
   - Funciones de formateo
   - Validaciones

### Baja Prioridad 🟢

4. **UI Components** (complejo, menos crítico)
   - Tests de widgets (requieren más setup)
   - Tests de integración

---

## 📝 Comandos Útiles

```powershell
# Ejecutar tests
flutter test

# Ejecutar tests con cobertura
flutter test --coverage

# Ver cobertura en VS Code
# 1. Instala "Coverage Gutters"
# 2. Ctrl + Shift + 7
```

---

## 🎯 Objetivo de Cobertura

**Meta recomendada:** 70-80% para código crítico

- ✅ **Modelos de datos:** Objetivo 90%+
- ✅ **Servicios:** Objetivo 70%+
- ⚠️ **UI/Widgets:** Objetivo 40-50% (opcional)

---

**Última actualización:** ${new Date().toLocaleDateString('es-ES')}

**Comando ejecutado:** `flutter test --coverage`
