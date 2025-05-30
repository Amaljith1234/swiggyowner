class Profile {
  final String id;
  final String name;
  final String email;
  final String phone;

  Profile({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json["_id"] ?? "",
      name: json["name"] ?? "No Name",
      email: json["email"] ?? "No Email",
      phone: json["phone"].toString(), // Convert phone to string
    );
  }
}
