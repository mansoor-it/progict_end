
import 'package:intl/intl.dart';

class Category {
	final String id;
	final String name;
	final String description;
	final String image;
	final String? createdAt;
	final String? updatedAt;

	Category({
		required this.id,
		required this.name,
		required this.description,
		required this.image,
		this.createdAt,
		this.updatedAt,
	});

	/// مُنشئ لإنشاء فئة جديدة بتعيين createdAt و updatedAt تلقائياً
	factory Category.create({
		required String id,
		required String name,
		required String description,
		required String image,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Category(
			id: id,
			name: name,
			description: description,
			image: image,
			createdAt: now,
			updatedAt: now,
		);
	}

	/// دالة copyWith لتحديث بيانات الفئة مع الحفاظ على createdAt وتحديث updatedAt إلى الوقت الحالي
	Category copyWith({
		String? id,
		String? name,
		String? description,
		String? image,
		String? createdAt,
		String? updatedAt,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Category(
			id: id ?? this.id,
			name: name ?? this.name,
			description: description ?? this.description,
			image: image ?? this.image,
			createdAt: this.createdAt, // لا يتغير تاريخ الإنشاء عند التعديل
			updatedAt: now, // يتم تحديث تاريخ التعديل تلقائياً
		);
	}

	factory Category.fromJson(Map<String, dynamic> json) {
		return Category(
			id: json['id'].toString(),
			name: json['name'],
			description: json['description'] ?? '',
			image: json['image'] ?? '',
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'name': name,
			'description': description,
			'image': image,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}
}



// import 'package:intl/intl.dart';
//
// class Category {
// 	final String id;
// 	final String name;
// 	final String description;
// 	final String image;
// 	final String? createdAt;
// 	final String? updatedAt;
//
// 	Category({
// 		required this.id,
// 		required this.name,
// 		required this.description,
// 		required this.image,
// 		this.createdAt,
// 		this.updatedAt,
// 	});
//
// 	/// مُنشئ لإنشاء فئة جديدة بتعيين createdAt و updatedAt تلقائياً
// 	factory Category.create({
// 		required String id,
// 		required String name,
// 		required String description,
// 		required String image,
// 	}) {
// 		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
// 		return Category(
// 			id: id,
// 			name: name,
// 			description: description,
// 			image: image,
// 			createdAt: now,
// 			updatedAt: now,
// 		);
// 	}
//
// 	/// دالة copyWith لتحديث بيانات الفئة مع الحفاظ على createdAt وتحديث updatedAt إلى الوقت الحالي
// 	Category copyWith({
// 		String? id,
// 		String? name,
// 		String? description,
// 		String? image,
// 		String? createdAt,
// 		String? updatedAt,
// 	}) {
// 		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
// 		return Category(
// 			id: id ?? this.id,
// 			name: name ?? this.name,
// 			description: description ?? this.description,
// 			image: image ?? this.image,
// 			createdAt: this.createdAt, // لا يتغير تاريخ الإنشاء عند التعديل
// 			updatedAt: now, // يتم تحديث تاريخ التعديل تلقائياً
// 		);
// 	}
//
// 	factory Category.fromJson(Map<String, dynamic> json) {
// 		return Category(
// 			id: json['id'].toString(),
// 			name: json['name'],
// 			description: json['description'] ?? '',
// 			image: json['image'] ?? '',
// 			createdAt: json['created_at'],
// 			updatedAt: json['updated_at'],
// 		);
// 	}
//
// 	Map<String, dynamic> toJson() {
// 		return {
// 			'id': id,
// 			'name': name,
// 			'description': description,
// 			'image': image,
// 			'created_at': createdAt ?? "",
// 			'updated_at': updatedAt ?? "",
// 		};
// 	}
// }
