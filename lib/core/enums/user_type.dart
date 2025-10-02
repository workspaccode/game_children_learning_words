enum UserType {
  child,
  parent,
  teacher,
  admin;

  String get displayName {
    switch (this) {
      case UserType.child:
        return 'Child';
      case UserType.parent:
        return 'Parent';
      case UserType.teacher:
        return 'Teacher';
      case UserType.admin:
        return 'Admin';
    }
  }
}
