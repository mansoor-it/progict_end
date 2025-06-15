import 'package:intl/intl.dart';

class Vendor {
	final String id;
	final String name;
	final String? address;
	final String? city;
	final String? state;
	final String? country;
	final String? pincode;
	final String mobile;
	final String email;
	final String password;
	final String? image;
	final String confirm;
	final double commission;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	// ✅ الخصائص الجديدة المطلوبة
	final String? accessToken;
	final String? emailVerifiedAt;
	final String? rememberToken;

	Vendor({
		required this.id,
		required this.name,
		this.address,
		this.city,
		this.state,
		this.country,
		this.pincode,
		required this.mobile,
		required this.email,
		required this.password,
		this.image,
		required this.confirm,
		required this.commission,
		required this.status,
		this.createdAt,
		this.updatedAt,
		this.accessToken,
		this.emailVerifiedAt,
		this.rememberToken,
	});

	factory Vendor.create({
		required String id,
		required String name,
		String? address,
		String? city,
		String? state,
		String? country,
		String? pincode,
		required String mobile,
		required String email,
		required String password,
		String? image,
		required String confirm,
		required double commission,
		required String status,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Vendor(
			id: id,
			name: name,
			address: address,
			city: city,
			state: state,
			country: country,
			pincode: pincode,
			mobile: mobile,
			email: email,
			password: password,
			image: image,
			confirm: confirm,
			commission: commission,
			status: status,
			createdAt: now,
			updatedAt: now,
		);
	}

	Vendor copyWith({
		String? id,
		String? name,
		String? address,
		String? city,
		String? state,
		String? country,
		String? pincode,
		String? mobile,
		String? email,
		String? password,
		String? image,
		String? confirm,
		double? commission,
		String? status,
		String? accessToken,
		String? emailVerifiedAt,
		String? rememberToken,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Vendor(
			id: id ?? this.id,
			name: name ?? this.name,
			address: address ?? this.address,
			city: city ?? this.city,
			state: state ?? this.state,
			country: country ?? this.country,
			pincode: pincode ?? this.pincode,
			mobile: mobile ?? this.mobile,
			email: email ?? this.email,
			password: password ?? this.password,
			image: image ?? this.image,
			confirm: confirm ?? this.confirm,
			commission: commission ?? this.commission,
			status: status ?? this.status,
			createdAt: this.createdAt,
			updatedAt: now,
			accessToken: accessToken ?? this.accessToken,
			emailVerifiedAt: emailVerifiedAt ?? this.emailVerifiedAt,
			rememberToken: rememberToken ?? this.rememberToken,
		);
	}

	factory Vendor.fromJson(Map<String, dynamic> json) {
		return Vendor(
			id: json['id'].toString(),
			name: json['name'],
			address: json['address'],
			city: json['city'],
			state: json['state'],
			country: json['country'],
			pincode: json['pincode'],
			mobile: json['mobile'] ?? '',
			email: json['email'],
			password: json['password'],
			image: json['image'],
			confirm: json['confirm'] ?? 'No',
			commission: (json['commission'] is num)
					? (json['commission'] as num).toDouble()
					: (json['commission'] != null &&
					json['commission'].toString().isNotEmpty)
					? double.tryParse(json['commission'].toString()) ?? 0.0
					: 0.0,
			status: json['status'].toString(),
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
			accessToken: json['access_token'],
			emailVerifiedAt: json['email_verified_at'],
			rememberToken: json['remember_token'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'address': address ?? "",
			'city': city ?? "",
			'state': state ?? "",
			'country': country ?? "",
			'pincode': pincode ?? "",
			'mobile': mobile,
			'email': email,
			'password': password,
			'image': image ?? "",
			'confirm': confirm,
			'commission': commission.toString(),
			'status': status,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
			'access_token': accessToken ?? "",
			'email_verified_at': emailVerifiedAt ?? "",
			'remember_token': rememberToken ?? "",
		};
	}

	/// تستخدم هذه الدالة عند الإرسال إلى API (http.post)
	Map<String, String> toJsonForRequest() {
		return {
			'id': id,
			'name': name,
			'address': address ?? "",
			'city': city ?? "",
			'state': state ?? "",
			'country': country ?? "",
			'pincode': pincode ?? "",
			'mobile': mobile,
			'email': email,
			'password': password,
			'image': image ?? "",
			'confirm': confirm,
			'commission': commission.toString(),
			'status': status,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
			'access_token': accessToken ?? "",
			'email_verified_at': emailVerifiedAt ?? "",
			'remember_token': rememberToken ?? "",
		};
	}
}
