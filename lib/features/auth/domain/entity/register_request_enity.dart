

class RegisterRequestEntity {
  final String email;
  final String password;
  final String name;
  final String role;
  final String phone;

  const RegisterRequestEntity({
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    required this.phone,
  });

}
