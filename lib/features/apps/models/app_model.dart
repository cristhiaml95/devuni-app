/// Modelo que representa un App (espacio de trabajo) en el sistema multi-tenant
class AppModel {
  final String id;
  final String name;
  final String description;
  final String ownerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? logoUrl;
  final bool isActive;

  const AppModel({
    required this.id,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.createdAt,
    required this.updatedAt,
    this.logoUrl,
    this.isActive = true,
  });

  /// Crear AppModel desde JSON (response de Supabase)
  factory AppModel.fromJson(Map<String, dynamic> json) {
    return AppModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ownerId: json['owner_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      logoUrl: json['logo_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Convertir AppModel a JSON (para enviar a Supabase)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'owner_id': ownerId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'logo_url': logoUrl,
      'is_active': isActive,
    };
  }

  /// Crear copia con campos modificados
  AppModel copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? logoUrl,
    bool? isActive,
  }) {
    return AppModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      logoUrl: logoUrl ?? this.logoUrl,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AppModel(id: $id, name: $name, description: $description, ownerId: $ownerId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Modelo que representa la membresía de un usuario en un App
class AppMemberModel {
  final String id;
  final String appId;
  final String userId;
  final AppRole role;
  final DateTime createdAt;
  final DateTime? invitedAt;
  final DateTime? joinedAt;
  final bool isActive;

  const AppMemberModel({
    required this.id,
    required this.appId,
    required this.userId,
    required this.role,
    required this.createdAt,
    this.invitedAt,
    this.joinedAt,
    this.isActive = true,
  });

  factory AppMemberModel.fromJson(Map<String, dynamic> json) {
    return AppMemberModel(
      id: json['id'] as String,
      appId: json['app_id'] as String,
      userId: json['user_id'] as String,
      role: AppRole.fromString(json['role'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      invitedAt: json['invited_at'] != null
          ? DateTime.parse(json['invited_at'] as String)
          : null,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'app_id': appId,
      'user_id': userId,
      'role': role.toString(),
      'created_at': createdAt.toIso8601String(),
      'invited_at': invitedAt?.toIso8601String(),
      'joined_at': joinedAt?.toIso8601String(),
      'is_active': isActive,
    };
  }

  AppMemberModel copyWith({
    String? id,
    String? appId,
    String? userId,
    AppRole? role,
    DateTime? createdAt,
    DateTime? invitedAt,
    DateTime? joinedAt,
    bool? isActive,
  }) {
    return AppMemberModel(
      id: id ?? this.id,
      appId: appId ?? this.appId,
      userId: userId ?? this.userId,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      invitedAt: invitedAt ?? this.invitedAt,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'AppMemberModel(id: $id, appId: $appId, userId: $userId, role: $role)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppMemberModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Enum que define los roles disponibles en un App
enum AppRole {
  owner('owner'),
  admin('admin'),
  member('member'),
  viewer('viewer');

  const AppRole(this.value);
  final String value;

  static AppRole fromString(String value) {
    return AppRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => AppRole.member,
    );
  }

  @override
  String toString() => value;

  /// Verificar si el rol tiene permisos de administración
  bool get isAdmin => this == AppRole.owner || this == AppRole.admin;

  /// Verificar si el rol puede editar
  bool get canEdit => this != AppRole.viewer;

  /// Verificar si el rol puede invitar usuarios
  bool get canInvite => isAdmin;

  /// Verificar si el rol puede gestionar otros miembros
  bool get canManageMembers => this == AppRole.owner;
}
