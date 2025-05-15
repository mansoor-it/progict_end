import 'dart:convert';
import 'package:flutter/foundation.dart'; // ← يجب استيراد foundation
import 'package:http/http.dart' as http;
import '../model/model_cart.dart';

const String apiBaseUrl = "http://192.168.43.129/ecommerce/add_to_cart.php";

/// الآن يرث من ChangeNotifier ليعمل مع ChangeNotifierProvider
class CartController extends ChangeNotifier {
	List<CartItemModel> _items = [];

	List<CartItemModel> get items => _items;

	/// يجلب العناصر الموجودة في سلة المستخدم
	Future<List<CartItemModel>> fetchCartItems(String userId) async {
		final uri = Uri.parse(
			"$apiBaseUrl?entity=cart_item&action=fetch&user_id=$userId",
		);
		final response = await http.get(uri);

		if (response.statusCode == 200) {
			final data = jsonDecode(response.body) as List;
			_items = data.map((item) => CartItemModel.fromJson(item)).toList();
			notifyListeners();
			return _items;
		} else {
			throw Exception("خطأ في الاتصال بالخادم: ${response.statusCode}");
		}
	}

	/// يضيف عنصر جديد إلى السلة
	Future<bool> addToCart(CartItemModel item) async {
		final uri = Uri.parse(apiBaseUrl);
		final payload = {
			'entity': 'cart_item',
			'action': 'add_to_cart',  // ← تم التعديل هنا
			...item.toJsonForRequest(),
		};

		if (kDebugMode) {
			print('>>> CartController.addToCart payload: ${jsonEncode(payload)}');
		}

		final response = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode(payload),
		);

		if (kDebugMode) {
			print('<<< Response[${response.statusCode}]: ${response.body}');
		}

		if (response.statusCode == 200) {
			try {
				final data = jsonDecode(response.body);
				if (data['success'] == true) {
					_items.add(item);
					notifyListeners();
					return true;
				}
				return false;
			} catch (e) {
				if (kDebugMode) print('Error decoding JSON: $e');
				throw Exception("استجابة غير صالحة من الخادم: $e");
			}
		} else {
			throw Exception("خطأ في الإضافة إلى السلة: ${response.statusCode}");
		}
	}

	/// يحذف عنصر من السلة بناءً على id
	Future<bool> deleteCartItem(String cartItemId) async {
		final uri = Uri.parse(apiBaseUrl);
		final payload = {
			'entity': 'cart_item',
			'action': 'delete',
			'id': cartItemId,
		};
		if (kDebugMode) {
			print('>>> CartController.deleteCartItem payload: ${jsonEncode(payload)}');
		}

		final response = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode(payload),
		);

		if (kDebugMode) {
			print('<<< Response[${response.statusCode}]: ${response.body}');
		}

		if (response.statusCode == 200) {
			final data = jsonDecode(response.body);
			if (data['success'] == true) {
				_items.removeWhere((i) => i.id == cartItemId);
				notifyListeners();
				return true;
			}
			return false;
		} else {
			throw Exception("خطأ في حذف عنصر السلة: ${response.statusCode}");
		}
	}

	/// يحدّث كمية عنصر في السلة
	Future<bool> updateCartItem(CartItemModel item) async {
		final uri = Uri.parse(apiBaseUrl);
		final payload = {
			'entity': 'cart_item',
			'action': 'update',
			...item.toJsonForRequest(),
		};
		if (kDebugMode) {
			print('>>> CartController.updateCartItem payload: ${jsonEncode(payload)}');
		}

		final response = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode(payload),
		);

		if (kDebugMode) {
			print('<<< Response[${response.statusCode}]: ${response.body}');
		}

		if (response.statusCode == 200) {
			final data = jsonDecode(response.body);
			if (data['success'] == true) {
				final index = _items.indexWhere((i) => i.id == item.id);
				if (index != -1) {
					_items[index] = item;
					notifyListeners();
				}
				return true;
			}
			return false;
		} else {
			throw Exception("خطأ في تحديث عنصر السلة: ${response.statusCode}");
		}
	}

	/// دالة لإضافة عنصر إلى السلة باستخدام تفاصيل المنتج
	/// دالة لإضافة عنصر إلى السلة باستخدام تفاصيل المنتج
	Future<bool> addCartItem({
		required String userId,
		required String productId,
		required String quantity,
		required String unitPrice,
		required String storeId, // ← تمت الإضافة هنا
	}) async {
		if (kDebugMode) {
			print('>>> CartController.addCartItem args: userId=$userId, productId=$productId, quantity=$quantity, unitPrice=$unitPrice, storeId=$storeId');
		}

		// تأكد من أن البيانات المرسلة صالحة قبل إرسالها
		if (quantity == "0" || unitPrice == "0.00") {
			throw Exception("الكمية أو السعر غير صحيح.");
		}

		final item = CartItemModel.create(
			id: DateTime.now().millisecondsSinceEpoch.toString(),
			userId: userId,
			productId: productId,
			quantity: quantity,
			unitPrice: unitPrice,
			storeId: storeId, // ← تمت الإضافة هنا
		);

		return await addToCart(item);
	}


	/// ✅ دالة لتأكيد الطلب
	Future<bool> confirmOrder(String userId, List<CartItemModel> items) async {
		final uri = Uri.parse(apiBaseUrl);
		final payload = {
			'entity': 'cart_item',
			'action': 'confirm_order',
			'user_id': userId,
			'items': items.map((item) => item.toJsonForRequest()).toList(),
		};
		if (kDebugMode) {
			print('>>> CartController.confirmOrder payload: ${jsonEncode(payload)}');
		}

		final response = await http.post(
			uri,
			headers: {'Content-Type': 'application/json'},
			body: jsonEncode(payload),
		);

		if (kDebugMode) {
			print('<<< Response[${response.statusCode}]: ${response.body}');
		}

		if (response.statusCode == 200) {
			final data = jsonDecode(response.body);
			if (data['success'] == true) {
				_items.clear();
				notifyListeners();
				return true;
			}
			return false;
		} else {
			throw Exception("فشل تأكيد الطلب: ${response.statusCode}");
		}
	}
}
