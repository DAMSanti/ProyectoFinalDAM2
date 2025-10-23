# 🔴 ERROR DE CONEXIÓN - SOLUCIÓN RÁPIDA

## ❌ Problema

```
The connection errored: The XMLHttpRequest onError callback was called
```

**Causa:** La API está escuchando en `127.0.0.1:5000` (solo localhost) en lugar de `0.0.0.0:5000` (todas las interfaces).

**Resultado:** Flutter Web no puede conectarse porque está en el navegador, no en el servidor.

---

## ✅ SOLUCIÓN INMEDIATA

### Opción 1: Usar el Script PowerShell (MÁS FÁCIL)

1. Abre PowerShell como **Administrador**
2. Ejecuta:
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
.\start-api.ps1
```

### Opción 2: Usar el Script BAT

1. Haz doble clic en:
   ```
   C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI\start-api.bat
   ```

### Opción 3: Comando Manual

```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
dotnet run --launch-profile http
```

**⚠️ IMPORTANTE:** Usa `--launch-profile http` para que escuche en `0.0.0.0:5000`

---

## ✅ Verificar que Funciona

### 1. Verificar que la API escucha en todas las interfaces

Ejecuta en PowerShell:
```powershell
netstat -ano | findstr :5000
```

**Resultado CORRECTO:**
```
TCP    0.0.0.0:5000           0.0.0.0:0              LISTENING       12345
TCP    [::]:5000              [::]:0                 LISTENING       12345
```

**Resultado INCORRECTO (lo que tenías antes):**
```
TCP    127.0.0.1:5000         0.0.0.0:0              LISTENING       12345
TCP    [::1]:5000             [::]:0                 LISTENING       12345
```

### 2. Verificar que el mensaje de inicio es correcto

En la consola donde iniciaste la API, deberías ver:

```
Now listening on: http://0.0.0.0:5000  ← ✅ CORRECTO
```

**NO** deberías ver:
```
Now listening on: http://localhost:5000  ← ❌ INCORRECTO
```

### 3. Probar desde el navegador

Abre: http://192.168.9.190:5000/swagger

Si se carga Swagger, ¡funciona! ✅

---

## 🚀 Después de Iniciar la API Correctamente

### Terminal 1 - API (Ya iniciada)
```
Now listening on: http://0.0.0.0:5000
```

### Terminal 2 - Flutter
```powershell
cd C:\Users\santiagota\source\repos\ProyectoFinalDAM2\proyecto_santi
flutter run -d chrome
```

### Login
- **Email:** `admin@acexapi.com`
- **Password:** `admin123`

---

## 🔧 Si Aún No Funciona

### Error: "El puerto 5000 ya está en uso"

```powershell
# Ver qué proceso usa el puerto 5000
netstat -ano | findstr :5000

# Cerrar el proceso (reemplaza 12345 con el PID que viste)
taskkill /PID 12345 /F
```

### Error: "No se puede ejecutar start-api.ps1"

Si PowerShell dice que no puede ejecutar scripts:

```powershell
# Como Administrador
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

Luego vuelve a ejecutar el script.

---

## 📊 Comparación: Antes vs Ahora

| Aspecto | ❌ Antes (Error) | ✅ Ahora (Correcto) |
|---------|-----------------|-------------------|
| **Comando** | `dotnet run` | `dotnet run --launch-profile http` |
| **Escucha en** | `127.0.0.1:5000` | `0.0.0.0:5000` |
| **Accesible desde** | Solo la misma máquina | Red local completa |
| **Flutter Web** | ❌ No puede conectar | ✅ Conecta perfectamente |

---

## 🎯 Resumen en 3 Pasos

1. **Detén** cualquier API corriendo con el puerto 5000
2. **Inicia** la API con: `dotnet run --launch-profile http`
3. **Verifica** que dice `Now listening on: http://0.0.0.0:5000`

**¡Listo! Ahora Flutter debería conectarse sin problemas. 🎉**
