# 🚨 RESUMEN DE PROBLEMAS Y SOLUCIONES

## ❌ PROBLEMA 1: Carácter `#` en la ruta (CRÍTICO)

### Error:
```
Error: Path G:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi contains invalid characters 
in "'#!$^&*=|,;<>?". Please rename your directory...
```

### ✅ SOLUCIÓN OBLIGATORIA:

**Debes renombrar la carpeta principal del proyecto.**

#### Pasos:

1. **CERRAR VS Code completamente**

2. **Renombrar la carpeta en PowerShell:**
   ```powershell
   Rename-Item -Path "G:\ProyectoFinalC#" -NewName "ProyectoFinalCSharp"
   ```

3. **Actualizar rutas en los scripts** (buscar y reemplazar):
   - De: `G:\ProyectoFinalC#\ProyectoFinalDAM2`
   - A: `G:\ProyectoFinalCSharp\ProyectoFinalDAM2`
   
   Archivos a actualizar:
   - `iniciar-proyecto.ps1`
   - `iniciar-proyecto-completo.ps1`
   - `detener-proyecto.ps1`
   - `poblar-base-datos.ps1`
   - `ACEXAPI\start-api-casa.ps1`
   - `ACEXAPI\start-api-trabajo.ps1`
   - `ACEXAPI\start-api.ps1`

4. **Limpiar caché de Flutter:**
   ```powershell
   cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\proyecto_santi
   flutter clean
   flutter pub get
   ```

5. **Abrir VS Code en la nueva ubicación:**
   ```powershell
   cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2
   code .
   ```

**📖 Documentación completa:** `SOLUCION_CARACTERES_INVALIDOS.md`

---

## ❌ PROBLEMA 2: Se abren 4 pestañas en Chrome

### Causa:
El archivo `web_entrypoint.dart` estaba causando conflictos con el punto de entrada normal.

### ✅ SOLUCIÓN APLICADA:

**Ya eliminé el archivo `web_entrypoint.dart`** que estaba en la raíz del proyecto `proyecto_santi`.

Ahora deberías poder ejecutar:
```powershell
cd proyecto_santi
flutter clean
flutter pub get
flutter run -d chrome
```

Y solo debería abrirse **una** pestaña.

---

## ❌ PROBLEMA 3: Base de datos vacía sin datos de ejemplo

### ✅ SOLUCIÓN: Script de población creado

He creado un script SQL completo que inserta datos de ejemplo.

### Ejecución:

**Opción 1 - PowerShell (Recomendado):**
```powershell
# Desde la raíz del proyecto
.\poblar-base-datos.ps1
```

**Opción 2 - SQL Command:**
```powershell
sqlcmd -S localhost\SQLEXPRESS -U sa -P Semicrol_10 -i "DB\PoblarBaseDatos.sql"
```

### Datos que se insertarán:

✅ **10 Actividades:**
- 5 futuras aprobadas (aparecerán en el Home)
- 3 pasadas realizadas
- 2 pendientes de aprobación

✅ **Datos relacionados:**
- 6 Departamentos
- 8 Cursos
- 8 Grupos
- 6 Profesores
- 5 Localizaciones
- 3 Empresas de Transporte
- Grupos participantes
- Profesores responsables/participantes
- Contratos de transporte

**📖 Documentación:** `DB\README_POBLAR.md`

---

## 📋 CHECKLIST DE PASOS A SEGUIR

### 1️⃣ Primero - Renombrar proyecto (OBLIGATORIO)
- [ ] Cerrar VS Code
- [ ] Renombrar carpeta `ProyectoFinalC#` → `ProyectoFinalCSharp`
- [ ] Actualizar rutas en los scripts `.ps1`
- [ ] Ejecutar `flutter clean` y `flutter pub get`
- [ ] Abrir VS Code en la nueva ubicación

### 2️⃣ Segundo - Poblar base de datos
- [ ] Verificar que SQL Server está ejecutándose
- [ ] Ejecutar `.\poblar-base-datos.ps1`
- [ ] Verificar que se insertaron los datos

### 3️⃣ Tercero - Probar la aplicación
- [ ] Iniciar API: `cd ACEXAPI; dotnet run`
- [ ] Iniciar Flutter: `cd proyecto_santi; flutter run -d windows`
- [ ] Verificar que se ven las actividades en el Home
- [ ] Probar navegación y funcionalidades

---

## 🎯 ORDEN RECOMENDADO DE EJECUCIÓN

```powershell
# 1. Renombrar (HACER MANUALMENTE O CON EL SCRIPT)
Rename-Item -Path "G:\ProyectoFinalC#" -NewName "ProyectoFinalCSharp"

# 2. Actualizar rutas en scripts (BUSCAR Y REEMPLAZAR EN VS CODE)
# Buscar: G:\ProyectoFinalC#\ProyectoFinalDAM2
# Reemplazar: G:\ProyectoFinalCSharp\ProyectoFinalDAM2

# 3. Navegar al proyecto
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2

# 4. Limpiar Flutter
cd proyecto_santi
flutter clean
flutter pub get
cd ..

# 5. Poblar base de datos
.\poblar-base-datos.ps1

# 6. Iniciar proyecto
.\iniciar-proyecto.ps1
```

---

## 📁 ARCHIVOS CREADOS/MODIFICADOS

### Nuevos archivos:
1. ✅ `DB\PoblarBaseDatos.sql` - Script SQL completo de población
2. ✅ `poblar-base-datos.ps1` - Script PowerShell para ejecutar población
3. ✅ `DB\README_POBLAR.md` - Documentación sobre población de BD
4. ✅ `SOLUCION_CARACTERES_INVALIDOS.md` - Guía detallada del problema del #
5. ✅ `RESUMEN_SOLUCIONES.md` - Este archivo

### Archivos eliminados:
1. ✅ `proyecto_santi\web_entrypoint.dart` - Causaba problema de múltiples pestañas

---

## ⚠️ ADVERTENCIAS IMPORTANTES

1. **NO puedes usar Flutter** hasta que renames la carpeta (problema del `#`)
2. **Cierra VS Code** antes de renombrar carpetas
3. **Actualiza TODAS las rutas** en los scripts PowerShell
4. El script de población **NO duplica datos** (puedes re-ejecutarlo)
5. Si quieres limpiar y empezar de cero, descomenta las líneas DELETE en el SQL

---

## 🆘 AYUDA ADICIONAL

- **Problema con rutas:** Ver `SOLUCION_CARACTERES_INVALIDOS.md`
- **Problema con base de datos:** Ver `DB\README_POBLAR.md`
- **Instalación SQL Server:** Ver `INSTALACION_SQLSERVER.md`
- **Guía general:** Ver `GUIA_INSTALACION.md`

---

## 📞 CONTACTO

Si después de seguir estos pasos sigues teniendo problemas:
1. Revisa los logs de error completos
2. Verifica que SQL Server está ejecutándose
3. Asegúrate de haber renombrado la carpeta correctamente
4. Comprueba que Flutter reconoce los dispositivos: `flutter devices`
