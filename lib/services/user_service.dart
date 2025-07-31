class UserService {
  static Map<String, dynamic>? currentUser;
  static String? authToken;

  static void setUser(Map<String, dynamic> user, String token) {
    currentUser = {
      'id': user['id'],
      'name': user['name'],
      'email': user['email'],
    };
    authToken = token;
  }

  static void clearUser() {
    currentUser = null;
    authToken = null;
  }

  static void logout() {
    clearUser();
  }
}

