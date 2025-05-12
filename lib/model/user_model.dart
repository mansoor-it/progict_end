import 'package:intl/intl.dart';

class User {
	final String id;
	final String name;
	final String mobile;
	final String email;
	final String password;
	final String image;
	final String status;
	final String? emailVerifiedAt;
	final String? rememberToken;
	final String? accessToken;
	final String? createdAt;
	final String? updatedAt;

	User({
		required this.id,
		required this.name,
		required this.mobile,
		required this.email,
		required this.password,
		required this.image,
		required this.status,
		this.emailVerifiedAt,
		this.rememberToken,
		this.accessToken,
		this.createdAt,
		this.updatedAt,
	});

	/// مُنشئ لإنشاء مستخدم جديد بتعيين createdAt و updatedAt تلقائياً
	factory User.create({
		required String id,
		required String name,
		required String mobile,
		required String email,
		required String password,
		required String image,
		required String status,
		String? emailVerifiedAt,
		String? rememberToken,
		String? accessToken,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return User(
			id: id,
			name: name,
			mobile: mobile,
			email: email,
			password: password,
			image: image,
			status: status,
			emailVerifiedAt: emailVerifiedAt,
			rememberToken: rememberToken,
			accessToken: accessToken,
			createdAt: now,
			updatedAt: now,
		);
	}

	/// دالة copyWith لتحديث بيانات المستخدم مع الحفاظ على createdAt وتحديث updatedAt إلى الوقت الحالي
	User copyWith({
		String? id,
		String? name,
		String? mobile,
		String? email,
		String? password,
		String? image,
		String? status,
		String? emailVerifiedAt,
		String? rememberToken,
		String? accessToken,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return User(
			id: id ?? this.id,
			name: name ?? this.name,
			mobile: mobile ?? this.mobile,
			email: email ?? this.email,
			password: password ?? this.password,
			image: image ?? this.image,
			status: status ?? this.status,
			emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
			rememberToken: rememberToken ?? this.rememberToken,
			accessToken: accessToken ?? this.accessToken,
			createdAt: this.createdAt, // لا يتغير تاريخ الإنشاء عند التعديل
			updatedAt: now, // يتم تحديث تاريخ التعديل تلقائياً
		);
	}

	factory User.fromJson(Map<String, dynamic> json) {
		return User(
			id: json['id'].toString(),
			name: json['name'],
			mobile: json['mobile'] ?? '',
			email: json['email'],
			password: json['password'],
			image: json['image'] ?? '',
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
			'mobile': mobile,
			'email': email,
			'password': password,
			'image': image,
			'status': status,
			'email_verified_at': emailVerifiedAt ?? "",
			'remember_token': rememberToken ?? "",
			'access_token': accessToken ?? "",
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}
}
