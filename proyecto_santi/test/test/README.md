# 🧪 Testing Guide - Guía de Tests

Esta guía explica cómo ejecutar los tests unitarios y de widgets en el proyecto ACEX.

## 📋 Tests Incluidos

### 1. **Tests de Modelos** (`test/models/actividad_test.dart`)
- Creación de actividades desde JSON
- Manejo de campos nulos
- Conversión a JSON

### 2. **Tests de Utilidades** (`test/utils/`)
- `scale_factor_test.dart`: Tests para el escalado en diferentes resoluciones (4K, 2K, Full HD)
- `date_format_test.dart`: Tests para formateo de fechas

### 3. **Tests de Servicios** (`test/services/api_service_test.dart`)
- Inicialización del ApiService
- Verificación de tipos de retorno

### 4. **Tests de Widgets** (`test/widgets/activity_card_test.dart`)
- Renderizado de tarjetas de actividad
- Visualización de título, descripción y estado
- Manejo de datos faltantes

## 🚀 Cómo Ejecutar los Tests

### Opción 1: Desde la Terminal en VS Code

#### Ejecutar TODOS los tests:
```powershell
cd "g:\ProyectoFinalC#\ProyectoFinalDAM2\proyecto_santi"
flutter test
```

#### Ejecutar un archivo específico:
```powershell
# Test de modelos
flutter test test/models/actividad_test.dart

# Test de scale factor
flutter test test/utils/scale_factor_test.dart

# Test de widgets
flutter test test/widgets/activity_card_test.dart
```

#### Ejecutar tests con cobertura:
```powershell
flutter test --coverage
```

### Opción 2: Desde VS Code (Interfaz Gráfica)

1. **Instalar la extensión Flutter** (si no la tienes):
   - Presiona `Ctrl + Shift + X`
   - Busca "Flutter" y instala la extensión oficial

2. **Ejecutar tests desde el explorador**:
   - Abre cualquier archivo `*_test.dart`
   - Verás iconos de "▶️ Run" y "🐛 Debug" encima de cada test
   - Click en "▶️ Run" para ejecutar ese test específico
   - Click en "🐛 Debug" para ejecutar en modo debug

3. **Ver resultados**:
   - Los resultados aparecerán en la pestaña "Debug Console"
   - ✅ Verde = Test pasado
   - ❌ Rojo = Test fallido

### Opción 3: Usando el Panel de Testing de VS Code

1. Click en el icono de "Testing" en la barra lateral izquierda (icono de matraz 🧪)
2. VS Code detectará automáticamente todos tus tests
3. Puedes ejecutar:
   - Todos los tests (click en el ▶️ arriba)
   - Tests por carpeta
   - Tests individuales

## 📊 Interpretar los Resultados

### Ejemplo de salida exitosa:
```
00:01 +5: All tests passed!
```

### Ejemplo de salida con fallo:
```
00:01 +4 -1: test/models/actividad_test.dart: Actividad debería crearse correctamente desde JSON [E]
  Expected: 1
  Actual: null
```

## 🎯 Atajos de Teclado en VS Code

| Atajo | Acción |
|-------|--------|
| `Ctrl + Shift + P` → "Flutter: Run Tests" | Ejecutar todos los tests |
| Click derecho en archivo → "Run Tests" | Ejecutar tests del archivo |
| `F5` en archivo de test | Debug del test |

## 📈 Cobertura de Tests

Para ver la cobertura de código:

```powershell
# Generar reporte de cobertura
flutter test --coverage

# Ver el reporte (necesitas instalar lcov)
# En Windows con Chocolatey:
choco install lcov

# Generar HTML
genhtml coverage/lcov.info -o coverage/html

# Abrir en navegador
start coverage/html/index.html
```

## 🔧 Troubleshooting

### Problema: "No tests found"
**Solución**: Asegúrate de que los archivos terminan en `_test.dart`

### Problema: Tests fallan por Firebase
**Solución**: Los tests de Firebase requieren configuración adicional. Por ahora, estos tests están comentados.

### Problema: "Package not found"
**Solución**: Ejecuta `flutter pub get` primero

### Problema: Tests lentos
**Solución**: 
- Ejecuta tests específicos en lugar de todos
- Usa `flutter test --plain-name "nombre del test"`

## 📝 Buenas Prácticas

1. **Ejecuta los tests antes de hacer commit**
2. **Añade tests para cada nueva funcionalidad**
3. **Mantén los tests simples y enfocados**
4. **Usa nombres descriptivos para los tests**
5. **Agrupa tests relacionados con `group()`**

## 🎓 Aprender Más

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Unit Testing](https://docs.flutter.dev/cookbook/testing/unit/introduction)

---

**¡Importante!** Siempre ejecuta `flutter test` antes de hacer push a tu repositorio para asegurarte de que no has roto nada. 🚀
