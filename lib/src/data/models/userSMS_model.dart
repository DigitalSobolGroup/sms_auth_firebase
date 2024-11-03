class UserSMS {
  final String id;
  final String phoneNumber;
  final String otp;
  final String name;

  UserSMS({
    required this.id,
    required this.phoneNumber,
    required this.otp,
    required this.name,
  });

  factory UserSMS.fromJson(Map<String, dynamic> json) {
    return UserSMS(
      id: json['id'],
      phoneNumber: json['phoneNumber'],
      otp: json['otp'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'otp': otp,
      'name': name,
    };
  }
}