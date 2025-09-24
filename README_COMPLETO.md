# DevUni App - Sistema de Inventario Multi-Tenant

Aplicación web/móvil multi-tenant de inventario construida con Flutter y Supabase con autenticación OAuth, roles de usuario y arquitectura limpia.

## 🚀 Características

- **Multi-tenant**: Soporte para múltiples organizaciones/apps
- **Roles y permisos**: Sistema completo de autorización con roles Propietario, Administrador, Editor y Visor
- **Autenticación con Google**: OAuth2 integrado con Supabase Auth
- **Gestión de inventario**: Productos, categorías, unidades de medida, almacenes
- **Gestión de miembros**: Sistema de invitaciones y asignación de roles
- **Diseño responsive**: Adaptado para web, móvil y tablets
- **UI en español**: Interfaz completamente localizada

## 📋 Requisitos Previos

- Flutter (versión estable)
- Cuenta de Supabase configurada
- Navegador web moderno (para desarrollo web)

## ⚙️ Configuración

### 1. Clonar y navegar al proyecto

```bash
git clone <repository-url>
cd project
```

### 2. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```env
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_anonima_de_supabase
```

**Nota**: Reemplaza con tus credenciales reales de Supabase.

### 3. Instalar dependencias

```bash
flutter pub get
```

### 4. Ejecutar la aplicación

#### Para desarrollo web (recomendado):
```bash
flutter run -d web-server --web-port 3000
```

Luego abre: `http://localhost:3000`

#### Para Chrome/Edge:
```bash
flutter run -d chrome
```

#### Para móvil:
```bash
flutter run
```

## 🏗️ Arquitectura del Proyecto

```
lib/
├── app/                    # Configuración global de la app
│   ├── core/              # Configuración, tema, constantes
│   ├── providers/         # Providers globales de Riverpod
│   └── router/           # Configuración de rutas con go_router
├── core/                  # Funcionalidades base
│   ├── errors/           # Manejo de errores
│   ├── types/            # Tipos base (Resultado<T>)
│   └── utils/            # Utilidades y helpers
├── data/                  # Capa de datos
│   ├── clients/          # Cliente de Supabase
│   └── repositories/     # Implementación de repositorios
├── domain/               # Capa de dominio
│   └── entities/         # Entidades de negocio
└── features/             # Funcionalidades por módulo
    ├── auth/             # Autenticación
    ├── apps/             # Gestión de aplicaciones/organizaciones
    ├── inventory/        # Módulo de inventario
    └── members/          # Gestión de miembros
```

## 🔐 Sistema de Roles

### Tipos de Roles:
- **Propietario**: Control total sobre la aplicación
- **Administrador**: Gestión de usuarios y configuración
- **Editor**: Modificación de inventario y datos
- **Visor**: Solo lectura

### Permisos por Rol:
- **Gestión de miembros**: Propietario y Administrador
- **Edición de inventario**: Propietario, Administrador y Editor
- **Visualización**: Todos los roles

## 📱 Funcionalidades Principales

### Autenticación
- Login con Google OAuth
- Gestión de sesiones con Supabase Auth
- Redirección automática según estado de autenticación

### Gestión de Apps/Organizaciones
- Creación de nuevas organizaciones
- Selector de aplicación actual
- Sistema de invitaciones por email

### Módulo de Inventario
- **Productos**: CRUD completo con categorías y unidades
- **Categorías**: Organización de productos
- **Unidades de medida**: kg, litros, piezas, etc.
- **Almacenes**: Múltiples ubicaciones
- **Movimientos**: Entradas, salidas, transferencias
- **Stock**: Control de existencias en tiempo real

### Gestión de Miembros
- Invitación de usuarios por email
- Asignación y modificación de roles
- Lista de miembros activos y pendientes

## 🧪 Testing

### Ejecutar tests:
```bash
flutter test
```

### Tests incluidos:
- Tests unitarios de entidades de dominio
- Tests de widgets de autenticación
- Tests de repositorios (próximamente)

## 🌐 Configuración Web

### Archivos web importantes:
- `web/index.html`: Configuración HTML base
- `web/manifest.json`: Metadatos de PWA
- `web/icons/`: Iconos para diferentes tamaños

### Características web:
- Compatible con navegadores modernos
- Diseño responsive
- Soporte para PWA (Progressive Web App)

## 🔧 Configuración de Supabase

### Tablas requeridas:
- `apps`: Aplicaciones/organizaciones
- `miembros_app`: Miembros y roles
- `invitaciones`: Invitaciones pendientes
- `productos`: Inventario de productos
- `categorias`: Categorías de productos
- `unidades_medida`: Unidades de medida

### RLS (Row Level Security):
- Configurado para multi-tenancy
- Acceso basado en roles de usuario
- Políticas de seguridad por tabla

### RPCs (Remote Procedure Calls):
- `crear_app_con_propietario`: Crear nueva app
- `invitar_a_app`: Enviar invitación
- `aceptar_invitacion`: Aceptar invitación
- Y más procedimientos para lógica de negocio

## 📚 Dependencias Principales

- **flutter**: Framework UI
- **hooks_riverpod**: Gestión de estado
- **supabase_flutter**: Backend como servicio
- **go_router**: Navegación y rutas
- **google_sign_in**: Autenticación OAuth
- **flutter_dotenv**: Variables de entorno

## 🚀 Despliegue

### Para web:
```bash
flutter build web
```

### Para móvil:
```bash
flutter build apk  # Android
flutter build ios  # iOS
```

## 🤝 Contribución

1. Fork el proyecto
2. Crear una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abrir un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 🆘 Soporte

Si encuentras algún problema o tienes preguntas:

1. Revisa que las variables de entorno estén configuradas correctamente
2. Verifica que Supabase esté configurado con las tablas y políticas necesarias
3. Asegúrate de tener la versión correcta de Flutter instalada

---

**¡Listo para usar!** 🎉

La aplicación debería estar funcionando en `http://localhost:3000` después de seguir estos pasos.