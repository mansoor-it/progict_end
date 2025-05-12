class VendorBusinessDetails {
	final String vendorId;
	final String shopName;
	final String? shopAddress;
	final String? shopCity;
	final String? shopState;
	final String? shopCountry;
	final String? shopPincode;
	final String? shopMobile;
	final String? shopWebsite;
	final String? shopEmail;
	final String? addressProof;
	final String? addressProofImage;
	final String? businessLicenseNumber;
	final String? gstNumber;
	final String? panNumber;

	VendorBusinessDetails({
		required this.vendorId,
		required this.shopName,
		this.shopAddress,
		this.shopCity,
		this.shopState,
		this.shopCountry,
		this.shopPincode,
		this.shopMobile,
		this.shopWebsite,
		this.shopEmail,
		this.addressProof,
		this.addressProofImage,
		this.businessLicenseNumber,
		this.gstNumber,
		this.panNumber,
	});

	factory VendorBusinessDetails.create({
		required String vendorId,
		required String shopName,
		String? shopAddress,
		String? shopCity,
		String? shopState,
		String? shopCountry,
		String? shopPincode,
		String? shopMobile,
		String? shopWebsite,
		String? shopEmail,
		String? addressProof,
		String? addressProofImage,
		String? businessLicenseNumber,
		String? gstNumber,
		String? panNumber,
	}) {
		return VendorBusinessDetails(
			vendorId: vendorId,
			shopName: shopName,
			shopAddress: shopAddress,
			shopCity: shopCity,
			shopState: shopState,
			shopCountry: shopCountry,
			shopPincode: shopPincode,
			shopMobile: shopMobile,
			shopWebsite: shopWebsite,
			shopEmail: shopEmail,
			addressProof: addressProof,
			addressProofImage: addressProofImage,
			businessLicenseNumber: businessLicenseNumber,
			gstNumber: gstNumber,
			panNumber: panNumber,
		);
	}

	VendorBusinessDetails copyWith({
		String? vendorId,
		String? shopName,
		String? shopAddress,
		String? shopCity,
		String? shopState,
		String? shopCountry,
		String? shopPincode,
		String? shopMobile,
		String? shopWebsite,
		String? shopEmail,
		String? addressProof,
		String? addressProofImage,
		String? businessLicenseNumber,
		String? gstNumber,
		String? panNumber,
	}) {
		return VendorBusinessDetails(
			vendorId: vendorId ?? this.vendorId,
			shopName: shopName ?? this.shopName,
			shopAddress: shopAddress ?? this.shopAddress,
			shopCity: shopCity ?? this.shopCity,
			shopState: shopState ?? this.shopState,
			shopCountry: shopCountry ?? this.shopCountry,
			shopPincode: shopPincode ?? this.shopPincode,
			shopMobile: shopMobile ?? this.shopMobile,
			shopWebsite: shopWebsite ?? this.shopWebsite,
			shopEmail: shopEmail ?? this.shopEmail,
			addressProof: addressProof ?? this.addressProof,
			addressProofImage: addressProofImage ?? this.addressProofImage,
			businessLicenseNumber: businessLicenseNumber ?? this.businessLicenseNumber,
			gstNumber: gstNumber ?? this.gstNumber,
			panNumber: panNumber ?? this.panNumber,
		);
	}

	factory VendorBusinessDetails.fromJson(Map<String, dynamic> json) {
		return VendorBusinessDetails(
			vendorId: json['vendor_id'].toString(),
			shopName: json['shop_name'] ?? '',
			shopAddress: json['shop_address'],
			shopCity: json['shop_city'],
			shopState: json['shop_state'],
			shopCountry: json['shop_country'],
			shopPincode: json['shop_pincode'],
			shopMobile: json['shop_mobile'],
			shopWebsite: json['shop_website'],
			shopEmail: json['shop_email'],
			addressProof: json['address_proof'],
			addressProofImage: json['address_proof_image'],
			businessLicenseNumber: json['business_license_number'],
			gstNumber: json['gst_number'],
			panNumber: json['pan_number'],
		);
	}

	Map<String, String> toJsonForRequest() {
		return {
			'vendor_id': vendorId,
			'shop_name': shopName,
			'shop_address': shopAddress ?? '',
			'shop_city': shopCity ?? '',
			'shop_state': shopState ?? '',
			'shop_country': shopCountry ?? '',
			'shop_pincode': shopPincode ?? '',
			'shop_mobile': shopMobile ?? '',
			'shop_website': shopWebsite ?? '',
			'shop_email': shopEmail ?? '',
			'address_proof': addressProof ?? '',
			'address_proof_image': addressProofImage ?? '',
			'business_license_number': businessLicenseNumber ?? '',
			'gst_number': gstNumber ?? '',
			'pan_number': panNumber ?? '',
		};
	}
}
