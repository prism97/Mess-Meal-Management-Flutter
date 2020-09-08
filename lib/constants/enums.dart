enum AuthStatus {
  Uninitialized,
  Authenticated,
  Authenticating,
  Unauthenticated,
  Registering
}

enum UserRole { Admin, Manager, Messboy, Member }

extension UserRoleExtension on UserRole {
  static UserRole fromString(String role) {
    switch (role) {
      case "admin":
        return UserRole.Admin;
      case "manager":
        return UserRole.Manager;
      case "messboy":
        return UserRole.Messboy;
      case "member":
        return UserRole.Member;
      default:
        return UserRole.Member;
    }
  }
}
