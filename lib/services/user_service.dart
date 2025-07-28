class UserService {
  static Map<String, dynamic>? currentUser;

  static void setUser(Map<String, dynamic> user) {
    currentUser = user;
  }

  static void clearUser() {
    currentUser = null;
  }
}
