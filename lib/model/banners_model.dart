import 'package:intl/intl.dart';

class BannerModel {
	final String id;
	final String image;
	final String type;
	final String link;
	final String title;
	final String alt;
	final String status;
	final String? createdAt;
	final String? updatedAt;

	BannerModel({
		required this.id,
		required this.image,
		required this.type,
		required this.link,
		required this.title,
		required this.alt,
		required this.status,
		this.createdAt,
		this.updatedAt,
	});

	factory BannerModel.create({
		required String id,
		required String image,
		required String type,
		required String link,
		required String title,
		required String alt,
		required String status,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return BannerModel(
			id: id,
			image: image,
			type: type,
			link: link,
			title: title,
			alt: alt,
			status: status,
			createdAt: now,
			updatedAt: now,
		);
	}

	BannerModel copyWith({
		String? id,
		String? image,
		String? type,
		String? link,
		String? title,
		String? alt,
		String? status,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return BannerModel(
			id: id ?? this.id,
			image: image ?? this.image,
			type: type ?? this.type,
			link: link ?? this.link,
			title: title ?? this.title,
			alt: alt ?? this.alt,
			status: status ?? this.status,
			createdAt: this.createdAt,
			updatedAt: now,
		);
	}

	factory BannerModel.fromJson(Map<String, dynamic> json) {
		return BannerModel(
			id: json['id'].toString(),
			image: json['image'],
			type: json['type'],
			link: json['link'],
			title: json['title'],
			alt: json['alt'],
			status: json['status'].toString(),
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'image': image,
			'type': type,
			'link': link,
			'title': title,
			'alt': alt,
			'status': status,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}

	Map<String, String> toJsonForRequest() {
		return {
			'id': id,
			'image': image,
			'type': type,
			'link': link,
			'title': title,
			'alt': alt,
			'status': status,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}
}
