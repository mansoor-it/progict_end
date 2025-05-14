import 'package:intl/intl.dart';

class Store {
	final String id;
	final String userId;
	final String categoryId;
	final String name;
	final String description;
	final String address;
	final String storeImage;
	final String rating;
	final String isActive;
	final String? createdAt;
	final String? updatedAt;

	Store({
		required this.id,
		required this.userId,
		required this.categoryId,
		required this.name,
		required this.description,
		required this.address,
		required this.storeImage,
		required this.rating,
		required this.isActive,
		this.createdAt,
		this.updatedAt,
	});

	/// منشئ تلقائي مع تاريخ الإنشاء والتعديل
	factory Store.create({
		required String id,
		required String userId,
		required String categoryId,
		required String name,
		required String description,
		required String address,
		required String storeImage,
		required String rating,
		required String isActive,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Store(
			id: id,
			userId: userId,
			categoryId: categoryId,
			name: name,
			description: description,
			address: address,
			storeImage: storeImage,
			rating: rating,
			isActive: isActive,
			createdAt: now,
			updatedAt: now,
		);
	}

	/// تحديث القيم مع الحفاظ على createdAt وتحديث updatedAt
	Store copyWith({
		String? id,
		String? userId,
		String? categoryId,
		String? name,
		String? description,
		String? address,
		String? storeImage,
		String? rating,
		String? isActive,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return Store(
			id: id ?? this.id,
			userId: userId ?? this.userId,
			categoryId: categoryId ?? this.categoryId,
			name: name ?? this.name,
			description: description ?? this.description,
			address: address ?? this.address,
			storeImage: storeImage ?? this.storeImage,
			rating: rating ?? this.rating,
			isActive: isActive ?? this.isActive,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory Store.fromJson(Map<String, dynamic> json) {
		return Store(
			id: json['id'].toString(),
			userId: json['user_id'].toString(),
			categoryId: json['category_id'].toString(),
			name: json['name'] ?? '',
			description: json['description'] ?? '',
			address: json['address'] ?? '',
			storeImage: json['store_image'] ?? '',
			rating: json['rating']?.toString() ?? '0',
			isActive: json['is_active']?.toString() ?? '0',
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'user_id': userId,
			'category_id': categoryId,
			'name': name,
			'description': description,
			'address': address,
			'store_image': storeImage,
			'rating': rating,
			'is_active': isActive,
			'created_at': createdAt ?? '',
			'updated_at': updatedAt ?? '',
		};
	}
}
