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

enum Department {
  Arch,
  ChE,
  CE,
  CSE,
  EEE,
  IPE,
  ME,
  MME,
  NAME,
  URP,
  WRE,
  BME,
  Other
}
