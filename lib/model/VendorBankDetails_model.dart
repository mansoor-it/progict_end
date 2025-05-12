import 'package:intl/intl.dart';

class VendorBankDetails {
	final String id;
	final String vendorId;
	final String accountHolderName;
	final String bankName;
	final String accountNumber;
	final String bankIfscCode;
	final String? createdAt;
	final String? updatedAt;

	VendorBankDetails({
		required this.id,
		required this.vendorId,
		required this.accountHolderName,
		required this.bankName,
		required this.accountNumber,
		required this.bankIfscCode,
		this.createdAt,
		this.updatedAt,
	});

	factory VendorBankDetails.create({
		required String id,
		required String vendorId,
		required String accountHolderName,
		required String bankName,
		required String accountNumber,
		required String bankIfscCode,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return VendorBankDetails(
			id: id,
			vendorId: vendorId,
			accountHolderName: accountHolderName,
			bankName: bankName,
			accountNumber: accountNumber,
			bankIfscCode: bankIfscCode,
			createdAt: now,
			updatedAt: now,
		);
	}

	VendorBankDetails copyWith({
		String? id,
		String? vendorId,
		String? accountHolderName,
		String? bankName,
		String? accountNumber,
		String? bankIfscCode,
		String? createdAt,
		String? updatedAt,
	}) {
		String now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
		return VendorBankDetails(
			id: id ?? this.id,
			vendorId: vendorId ?? this.vendorId,
			accountHolderName: accountHolderName ?? this.accountHolderName,
			bankName: bankName ?? this.bankName,
			accountNumber: accountNumber ?? this.accountNumber,
			bankIfscCode: bankIfscCode ?? this.bankIfscCode,
			createdAt: createdAt ?? this.createdAt,
			updatedAt: updatedAt ?? now,
		);
	}

	factory VendorBankDetails.fromJson(Map<String, dynamic> json) {
		return VendorBankDetails(
			id: json['id'].toString(),
			vendorId: json['vendor_id'].toString(),
			accountHolderName: json['account_holder_name'],
			bankName: json['bank_name'],
			accountNumber: json['account_number'],
			bankIfscCode: json['bank_ifsc_code'],
			createdAt: json['created_at'],
			updatedAt: json['updated_at'],
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'vendor_id': vendorId,
			'account_holder_name': accountHolderName,
			'bank_name': bankName,
			'account_number': accountNumber,
			'bank_ifsc_code': bankIfscCode,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}

	/// تستخدم هذه الدالة عند الإرسال إلى API (http.post) حيث يجب أن تكون القيم كلها من نوع String
	Map<String, String> toJsonForRequest() {
		return {
			'id': id,
			'vendor_id': vendorId,
			'account_holder_name': accountHolderName,
			'bank_name': bankName,
			'account_number': accountNumber,
			'bank_ifsc_code': bankIfscCode,
			'created_at': createdAt ?? "",
			'updated_at': updatedAt ?? "",
		};
	}
}
