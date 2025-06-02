import 'package:intl/intl.dart';

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

  /// مُنشئ لإنشاء مدير جديد بتسجيل التاريخ تلقائياً
  factory Admin.create({
    required String id,
    required String name,
    required String type,
    required String vendorId,
    required String mobile,
    required String email,
    required String password,
    required String image,
    required String confirm,
    required String status,
    String? emailVerifiedAt,
    String? rememberToken,
    String? accessToken,
  }) {
    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    return Admin(
      id: id,
      name: name,
      type: type,
      vendorId: vendorId,
      mobile: mobile,
      email: email,
      password: password,
      image: image,
      confirm: confirm,
      status: status,
      emailVerifiedAt: emailVerifiedAt,
      rememberToken: rememberToken,
      accessToken: accessToken,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// دالة copyWith لتحديث بيانات المدير مع الحفاظ على createdAt وتحديث updatedAt
  Admin copyWith({
    String? id,
    String? name,
    String? type,
    String? vendorId,
    String? mobile,
    String? email,
    String? password,
    String? image,
    String? confirm,
    String? status,
    String? emailVerifiedAt,
    String? rememberToken,
    String? accessToken,
  }) {
    String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    return Admin(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      vendorId: vendorId ?? this.vendorId,
      mobile: mobile ?? this.mobile,
      email: email ?? this.email,
      password: password ?? this.password,
      image: image ?? this.image,
      confirm: confirm ?? this.confirm,
      status: status ?? this.status,
      emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
      rememberToken: rememberToken ?? this.rememberToken,
      accessToken: accessToken ?? this.accessToken,
      createdAt: this.createdAt,
      updatedAt: now,
    );
  }

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
      'email_verified_at': emailVerifiedAt ?? '',
      'remember_token': rememberToken ?? '',
      'access_token': accessToken ?? '',
      'created_at': createdAt ?? '',
      'updated_at': updatedAt ?? '',
    };
  }
}
