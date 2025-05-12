class Images {
	final String id;
	final String imageString;

	Images({
		required this.id,
		required this.imageString,
	});

	factory Images.fromJson(Map<String, dynamic> json) {
		return Images(
			id: json['id'].toString(),
			imageString: json['imageCode'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'imageCode': imageString,
		};
	}
}
