# Solución al Error de Caracteres Inválidos en la Ruta

## 🚨 PROBLEMA CRÍTICO

Flutter **NO puede trabajar** con rutas que contengan caracteres especiales como `#`, `!`, `$`, `^`, `&`, `*`, `=`, `|`, `,`, `;`, `<`, `>`, `?`.

Tu proyecto está en:
```
G:\ProyectoFinalC#\ProyectoFinalDAM2
          ^^^ PROBLEMA: Carácter # inválido
```

## ❌ Error que verás:

```
Error: Path G:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi contains invalid characters 
in "'#!$^&*=|,;<>?". Please rename your directory so as to not include any of these characters 
and retry.
```

## ✅ SOLUCIÓN OBLIGATORIA

Debes **RENOMBRAR o MOVER** la carpeta principal del proyecto a una ruta sin caracteres especiales.

### Opción 1: Renombrar la carpeta (MÁS FÁCIL)

1. **Cierra VS Code y todas las ventanas del proyecto**
2. **Abre el Explorador de Windows**
3. **Navega a** `G:\`
4. **Renombra la carpeta** `ProyectoFinalC#` a `ProyectoFinalCSharp` (o similar sin #)
5. **La nueva ruta será:** `G:\ProyectoFinalCSharp\ProyectoFinalDAM2`

**Comando PowerShell:**
```powershell
# CERRAR VS CODE PRIMERO!!!
Rename-Item -Path "G:\ProyectoFinalC#" -NewName "ProyectoFinalCSharp"
```

### Opción 2: Mover el proyecto a otra ubicación

```powershell
# Ejemplo: mover a C:\Proyectos
Move-Item -Path "G:\ProyectoFinalC#\ProyectoFinalDAM2" -Destination "C:\Proyectos\ProyectoFinalDAM2"
```

## 📝 PASOS DESPUÉS DEL RENOMBRADO

1. **Abrir VS Code en la nueva ubicación:**
   ```powershell
   cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2
   code .
   ```

2. **Actualizar las rutas en los scripts PowerShell:**
   
   Los siguientes archivos tienen rutas hardcodeadas que debes actualizar:
   
   - `iniciar-proyecto.ps1`
   - `iniciar-proyecto-completo.ps1`
   - `detener-proyecto.ps1`
   - `ACEXAPI\start-api-casa.ps1`
   - `ACEXAPI\start-api-trabajo.ps1`
   - `ACEXAPI\start-api.ps1`
   
   **Buscar y reemplazar en todos:**
   ```
   Buscar:  G:\ProyectoFinalC#\ProyectoFinalDAM2
   Reemplazar: G:\ProyectoFinalCSharp\ProyectoFinalDAM2
   ```

3. **Limpiar caché de Flutter:**
   ```powershell
   cd proyecto_santi
   flutter clean
   flutter pub get
   ```

4. **Verificar que funciona:**
   ```powershell
   # Probar ejecución en Windows
   cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\proyecto_santi
   flutter run -d windows
   ```

## 🔧 SCRIPT AUTOMÁTICO DE RENOMBRADO Y ACTUALIZACIÓN

Guarda esto como `renombrar-proyecto.ps1`:

```powershell
# Script para renombrar proyecto y actualizar rutas
# EJECUTAR COMO ADMINISTRADOR

Write-Host "RENOMBRANDO PROYECTO..." -ForegroundColor Cyan
Write-Host ""

$oldPath = "G:\ProyectoFinalC#"
$newPath = "G:\ProyectoFinalCSharp"
$oldPathEscaped = "G:\ProyectoFinalC#"
$newPathEscaped = "G:\ProyectoFinalCSharp"

# Verificar que VS Code está cerrado
$vsCodeProcess = Get-Process "Code" -ErrorAction SilentlyContinue
if ($vsCodeProcess) {
    Write-Host "ADVERTENCIA: VS Code está abierto. Ciérralo primero." -ForegroundColor Red
    Read-Host "Presiona Enter cuando hayas cerrado VS Code"
}

# Renombrar carpeta
if (Test-Path $oldPath) {
    Write-Host "Renombrando carpeta..." -ForegroundColor Yellow
    Rename-Item -Path $oldPath -NewName "ProyectoFinalCSharp"
    Write-Host "Carpeta renombrada exitosamente!" -ForegroundColor Green
} else {
    Write-Host "La carpeta antigua no existe o ya fue renombrada." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Actualizando archivos de script..." -ForegroundColor Yellow

# Lista de archivos a actualizar
$archivos = @(
    "$newPath\ProyectoFinalDAM2\iniciar-proyecto.ps1",
    "$newPath\ProyectoFinalDAM2\iniciar-proyecto-completo.ps1",
    "$newPath\ProyectoFinalDAM2\detener-proyecto.ps1",
    "$newPath\ProyectoFinalDAM2\ACEXAPI\start-api-casa.ps1",
    "$newPath\ProyectoFinalDAM2\ACEXAPI\start-api-trabajo.ps1",
    "$newPath\ProyectoFinalDAM2\ACEXAPI\start-api.ps1"
)

foreach ($archivo in $archivos) {
    if (Test-Path $archivo) {
        $contenido = Get-Content $archivo -Raw
        $contenido = $contenido -replace [regex]::Escape("G:\ProyectoFinalC#\ProyectoFinalDAM2"), "G:\ProyectoFinalCSharp\ProyectoFinalDAM2"
        Set-Content -Path $archivo -Value $contenido
        Write-Host "✓ Actualizado: $archivo" -ForegroundColor Green
    }
}

Write-Host ""
Write-Host "Limpiando caché de Flutter..." -ForegroundColor Yellow
Set-Location "$newPath\ProyectoFinalDAM2\proyecto_santi"
flutter clean
flutter pub get

Write-Host ""
Write-Host "PROCESO COMPLETADO!" -ForegroundColor Green
Write-Host ""
Write-Host "Nueva ruta: $newPath\ProyectoFinalDAM2" -ForegroundColor Cyan
Write-Host ""
Write-Host "Puedes abrir VS Code con:" -ForegroundColor Yellow
Write-Host "  cd $newPath\ProyectoFinalDAM2" -ForegroundColor White
Write-Host "  code ." -ForegroundColor White
Write-Host ""

Read-Host "Presiona Enter para cerrar"
```

## ⚠️ IMPORTANTE

- **Cierra VS Code ANTES de renombrar**
- **Actualiza todos los scripts con rutas hardcodeadas**
- **No uses caracteres especiales en nombres de carpetas** para proyectos Flutter
- **Recomendación:** Usa solo letras, números, guiones `-` y guiones bajos `_`

## 🎯 Nombres válidos para carpetas

✅ **CORRECTO:**
- `ProyectoFinalCSharp`
- `ProyectoFinal_CSharp`
- `ProyectoFinal-CSharp`
- `ProyectoFinalDAM2`
- `proyecto_dam_2024`

❌ **INCORRECTO:**
- `ProyectoFinalC#` ← Contiene #
- `Proyecto Final` ← Contiene espacio (evitar)
- `Proyecto@Final` ← Contiene @
- `Proyecto$Final` ← Contiene $

## 📚 Más información

- [Flutter Issue sobre caracteres especiales](https://github.com/flutter/flutter/issues/57471)
- [Windows Path Naming Conventions](https://docs.microsoft.com/en-us/windows/win32/fileio/naming-a-file)
