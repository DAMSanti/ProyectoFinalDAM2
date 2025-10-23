@echo off
REM Script para iniciar la API ACEXAPI en 0.0.0.0:5000
cd /d C:\Users\santiagota\source\repos\ProyectoFinalDAM2\ACEXAPI
echo ==========================================
echo  Iniciando API ACEXAPI
echo  Puerto: 5000 (todas las interfaces)
echo  Swagger: http://192.168.9.190:5000/
echo ==========================================
echo.
dotnet run --launch-profile http
pause
