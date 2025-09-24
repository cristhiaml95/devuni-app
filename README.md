# DevUni App - Sistema de Inventario Multi-Espacio

Una aplicación Flutter para gestión de inventario con múltiples espacios de trabajo (Apps), autenticación con Google, y roles de usuario.

## Características

- 🔐 **Autenticación**: Inicio de sesión con Google OAuth
- 🏢 **Multi-Espacio**: Gestión de múltiples aplicaciones/espacios
- 👥 **Roles de Usuario**: Visor, Colaborador, Administrador, Propietario
- 📦 **Inventario**: Gestión de productos, categorías, unidades de medida
- 📊 **Dashboard**: Vista general con acciones rápidas
- ✉️ **Invitaciones**: Sistema de invitaciones por email

## Arquitectura

### Frontend (Flutter)
- **Gestión de Estado**: Riverpod (hooks_riverpod)
- **Navegación**: GoRouter
- **UI**: Material Design 3
- **Autenticación**: supabase_flutter

### Backend (Supabase)
- **Base de Datos**: PostgreSQL
- **Autenticación**: Supabase Auth con Google OAuth
- **API**: PostgREST
- **Seguridad**: Row Level Security (RLS)

### Estructura del Proyecto
```
lib/
├── app/                    # Configuración global de la app
│   ├── core/
│   ├── providers/         # Providers globales (Riverpod)
│   ├── router/           # Configuración de rutas
│   └── theme/            # Temas y estilos
├── core/                 # Utilidades centrales
│   ├── errors/           # Manejo de errores
│   └── types/            # Tipos personalizados (Resultado)
├── data/                 # Capa de datos
│   ├── clients/          # Cliente Supabase
│   └── repositories/     # Repositorios
├── domain/               # Entidades del dominio
│   └── entities/
└── features/             # Características de la app
    ├── auth/            # Autenticación
    ├── apps/            # Gestión de aplicaciones
    ├── inventory/       # Módulo de inventario
    └── members/         # Gestión de miembros
```

## Configuración

### 1. Prerrequisitos
- Flutter 3.24.0 o superior
- Dart SDK
- Cuenta de Supabase
- Proyecto configurado en Google Cloud Console

### 2. Configuración de Supabase

#### Base de Datos
Ejecuta el esquema SQL proporcionado en tu proyecto de Supabase para crear:
- Tablas principales (apps, perfiles, miembros, etc.)
- Políticas RLS
- Funciones y vistas

#### Autenticación
1. En el panel de Supabase, ve a Authentication > Settings
2. Configura Google OAuth:
   - Client ID de Google
   - Client Secret de Google
   - Redirect URLs autorizadas

### 3. Configuración del Proyecto Flutter

#### Instalar dependencias
```bash
flutter pub get
```

#### Archivo de configuración
Crea un archivo `.env` en la raíz del proyecto:
```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima
```

#### Configuración de Google OAuth (Android)
1. Coloca tu archivo `google-services.json` en `android/app/`
2. Actualiza `android/app/build.gradle` con el applicationId correcto

#### Configuración de Google OAuth (iOS)
1. Coloca tu archivo `GoogleService-Info.plist` en `ios/Runner/`
2. Actualiza `ios/Runner/Info.plist` con los URL schemes

## Ejecución

### Desarrollo
```bash
flutter run
```

### Construcción
```bash
# Android
flutter build apk

# iOS
flutter build ios
```

## Uso de la Aplicación

### 1. Primer Inicio
1. Inicia sesión con tu cuenta de Google
2. Crea tu primera aplicación/espacio
3. Invita colaboradores si es necesario

### 2. Gestión de Miembros
- **Propietarios**: Control total
- **Administradores**: Gestionar miembros e invitaciones
- **Colaboradores**: Crear y editar inventario
- **Visores**: Solo lectura

### 3. Módulo de Inventario
1. **Configuración inicial**:
   - Crear unidades de medida (kg, litros, piezas, etc.)
   - Definir categorías de productos
2. **Gestión de productos**:
   - Agregar productos con códigos únicos
   - Configurar stock mínimo
   - Asignar ubicaciones
3. **Control de stock**:
   - Registrar movimientos (entradas/salidas)
   - Alertas de stock bajo
   - Historial de movimientos

## Testing

### Ejecutar tests
```bash
flutter test
```

### Tests incluidos
- Tests unitarios para repositorios
- Tests de widgets principales
- Tests de integración básicos

## Estructura de Base de Datos

### Tablas Principales
- `apps`: Aplicaciones/espacios de trabajo
- `perfiles`: Perfiles de usuario
- `miembros`: Relación usuario-app con roles
- `invitaciones`: Invitaciones pendientes
- `productos`: Catálogo de productos
- `categorias`: Categorías de productos
- `unidades_medida`: Unidades de medida
- `movimientos_inventario`: Historial de movimientos

### Características de Seguridad
- Row Level Security (RLS) en todas las tablas
- Políticas basadas en roles
- Validaciones a nivel de base de datos

## Desarrollo y Contribuciones

### Estilo de Código
- Seguir las convenciones de Dart/Flutter
- Usar nombres descriptivos en español para UI
- Documentar funciones complejas
- Mantener separación clara entre capas

### Nuevas Características
1. Crear feature branch
2. Implementar con tests
3. Actualizar documentación
4. Crear pull request

## Troubleshooting

### Problemas Comunes

**Error de autenticación**
- Verificar configuración OAuth en Supabase
- Revisar google-services.json/GoogleService-Info.plist
- Comprobar bundle ID/package name

**Error de conexión a Supabase**
- Verificar SUPABASE_URL y SUPABASE_ANON_KEY
- Comprobar políticas RLS
- Revisar logs en panel de Supabase

**Problemas de permisos**
- Verificar rol del usuario en la app
- Comprobar políticas RLS en tablas afectadas
- Revisar funciones/triggers de base de datos

## Próximas Características

- [ ] Reportes y analíticas
- [ ] Códigos de barras/QR
- [ ] Notificaciones push
- [ ] Exportación de datos
- [ ] API REST para integraciones
- [ ] Soporte multi-idioma completo

## Licencia

Este proyecto está bajo la licencia MIT. Ver archivo LICENSE para más detalles.

## Contacto

Para soporte o consultas sobre el proyecto, contacta al equipo de desarrollo.