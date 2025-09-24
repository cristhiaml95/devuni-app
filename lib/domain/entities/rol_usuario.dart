enum RolUsuarioApp {
  visor,
  colaborador,
  administrador,
  propietario;

  String get nombre {
    switch (this) {
      case RolUsuarioApp.visor:
        return 'Visor';
      case RolUsuarioApp.colaborador:
        return 'Colaborador';
      case RolUsuarioApp.administrador:
        return 'Administrador';
      case RolUsuarioApp.propietario:
        return 'Propietario';
    }
  }

  String get descripcion {
    switch (this) {
      case RolUsuarioApp.visor:
        return 'Solo puede ver el contenido';
      case RolUsuarioApp.colaborador:
        return 'Puede crear, editar y gestionar inventario';
      case RolUsuarioApp.administrador:
        return 'Puede gestionar miembros e invitaciones';
      case RolUsuarioApp.propietario:
        return 'Control total de la aplicación';
    }
  }

  int get nivel {
    switch (this) {
      case RolUsuarioApp.visor:
        return 1;
      case RolUsuarioApp.colaborador:
        return 2;
      case RolUsuarioApp.administrador:
        return 3;
      case RolUsuarioApp.propietario:
        return 4;
    }
  }

  bool puedeHacer(RolUsuarioApp rolMinimo) {
    return nivel >= rolMinimo.nivel;
  }

  static RolUsuarioApp fromString(String rol) {
    switch (rol.toLowerCase()) {
      case 'visor':
        return RolUsuarioApp.visor;
      case 'colaborador':
        return RolUsuarioApp.colaborador;
      case 'administrador':
        return RolUsuarioApp.administrador;
      case 'propietario':
        return RolUsuarioApp.propietario;
      default:
        return RolUsuarioApp.visor;
    }
  }

  @override
  String toString() {
    return name;
  }
}