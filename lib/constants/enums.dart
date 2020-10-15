/*
The UI depends on the Status
- Uninitialized - Checking user is logged or not, Landing Screen will be shown
- Unregistered - User is logged in for the first time, Register Screen will be shown 
- Authenticated - User is authenticated successfully, Meal Check Screen will be shown
- Unauthenticated - User is not authenticated, Login Screen will be shown
 */

enum AuthStatus {
  Uninitialized,
  Unregistered,
  Authenticated,
  AuthenticatedAsMessboy,
  Unauthenticated,
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
