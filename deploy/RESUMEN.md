# 🚀 Resumen - Archivos de Deploy Creados

## 📁 Archivos Generados

### 1. **install_server.sh**
Script de instalación automática para Ubuntu que instala:
- SQL Server 2019
- .NET 8.0 SDK y Runtime
- Nginx
- Firewall configurado
- Servicio systemd para la API

### 2. **quick_deploy.ps1** ⭐ USAR ESTE
Script PowerShell TODO-EN-UNO que:
- Verifica conexión al Droplet
- Sube e instala todo automáticamente
- Compila y sube la API
- Restaura la base de datos
- Configura y arranca servicios

**Uso:**
```powershell
cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\deploy
.\quick_deploy.ps1
```

### 3. **README.md**
Guía completa paso a paso con:
- Instrucciones detalladas
- Comandos para solución de problemas
- Referencias útiles

### 4. **appsettings.Production.json**
Configuración de producción con:
- Connection string para SQL Server
- CORS configurado
- Logging optimizado

### 5. **Backup de Base de Datos**
Ubicación: `G:\ProyectoFinalCSharp\ProyectoFinalDAM2\DB\ACEXAPI_backup.bak`
- Backup completo listo para restaurar
- 857 páginas procesadas

## 🎯 Pasos Rápidos

### Cuando el Droplet esté listo:

1. **Anota la IP** del Droplet (ejemplo: 164.92.123.45)

2. **Ejecuta el script automático:**
   ```powershell
   cd G:\ProyectoFinalCSharp\ProyectoFinalDAM2\deploy
   .\quick_deploy.ps1
   ```

3. **Responde las preguntas:**
   - IP del Droplet
   - Contraseña SA (la que configuraste durante la instalación)

4. **Espera 5-10 minutos**

5. **¡Listo!** Tu API estará en: `http://TU_IP/swagger`

## 🔍 Verificación

Después del deploy, verifica:

```powershell
# Test de la API
curl http://TU_IP/swagger

# O abre en navegador
start http://TU_IP/swagger
```

## 🐛 Si algo falla

Conéctate al servidor:
```powershell
ssh -i C:\Users\rathm\.ssh\digitalocean_key root@TU_IP
```

Ver logs:
```bash
# Logs de la API
sudo journalctl -u acexapi -f

# Logs de SQL Server
sudo journalctl -u mssql-server -f

# Logs de Nginx
sudo tail -f /var/log/nginx/error.log
```

## 📱 Actualizar Flutter App

Edita: `proyecto_santi\lib\config\api_config.dart`

```dart
static const String baseUrl = 'http://TU_IP_DROPLET';
```

## 💡 Consejos

1. **Guarda la contraseña SA** en un lugar seguro
2. **Anota la IP del Droplet**
3. Si quieres HTTPS, necesitarás un dominio y Let's Encrypt
4. El script `quick_deploy.ps1` se puede ejecutar múltiples veces para actualizar

## 📊 Costos

Con $200 de crédito y Droplet de $6/mes:
- **33 meses** de hosting gratis
- Más que suficiente para tu TFG/proyecto

---

¿Listo para cuando se cree el Droplet? 🚀
