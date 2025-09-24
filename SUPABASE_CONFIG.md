# Configurar Supabase para DevUni App

Este documento te guía paso a paso para configurar tu proyecto de Supabase.

## 1. Crear un nuevo proyecto en Supabase

1. Ve a [supabase.com](https://supabase.com)
2. Inicia sesión o crea una cuenta
3. Crea un nuevo proyecto
4. Anota la URL y la clave anónima

## 2. Configurar autenticación con Google

### En Google Cloud Console:
1. Ve a [Google Cloud Console](https://console.cloud.google.com)
2. Crea un nuevo proyecto o selecciona uno existente
3. Habilita la API de Google+ 
4. Ve a "Credenciales" → "Crear credenciales" → "ID de cliente OAuth 2.0"
5. Configura:
   - Tipo de aplicación: Web application
   - Orígenes autorizados: `https://tu-proyecto.supabase.co`
   - URIs de redirección: `https://tu-proyecto.supabase.co/auth/v1/callback`

### En Supabase Dashboard:
1. Ve a Authentication → Settings
2. Habilita Google provider
3. Pega Client ID y Client Secret de Google
4. Guarda los cambios

## 3. Ejecutar el esquema SQL

Copia y pega el siguiente SQL en la pestaña "SQL Editor" de Supabase:

```sql
-- Habilitar extensiones necesarias
create extension if not exists "uuid-ossp";

-- Crear tipos ENUM
create type rol_usuario_app as enum ('visor', 'editor', 'administrador', 'propietario');
create type estado_invitacion as enum ('pendiente', 'aceptada', 'cancelada');
create type tipo_movimiento as enum ('entrada', 'salida', 'transferencia', 'ajuste');

-- Tabla: apps (aplicaciones/organizaciones)
create table public.apps (
  id uuid default uuid_generate_v4() primary key,
  nombre text not null,
  descripcion text,
  slug text unique not null,
  propietario_id uuid references auth.users(id) on delete cascade not null,
  creado_en timestamp with time zone default now() not null,
  actualizado_en timestamp with time zone default now() not null
);

-- Tabla: miembros_app (relación usuario-app con rol)
create table public.miembros_app (
  id uuid default uuid_generate_v4() primary key,
  app_id uuid references public.apps(id) on delete cascade not null,
  usuario_id uuid references auth.users(id) on delete cascade not null,
  rol rol_usuario_app not null default 'visor',
  creado_en timestamp with time zone default now() not null,
  unique(app_id, usuario_id)
);

-- Tabla: invitaciones
create table public.invitaciones (
  id uuid default uuid_generate_v4() primary key,
  app_id uuid references public.apps(id) on delete cascade not null,
  email text not null,
  rol rol_usuario_app not null default 'visor',
  estado estado_invitacion not null default 'pendiente',
  token text unique not null default encode(gen_random_bytes(32), 'hex'),
  invitado_por uuid references auth.users(id) on delete cascade not null,
  creado_en timestamp with time zone default now() not null,
  aceptado_en timestamp with time zone,
  unique(app_id, email)
);

-- Tabla: categorias
create table public.categorias (
  id uuid default uuid_generate_v4() primary key,
  app_id uuid references public.apps(id) on delete cascade not null,
  nombre text not null,
  descripcion text,
  color text default '#2196F3',
  creado_en timestamp with time zone default now() not null,
  unique(app_id, nombre)
);

-- Tabla: unidades_medida
create table public.unidades_medida (
  id uuid default uuid_generate_v4() primary key,
  app_id uuid references public.apps(id) on delete cascade not null,
  nombre text not null,
  simbolo text not null,
  tipo text not null default 'cantidad', -- cantidad, peso, volumen, longitud
  creado_en timestamp with time zone default now() not null,
  unique(app_id, nombre),
  unique(app_id, simbolo)
);

-- Tabla: productos
create table public.productos (
  id uuid default uuid_generate_v4() primary key,
  app_id uuid references public.apps(id) on delete cascade not null,
  codigo text not null,
  nombre text not null,
  descripcion text,
  categoria_id uuid references public.categorias(id) on delete set null,
  unidad_medida_id uuid references public.unidades_medida(id) on delete set null,
  precio_compra decimal(10,2),
  precio_venta decimal(10,2),
  stock_minimo decimal(10,2) default 0,
  activo boolean default true,
  creado_en timestamp with time zone default now() not null,
  actualizado_en timestamp with time zone default now() not null,
  unique(app_id, codigo)
);

-- RLS (Row Level Security) Policies

-- Apps: solo propietarios y miembros pueden ver/editar
alter table public.apps enable row level security;

create policy "Usuarios pueden ver apps donde son miembros" on public.apps
  for select using (
    id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Solo propietarios pueden crear apps" on public.apps
  for insert with check (propietario_id = auth.uid());

create policy "Solo propietarios pueden actualizar apps" on public.apps
  for update using (propietario_id = auth.uid());

create policy "Solo propietarios pueden eliminar apps" on public.apps
  for delete using (propietario_id = auth.uid());

-- Miembros App: solo miembros pueden ver otros miembros
alter table public.miembros_app enable row level security;

create policy "Miembros pueden ver otros miembros de su app" on public.miembros_app
  for select using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Solo administradores+ pueden gestionar miembros" on public.miembros_app
  for all using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid() 
      and rol in ('administrador', 'propietario')
    )
  );

-- Invitaciones
alter table public.invitaciones enable row level security;

create policy "Miembros pueden ver invitaciones de su app" on public.invitaciones
  for select using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Solo administradores+ pueden gestionar invitaciones" on public.invitaciones
  for all using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid() 
      and rol in ('administrador', 'propietario')
    )
  );

-- Productos, Categorías, Unidades: miembros pueden ver, editores+ pueden modificar
alter table public.categorias enable row level security;
alter table public.unidades_medida enable row level security;
alter table public.productos enable row level security;

-- Políticas para Categorías
create policy "Miembros pueden ver categorías" on public.categorias
  for select using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Editores+ pueden gestionar categorías" on public.categorias
  for all using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid() 
      and rol in ('editor', 'administrador', 'propietario')
    )
  );

-- Políticas para Unidades de Medida
create policy "Miembros pueden ver unidades" on public.unidades_medida
  for select using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Editores+ pueden gestionar unidades" on public.unidades_medida
  for all using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid() 
      and rol in ('editor', 'administrador', 'propietario')
    )
  );

-- Políticas para Productos
create policy "Miembros pueden ver productos" on public.productos
  for select using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid()
    )
  );

create policy "Editores+ pueden gestionar productos" on public.productos
  for all using (
    app_id in (
      select app_id from public.miembros_app 
      where usuario_id = auth.uid() 
      and rol in ('editor', 'administrador', 'propietario')
    )
  );

-- Functions/RPCs

-- Crear app con propietario automático
create or replace function crear_app_con_propietario(
  p_nombre text,
  p_descripcion text default null,
  p_slug text default null
)
returns uuid
language plpgsql
security definer
as $$
declare
  nuevo_app_id uuid;
  slug_final text;
begin
  -- Generar slug si no se proporciona
  if p_slug is null then
    slug_final := lower(regexp_replace(p_nombre, '[^a-zA-Z0-9]', '-', 'g'));
    slug_final := regexp_replace(slug_final, '-+', '-', 'g');
    slug_final := trim(slug_final, '-');
  else
    slug_final := p_slug;
  end if;

  -- Crear la app
  insert into public.apps (nombre, descripcion, slug, propietario_id)
  values (p_nombre, p_descripcion, slug_final, auth.uid())
  returning id into nuevo_app_id;

  -- Agregar al creador como propietario en miembros_app
  insert into public.miembros_app (app_id, usuario_id, rol)
  values (nuevo_app_id, auth.uid(), 'propietario');

  return nuevo_app_id;
end;
$$;

-- Invitar usuario a app
create or replace function invitar_a_app(
  p_app_id uuid,
  p_email text,
  p_rol rol_usuario_app default 'visor'
)
returns text
language plpgsql
security definer
as $$
declare
  es_admin boolean;
begin
  -- Verificar permisos
  select exists(
    select 1 from public.miembros_app 
    where app_id = p_app_id 
    and usuario_id = auth.uid() 
    and rol in ('administrador', 'propietario')
  ) into es_admin;

  if not es_admin then
    raise exception 'No tienes permisos para invitar usuarios';
  end if;

  -- Crear invitación
  insert into public.invitaciones (app_id, email, rol, invitado_por)
  values (p_app_id, p_email, p_rol, auth.uid())
  on conflict (app_id, email) do update set
    rol = excluded.rol,
    estado = 'pendiente',
    token = encode(gen_random_bytes(32), 'hex'),
    creado_en = now();

  return 'Invitación enviada exitosamente';
end;
$$;

-- Aceptar invitación
create or replace function aceptar_invitacion(p_app_id uuid)
returns json
language plpgsql
security definer
as $$
declare
  invitacion_data record;
  usuario_email text;
  resultado json;
begin
  -- Obtener email del usuario actual
  select email into usuario_email from auth.users where id = auth.uid();

  -- Buscar invitación pendiente
  select * into invitacion_data
  from public.invitaciones
  where app_id = p_app_id 
  and email = usuario_email 
  and estado = 'pendiente';

  if not found then
    raise exception 'No se encontró invitación pendiente';
  end if;

  -- Agregar como miembro
  insert into public.miembros_app (app_id, usuario_id, rol)
  values (p_app_id, auth.uid(), invitacion_data.rol)
  on conflict (app_id, usuario_id) do update set rol = excluded.rol;

  -- Marcar invitación como aceptada
  update public.invitaciones
  set estado = 'aceptada', aceptado_en = now()
  where id = invitacion_data.id;

  -- Retornar datos del miembro
  select json_build_object(
    'app_id', p_app_id,
    'usuario_id', auth.uid(),
    'rol', invitacion_data.rol,
    'creado_en', now()
  ) into resultado;

  return resultado;
end;
$$;

-- Vistas útiles

-- Vista completa de miembros con información de usuario
create view public.vista_miembros_completa as
select 
  ma.id,
  ma.app_id,
  ma.usuario_id,
  ma.rol,
  ma.creado_en,
  au.email,
  au.raw_user_meta_data->>'full_name' as nombre_completo,
  au.raw_user_meta_data->>'avatar_url' as avatar_url
from public.miembros_app ma
join auth.users au on ma.usuario_id = au.id;

-- Insertar datos de ejemplo (opcional)
-- Puedes descomentar esto para tener datos de prueba

/*
-- Insertar categorías por defecto cuando se crea una app
create or replace function crear_datos_ejemplo(p_app_id uuid)
returns void
language plpgsql
as $$
begin
  -- Categorías ejemplo
  insert into public.categorias (app_id, nombre, descripcion, color) values
  (p_app_id, 'Electrónicos', 'Dispositivos y componentes electrónicos', '#2196F3'),
  (p_app_id, 'Oficina', 'Suministros de oficina', '#4CAF50'),
  (p_app_id, 'Limpieza', 'Productos de limpieza y mantenimiento', '#FF9800');

  -- Unidades de medida ejemplo
  insert into public.unidades_medida (app_id, nombre, simbolo, tipo) values
  (p_app_id, 'Piezas', 'pz', 'cantidad'),
  (p_app_id, 'Kilogramos', 'kg', 'peso'),
  (p_app_id, 'Litros', 'L', 'volumen'),
  (p_app_id, 'Metros', 'm', 'longitud');
end;
$$;
*/
```

## 4. Configurar variables de entorno

Crea el archivo `.env` con:

```env
SUPABASE_URL=https://tu-proyecto-id.supabase.co
SUPABASE_ANON_KEY=tu-clave-anonima-muy-larga
```

## 5. Ejecutar la aplicación

```bash
flutter pub get
flutter run -d web-server --web-port 3000
```

¡Listo! Tu aplicación debería estar funcionando con Supabase.