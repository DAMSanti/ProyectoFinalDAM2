# Despliegue de proyecto_santi en Digital Ocean

## Requisitos previos
- Un Droplet de Digital Ocean con Ubuntu 22.04 o superior
- Docker instalado
- Acceso SSH al servidor

## Instalación rápida de Docker (si no está instalado)

```bash
# Conectarse al servidor
ssh root@TU_IP_DIGITAL_OCEAN

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
```

## Método 1: Despliegue manual con SCP

### 1. Subir archivos al servidor

```bash
# Desde tu máquina local (en la carpeta dist/proyecto_santi/web)
scp -r * root@TU_IP_DIGITAL_OCEAN:/root/proyecto_santi_web/
```

### 2. Conectar al servidor y desplegar

```bash
ssh root@TU_IP_DIGITAL_OCEAN
cd /root/proyecto_santi_web
chmod +x deploy.sh
./deploy.sh
```

## Método 2: Usar Docker Compose

```bash
ssh root@TU_IP_DIGITAL_OCEAN
cd /root/proyecto_santi_web
docker-compose up -d --build
```

## Método 3: Usar Digital Ocean App Platform

1. Sube el contenido de `dist/proyecto_santi/web` a un repositorio Git (GitHub, GitLab)
2. Ve a [Digital Ocean App Platform](https://cloud.digitalocean.com/apps)
3. Crea una nueva app y conecta tu repositorio
4. Selecciona "Static Site" o "Docker" como tipo
5. Configura el puerto 80
6. Deploy!

## Configurar dominio personalizado (opcional)

### Con Nginx como reverse proxy:

```bash
apt install nginx certbot python3-certbot-nginx -y

# Crear configuración
cat > /etc/nginx/sites-available/proyecto_santi << 'EOF'
server {
    listen 80;
    server_name tu-dominio.com www.tu-dominio.com;

    location / {
        proxy_pass http://localhost:8080;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
EOF

ln -s /etc/nginx/sites-available/proyecto_santi /etc/nginx/sites-enabled/
nginx -t && systemctl reload nginx

# Obtener certificado SSL (gratis con Let's Encrypt)
certbot --nginx -d tu-dominio.com -d www.tu-dominio.com
```

## Verificar el despliegue

```bash
# Ver estado del contenedor
docker ps

# Ver logs
docker logs -f proyecto-santi-web

# Probar localmente
curl http://localhost:8080
```

## Comandos útiles

```bash
# Reiniciar la app
docker restart proyecto-santi-web

# Actualizar la app (después de subir nuevos archivos)
docker stop proyecto-santi-web
docker rm proyecto-santi-web
docker build -t proyecto-santi-web .
docker run -d --name proyecto-santi-web -p 8080:80 --restart unless-stopped proyecto-santi-web

# Ver uso de recursos
docker stats proyecto-santi-web
```

## Notas

- El puerto por defecto es 8080. Modifica `deploy.sh` o `docker-compose.yml` si necesitas otro
- La app usa Nginx Alpine para servir los archivos estáticos (imagen muy ligera ~23MB)
- Los archivos estáticos tienen caché de 1 año configurado
- Gzip está habilitado para mejor rendimiento
