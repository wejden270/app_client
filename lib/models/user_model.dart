class User {
  final int id;
  final String name;
  final String email;
  final String password;
  final String token;  // Nouveau champ pour stocker le token

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.token = "",  // Par défaut, le token est une chaîne vide
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'token': token,  // Ajouter le token dans la map
    };
  }

  // Constructeur pour la connexion
  factory User.login({required String email, required String password}) {
    return User(id: 0, name: '', email: email, password: password);
  }

  // Ajouter un constructeur pour récupérer un utilisateur avec un token
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user']['id'],
      name: json['user']['name'],
      email: json['user']['email'],
      password: "",  // Le mot de passe n'est pas nécessaire de le garder dans ce cas
      token: json['token'],  // Récupérer le token dans la réponse
    );
  }
}