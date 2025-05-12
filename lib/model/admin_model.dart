class Admin {
  final String id;
  final String name;
  final String type;
  final String vendorId;
  final String mobile;
  final String email;
  final String password;
  final String image;
  final String confirm;
  final String status;
  final String? emailVerifiedAt;
  final String? rememberToken;
  final String? accessToken;
  final String? createdAt;
  final String? updatedAt;

  Admin({
    required this.id,
    required this.name,
    required this.type,
    required this.vendorId,
    required this.mobile,
    required this.email,
    required this.password,
    required this.image,
    required this.confirm,
    required this.status,
    this.emailVerifiedAt,
    this.rememberToken,
    this.accessToken,
    this.createdAt,
    this.updatedAt,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'].toString(),
      name: json['name'],
      type: json['type'],
      vendorId: json['vendor_id'].toString(),
      mobile: json['mobile'],
      email: json['email'],
      password: json['password'],
      image: json['image'] ?? '',
      confirm: json['confirm'],
      status: json['status'].toString(),
      emailVerifiedAt: json['email_verified_at'],
      rememberToken: json['remember_token'],
      accessToken: json['access_token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'vendor_id': vendorId,
      'mobile': mobile,
      'email': email,
      'password': password,
      'image': image,
      'confirm': confirm,
      'status': status,
      // تحويل القيم الاختيارية إلى نص فارغ في حال كانت null
      'email_verified_at': emailVerifiedAt ?? "",
      'remember_token': rememberToken ?? "",
      'access_token': accessToken ?? "",
      'created_at': createdAt ?? "",
      'updated_at': updatedAt ?? "",
    };
  }
}
