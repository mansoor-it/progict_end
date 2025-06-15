import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../ApiConfig.dart';

// تعريف كلاس الدفعة بناءً على جدول payments
class Payment {
	final String id;
	final String orderId;
	final String userId;
	final String amount;
	final String paymentMethod;
	final String status;
	final String createdAt;

	Payment({
		required this.id,
		required this.orderId,
		required this.userId,
		required this.amount,
		required this.paymentMethod,
		required this.status,
		required this.createdAt,
	});

	factory Payment.fromJson(Map<String, dynamic> json) {
		return Payment(
			id: json['id']?.toString() ?? '',
			orderId: json['order_id']?.toString() ?? '',
			userId: json['user_id']?.toString() ?? '',
			amount: json['amount']?.toString() ?? '',
			paymentMethod: json['payment_method'] ?? '',
			status: json['status'] ?? '',
			createdAt: json['created_at'] ?? '',
		);
	}
}

// كلاس للإحصائيات
class DashboardStats {
	final int totalPayments;
	final double totalAmount;
	final double averagePayment;
	final int uniqueUsers;
	final int uniqueOrders;
	final int successfulPayments;
	final int pendingPayments;
	final int failedPayments;
	final int refundedPayments;
	final String mostUsedPaymentMethod;
	final double largestPayment;
	final double smallestPayment;

	DashboardStats({
		required this.totalPayments,
		required this.totalAmount,
		required this.averagePayment,
		required this.uniqueUsers,
		required this.uniqueOrders,
		required this.successfulPayments,
		required this.pendingPayments,
		required this.failedPayments,
		required this.refundedPayments,
		required this.mostUsedPaymentMethod,
		required this.largestPayment,
		required this.smallestPayment,
	});
}

class PaymentsManagementPage extends StatefulWidget {
	@override
	_PaymentsManagementPageState createState() => _PaymentsManagementPageState();
}

class _PaymentsManagementPageState extends State<PaymentsManagementPage>
		with TickerProviderStateMixin {
	List<Payment> _payments = [];
	List<Payment> _filteredPayments = [];
	bool _isLoading = false;
	DashboardStats? _stats;

	// Controllers للنموذج
	final TextEditingController _orderIdController = TextEditingController();
	final TextEditingController _userIdController = TextEditingController();
	final TextEditingController _amountController = TextEditingController();
	final TextEditingController _paymentMethodController = TextEditingController();
	final TextEditingController _statusController = TextEditingController();

	// Controllers للفلترة والبحث
	final TextEditingController _searchController = TextEditingController();
	final TextEditingController _orderIdFilterController = TextEditingController();
	final TextEditingController _userIdFilterController = TextEditingController();
	final TextEditingController _minAmountController = TextEditingController();
	final TextEditingController _maxAmountController = TextEditingController();
	String _selectedStatusFilter = 'الكل';
	String _selectedPaymentMethodFilter = 'الكل';
	String _sortBy = 'id';
	bool _sortAscending = true;

	final List<String> _validPaymentMethods = [
		'credit_card',
		'debit_card',
		'paypal',
		'bank_transfer',
		'cash',
		'cash_on_delivery',
		'wallet',
	];

	// Animation Controllers
	AnimationController? _fadeController;
	AnimationController? _slideController;
	Animation<double>? _fadeAnimation;
	Animation<Offset>? _slideAnimation;

	// رابط API الخاص بالدفعات
	final String apiUrl = ApiHelper.url('payments_api.php');

	@override
	void initState() {
		super.initState();

		_fadeController = AnimationController(
			duration: Duration(milliseconds: 800),
			vsync: this,
		);
		_slideController = AnimationController(
			duration: Duration(milliseconds: 600),
			vsync: this,
		);

		_fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
			CurvedAnimation(parent: _fadeController!, curve: Curves.easeInOut),
		);

		_slideAnimation = Tween<Offset>(
			begin: Offset(0, 0.3),
			end: Offset.zero,
		).animate(CurvedAnimation(parent: _slideController!, curve: Curves.easeOutCubic));

		_fadeController!.forward();
		_slideController!.forward();

		_fetchPayments();
		_searchController.addListener(_filterPayments);
		_orderIdFilterController.addListener(_filterPayments);
		_userIdFilterController.addListener(_filterPayments);
		_minAmountController.addListener(_filterPayments);
		_maxAmountController.addListener(_filterPayments);
	}

	Future<void> _fetchPayments() async {
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.get(Uri.parse("$apiUrl?action=fetch"));
			if (response.statusCode == 200) {
				final List<dynamic> data = json.decode(response.body);
				setState(() {
					_payments = data.map((item) => Payment.fromJson(item)).toList();
					_filteredPayments = List.from(_payments);
					_stats = _calculateStats();
					_isLoading = false;
				});
				_filterPayments();
			} else {
				setState(() {
					_isLoading = false;
				});
				_showSnackBar("خطأ في جلب البيانات", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	DashboardStats _calculateStats() {
		if (_payments.isEmpty) {
			return DashboardStats(
				totalPayments: 0,
				totalAmount: 0.0,
				averagePayment: 0.0,
				uniqueUsers: 0,
				uniqueOrders: 0,
				successfulPayments: 0,
				pendingPayments: 0,
				failedPayments: 0,
				refundedPayments: 0,
				mostUsedPaymentMethod: 'غير متوفر',
				largestPayment: 0.0,
				smallestPayment: 0.0,
			);
		}

		double totalAmount = _payments.fold(0.0, (sum, payment) => sum + double.parse(payment.amount));
		double averagePayment = totalAmount / _payments.length;
		Set<String> uniqueUsers = _payments.map((payment) => payment.userId).toSet();
		Set<String> uniqueOrders = _payments.map((payment) => payment.orderId).toSet();

		// حساب الدفعات حسب الحالة
		int successfulPayments = _payments.where((payment) => payment.status.toLowerCase() == 'completed' || payment.status.toLowerCase() == 'success').length;
		int pendingPayments = _payments.where((payment) => payment.status.toLowerCase() == 'pending').length;
		int failedPayments = _payments.where((payment) => payment.status.toLowerCase() == 'failed' || payment.status.toLowerCase() == 'cancelled').length;
		int refundedPayments = _payments.where((payment) => payment.status.toLowerCase() == 'refunded').length;

		// حساب طريقة الدفع الأكثر استخداماً
		Map<String, int> paymentMethodCount = {};
		for (var payment in _payments) {
			paymentMethodCount[payment.paymentMethod] = (paymentMethodCount[payment.paymentMethod] ?? 0) + 1;
		}
		String mostUsedPaymentMethod = paymentMethodCount.entries.isNotEmpty
				? paymentMethodCount.entries
				.reduce((a, b) => a.value > b.value ? a : b)
				.key
				: 'غير متوفر';

		// حساب أكبر وأصغر دفعة
		var sortedByAmount = List<Payment>.from(_payments);
		sortedByAmount.sort((a, b) => double.parse(a.amount).compareTo(double.parse(b.amount)));
		double smallestPayment = sortedByAmount.isNotEmpty ? double.parse(sortedByAmount.first.amount) : 0.0;
		double largestPayment = sortedByAmount.isNotEmpty ? double.parse(sortedByAmount.last.amount) : 0.0;

		return DashboardStats(
			totalPayments: _payments.length,
			totalAmount: totalAmount,
			averagePayment: averagePayment,
			uniqueUsers: uniqueUsers.length,
			uniqueOrders: uniqueOrders.length,
			successfulPayments: successfulPayments,
			pendingPayments: pendingPayments,
			failedPayments: failedPayments,
			refundedPayments: refundedPayments,
			mostUsedPaymentMethod: mostUsedPaymentMethod,
			largestPayment: largestPayment,
			smallestPayment: smallestPayment,
		);
	}

	void _filterPayments() {
		setState(() {
			_filteredPayments = _payments.where((payment) {
				bool matchesSearch = _searchController.text.isEmpty ||
						payment.id.contains(_searchController.text) ||
						payment.orderId.contains(_searchController.text) ||
						payment.userId.contains(_searchController.text) ||
						payment.paymentMethod.toLowerCase().contains(_searchController.text.toLowerCase());

				bool matchesOrderId = _orderIdFilterController.text.isEmpty ||
						payment.orderId.contains(_orderIdFilterController.text);

				bool matchesUserId = _userIdFilterController.text.isEmpty ||
						payment.userId.contains(_userIdFilterController.text);

				bool matchesStatus = _selectedStatusFilter == 'الكل' ||
						payment.status.toLowerCase() == _selectedStatusFilter.toLowerCase();

				bool matchesPaymentMethod = _selectedPaymentMethodFilter == 'الكل' ||
						payment.paymentMethod == _selectedPaymentMethodFilter;

				bool matchesAmount = true;
				if (_minAmountController.text.isNotEmpty) {
					try {
						double minAmount = double.parse(_minAmountController.text);
						matchesAmount = matchesAmount && double.parse(payment.amount) >= minAmount;
					} catch (_) {}
				}
				if (_maxAmountController.text.isNotEmpty) {
					try {
						double maxAmount = double.parse(_maxAmountController.text);
						matchesAmount = matchesAmount && double.parse(payment.amount) <= maxAmount;
					} catch (_) {}
				}

				return matchesSearch && matchesOrderId && matchesUserId && matchesStatus && matchesPaymentMethod && matchesAmount;
			}).toList();

			_sortPayments();
		});
	}

	void _sortPayments() {
		_filteredPayments.sort((a, b) {
			int comparison = 0;
			switch (_sortBy) {
				case 'id':
					comparison = int.parse(a.id).compareTo(int.parse(b.id));
					break;
				case 'orderId':
					comparison = int.parse(a.orderId).compareTo(int.parse(b.orderId));
					break;
				case 'userId':
					comparison = int.parse(a.userId).compareTo(int.parse(b.userId));
					break;
				case 'amount':
					comparison = double.parse(a.amount).compareTo(double.parse(b.amount));
					break;
				case 'paymentMethod':
					comparison = a.paymentMethod.compareTo(b.paymentMethod);
					break;
				case 'status':
					comparison = a.status.compareTo(b.status);
					break;
				case 'createdAt':
					comparison = a.createdAt.compareTo(b.createdAt);
					break;
			}
			return _sortAscending ? comparison : -comparison;
		});
	}

	Future<void> _addPayment() async {
		final Map<String, String> data = {
			"action": "add",
			"order_id": _orderIdController.text.trim(),
			"user_id": _userIdController.text.trim(),
			"amount": _amountController.text.trim(),
			"payment_method": _paymentMethodController.text.trim(),
			"status": _statusController.text.trim().isEmpty ? 'pending' : _statusController.text.trim(),
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم إضافة الدفعة بنجاح", Colors.green);
				_fetchPayments();
			} else {
				_showSnackBar("فشل في إضافة الدفعة: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _updatePayment(String id) async {
		final Map<String, String> data = {
			"action": "update",
			"id": id,
			"order_id": _orderIdController.text.trim(),
			"user_id": _userIdController.text.trim(),
			"amount": _amountController.text.trim(),
			"payment_method": _paymentMethodController.text.trim(),
			"status": _statusController.text.trim().isEmpty ? 'pending' : _statusController.text.trim(),
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم تحديث الدفعة بنجاح", Colors.green);
				_fetchPayments();
			} else {
				_showSnackBar("فشل في تحديث الدفعة: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	Future<void> _deletePayment(String id) async {
		final Map<String, String> data = {
			"action": "delete",
			"id": id,
		};
		setState(() {
			_isLoading = true;
		});
		try {
			final response = await http.post(Uri.parse(apiUrl), body: data);
			final responseBody = json.decode(response.body);
			setState(() {
				_isLoading = false;
			});
			if (responseBody['message'].toString().toLowerCase().contains('successfully')) {
				_showSnackBar("تم حذف الدفعة بنجاح", Colors.green);
				_fetchPayments();
			} else {
				_showSnackBar("فشل في حذف الدفعة: ${responseBody['message']}", Colors.red);
			}
		} catch (e) {
			setState(() {
				_isLoading = false;
			});
			_showSnackBar("استثناء: $e", Colors.red);
		}
	}

	void _showSnackBar(String message, Color color) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(
				content: Text(message),
				backgroundColor: color,
				behavior: SnackBarBehavior.floating,
				shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
			),
		);
	}

	void _showAddEditDialog({Payment? paymentObj}) {
		if (paymentObj != null) {
			_orderIdController.text = paymentObj.orderId;
			_userIdController.text = paymentObj.userId;
			_amountController.text = paymentObj.amount;
			_paymentMethodController.text = paymentObj.paymentMethod;
			_statusController.text = paymentObj.status;
		} else {
			_orderIdController.clear();
			_userIdController.clear();
			_amountController.clear();
			_paymentMethodController.clear();
			_statusController.clear();
		}

		showDialog(
			context: context,
			builder: (context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
					title: Container(
						padding: EdgeInsets.all(16),
						decoration: BoxDecoration(
							gradient: LinearGradient(
								colors: [Colors.indigo.shade600, Colors.indigo.shade800],
								begin: Alignment.topLeft,
								end: Alignment.bottomRight,
							),
							borderRadius: BorderRadius.circular(15),
						),
						child: Text(
							paymentObj == null ? "إضافة دفعة جديدة" : "تعديل الدفعة",
							style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
						),
					),
					content: Container(
						width: double.maxFinite,
						child: SingleChildScrollView(
							child: Column(
								mainAxisSize: MainAxisSize.min,
								children: [
									_buildDialogTextField(_orderIdController, "رقم الطلب", Icons.receipt, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_userIdController, "رقم المستخدم", Icons.person, TextInputType.number),
									SizedBox(height: 16),
									_buildDialogTextField(_amountController, "المبلغ", Icons.attach_money, TextInputType.number),
									SizedBox(height: 16),
									Container(
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: Colors.grey.shade300),
										),
										child: DropdownButtonFormField<String>(
											value: _validPaymentMethods.contains(_paymentMethodController.text) && _paymentMethodController.text.isNotEmpty ? _paymentMethodController.text : 'credit_card',
											decoration: InputDecoration(
												labelText: "طريقة الدفع",
												prefixIcon: Icon(Icons.payment, color: Colors.indigo.shade600),
												border: InputBorder.none,
												contentPadding: EdgeInsets.all(16),
											),
											items: [
												DropdownMenuItem(value: 'credit_card', child: Text('بطاقة ائتمان')),
												DropdownMenuItem(value: 'debit_card', child: Text('بطاقة خصم')),
												DropdownMenuItem(value: 'paypal', child: Text('PayPal')),
												DropdownMenuItem(value: 'bank_transfer', child: Text('تحويل بنكي')),
												DropdownMenuItem(value: 'cash', child: Text('نقداً')),
												DropdownMenuItem(value: 'cash_on_delivery', child: Text('الدفع عند الاستلام')),
												DropdownMenuItem(value: 'wallet', child: Text('محفظة إلكترونية')),
											],
											onChanged: (value) {
												_paymentMethodController.text = value!;
											},
										),
									),
									SizedBox(height: 16),
									Container(
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(12),
											border: Border.all(color: Colors.grey.shade300),
										),
										child: DropdownButtonFormField<String>(
											value: _statusController.text.isEmpty ? 'pending' : _statusController.text,
											decoration: InputDecoration(
												labelText: "حالة الدفعة",
												prefixIcon: Icon(Icons.info, color: Colors.indigo.shade600),
												border: InputBorder.none,
												contentPadding: EdgeInsets.all(16),
											),
											items: [
												DropdownMenuItem(value: 'pending', child: Text('قيد الانتظار')),
												DropdownMenuItem(value: 'completed', child: Text('مكتملة')),
												DropdownMenuItem(value: 'success', child: Text('نجحت')),
												DropdownMenuItem(value: 'failed', child: Text('فشلت')),
												DropdownMenuItem(value: 'cancelled', child: Text('ملغية')),
												DropdownMenuItem(value: 'refunded', child: Text('مستردة')),
											],
											onChanged: (value) {
												_statusController.text = value!;
											},
										),
									),
								],
							),
						),
					),
					actions: [
						TextButton(
							onPressed: () => Navigator.of(context).pop(),
							child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
						),
						ElevatedButton(
							onPressed: () {
								if (paymentObj == null) {
									_addPayment();
								} else {
									_updatePayment(paymentObj.id);
								}
								Navigator.of(context).pop();
							},
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.indigo.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text(
								paymentObj == null ? "إضافة" : "تحديث",
								style: TextStyle(color: Colors.white),
							),
						),
					],
				);
			},
		);
	}

	Widget _buildDialogTextField(TextEditingController controller, String label, IconData icon, TextInputType keyboardType) {
		return Container(
			decoration: BoxDecoration(
				borderRadius: BorderRadius.circular(12),
				border: Border.all(color: Colors.grey.shade300),
			),
			child: TextField(
				controller: controller,
				decoration: InputDecoration(
					labelText: label,
					prefixIcon: Icon(icon, color: Colors.indigo.shade600),
					border: InputBorder.none,
					contentPadding: EdgeInsets.all(16),
				),
				keyboardType: keyboardType,
			),
		);
	}

	Widget _buildDashboard() {
		if (_stats == null) return SizedBox.shrink();

		// التأكد من أن الرسوم المتحركة قد تم تهيئتها قبل الاستخدام
		if (_fadeAnimation == null || _slideAnimation == null) {
			return Container(
				margin: EdgeInsets.all(16),
				padding: EdgeInsets.all(20),
				decoration: BoxDecoration(
					gradient: LinearGradient(
						colors: [Colors.indigo.shade50, Colors.indigo.shade100],
						begin: Alignment.topLeft,
						end: Alignment.bottomRight,
					),
					borderRadius: BorderRadius.circular(20),
					boxShadow: [
						BoxShadow(
							color: Colors.indigo.shade200.withOpacity(0.5),
							blurRadius: 15,
							offset: Offset(0, 5),
						),
					],
				),
				child: SingleChildScrollView(
					child: Column(
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							Row(
								children: [
									Icon(Icons.dashboard, color: Colors.indigo.shade700, size: 28),
									SizedBox(width: 12),
									Text(
										"لوحة الإحصائيات",
										style: TextStyle(
											fontSize: 24,
											fontWeight: FontWeight.bold,
											color: Colors.indigo.shade800,
										),
									),
								],
							),
							SizedBox(height: 20),
							GridView.count(
								shrinkWrap: true,
								physics: NeverScrollableScrollPhysics(),
								crossAxisCount: 2,
								childAspectRatio: 1.5,
								crossAxisSpacing: 16,
								mainAxisSpacing: 16,
								children: [
									_buildStatCard("إجمالي الدفعات", _stats!.totalPayments.toString(), Icons.payment, Colors.green),
									_buildStatCard("إجمالي المبلغ", "${_stats!.totalAmount.toStringAsFixed(2)} ر.س", Icons.attach_money, Colors.blue),
									_buildStatCard("متوسط الدفعة", "${_stats!.averagePayment.toStringAsFixed(2)} ر.س", Icons.analytics, Colors.orange),
									_buildStatCard("المستخدمين الفريدين", _stats!.uniqueUsers.toString(), Icons.people, Colors.purple),
									_buildStatCard("الطلبات الفريدة", _stats!.uniqueOrders.toString(), Icons.receipt_long, Colors.teal),
									_buildStatCard("دفعات ناجحة", _stats!.successfulPayments.toString(), Icons.check_circle, Colors.green),
									_buildStatCard("دفعات معلقة", _stats!.pendingPayments.toString(), Icons.pending, Colors.amber),
									_buildStatCard("دفعات فاشلة", _stats!.failedPayments.toString(), Icons.error, Colors.red),
									_buildStatCard("دفعات مستردة", _stats!.refundedPayments.toString(), Icons.undo, Colors.grey),
									_buildStatCard("طريقة الدفع الأكثر استخداماً", _stats!.mostUsedPaymentMethod, Icons.trending_up, Colors.indigo),
									_buildStatCard("أكبر دفعة", "${_stats!.largestPayment.toStringAsFixed(2)} ر.س", Icons.arrow_upward, Colors.cyan),
									_buildStatCard("أصغر دفعة", "${_stats!.smallestPayment.toStringAsFixed(2)} ر.س", Icons.arrow_downward, Colors.pink),
								],
							),
						],
					),
				),
			);
		}

		return FadeTransition(
			opacity: _fadeAnimation!,
			child: SlideTransition(
				position: _slideAnimation!,
				child: Container(
					margin: EdgeInsets.all(16),
					padding: EdgeInsets.all(20),
					decoration: BoxDecoration(
						gradient: LinearGradient(
							colors: [Colors.indigo.shade50, Colors.indigo.shade100],
							begin: Alignment.topLeft,
							end: Alignment.bottomRight,
						),
						borderRadius: BorderRadius.circular(20),
						boxShadow: [
							BoxShadow(
								color: Colors.indigo.shade200.withOpacity(0.5),
								blurRadius: 15,
								offset: Offset(0, 5),
							),
						],
					),
					child: SingleChildScrollView(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Row(
									children: [
										Icon(Icons.dashboard, color: Colors.indigo.shade700, size: 28),
										SizedBox(width: 12),
										Text(
											"لوحة الإحصائيات",
											style: TextStyle(
												fontSize: 24,
												fontWeight: FontWeight.bold,
												color: Colors.indigo.shade800,
											),
										),
									],
								),
								SizedBox(height: 20),
								GridView.count(
									shrinkWrap: true,
									physics: NeverScrollableScrollPhysics(),
									crossAxisCount: 2,
									childAspectRatio: 1.5,
									crossAxisSpacing: 16,
									mainAxisSpacing: 16,
									children: [
										_buildStatCard("إجمالي الدفعات", _stats!.totalPayments.toString(), Icons.payment, Colors.green),
										_buildStatCard("إجمالي المبلغ", "${_stats!.totalAmount.toStringAsFixed(2)} ر.س", Icons.attach_money, Colors.blue),
										_buildStatCard("متوسط الدفعة", "${_stats!.averagePayment.toStringAsFixed(2)} ر.س", Icons.analytics, Colors.orange),
										_buildStatCard("المستخدمين الفريدين", _stats!.uniqueUsers.toString(), Icons.people, Colors.purple),
										_buildStatCard("الطلبات الفريدة", _stats!.uniqueOrders.toString(), Icons.receipt_long, Colors.teal),
										_buildStatCard("دفعات ناجحة", _stats!.successfulPayments.toString(), Icons.check_circle, Colors.green),
										_buildStatCard("دفعات معلقة", _stats!.pendingPayments.toString(), Icons.pending, Colors.amber),
										_buildStatCard("دفعات فاشلة", _stats!.failedPayments.toString(), Icons.error, Colors.red),
										_buildStatCard("دفعات مستردة", _stats!.refundedPayments.toString(), Icons.undo, Colors.grey),
										_buildStatCard("طريقة الدفع الأكثر استخداماً", _stats!.mostUsedPaymentMethod, Icons.trending_up, Colors.indigo),
										_buildStatCard("أكبر دفعة", "${_stats!.largestPayment.toStringAsFixed(2)} ر.س", Icons.arrow_upward, Colors.cyan),
										_buildStatCard("أصغر دفعة", "${_stats!.smallestPayment.toStringAsFixed(2)} ر.س", Icons.arrow_downward, Colors.pink),
									],
								),
							],
						),
					),
				),
			),
		);
	}

	Widget _buildStatCard(String title, String value, IconData icon, Color color) {
		return Container(
			padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: color.withOpacity(0.2),
						blurRadius: 8,
						offset: Offset(0, 3),
					),
				],
			),
			child: Column(
				mainAxisSize: MainAxisSize.min,
				mainAxisAlignment: MainAxisAlignment.center,
				children: [
					Icon(icon, color: color, size: 26),
					SizedBox(height: 6),
					Text(
						value,
						style: TextStyle(
							fontSize: 16,
							fontWeight: FontWeight.bold,
							color: color,
						),
						textAlign: TextAlign.center,
					),
					SizedBox(height: 2),
					Text(
						title,
						textAlign: TextAlign.center,
						style: TextStyle(
							fontSize: 10,
							color: Colors.grey.shade600,
						),
					),
				],
			),
		);
	}

	Widget _buildFilterSection() {
		return Container(
			margin: EdgeInsets.symmetric(horizontal: 16),
			padding: EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.shade200,
						blurRadius: 10,
						offset: Offset(0, 3),
					),
				],
			),
			child: Column(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Row(
						children: [
							Icon(Icons.filter_list, color: Colors.indigo.shade600),
							SizedBox(width: 8),
							Text(
								"البحث والفلترة",
								style: TextStyle(
									fontSize: 18,
									fontWeight: FontWeight.bold,
									color: Colors.indigo.shade800,
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: TextField(
									controller: _searchController,
									decoration: InputDecoration(
										hintText: "البحث في الدفعات...",
										prefixIcon: Icon(Icons.search),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _orderIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة برقم الطلب...",
										prefixIcon: Icon(Icons.receipt),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: TextField(
									controller: _userIdFilterController,
									decoration: InputDecoration(
										hintText: "فلترة برقم المستخدم...",
										prefixIcon: Icon(Icons.person),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: TextField(
									controller: _minAmountController,
									decoration: InputDecoration(
										hintText: "أقل مبلغ...",
										prefixIcon: Icon(Icons.attach_money),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									keyboardType: TextInputType.number,
								),
							),
						],
					),
					SizedBox(height: 16),
					Row(
						children: [
							Expanded(
								child: TextField(
									controller: _maxAmountController,
									decoration: InputDecoration(
										hintText: "أعلى مبلغ...",
										prefixIcon: Icon(Icons.attach_money),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(10),
										),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									keyboardType: TextInputType.number,
								),
							),
							SizedBox(width: 12),
							Expanded(
								child: DropdownButtonFormField<String>(
									value: _selectedStatusFilter,
									decoration: InputDecoration(
										labelText: "فلترة بالحالة",
										border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
										filled: true,
										fillColor: Colors.grey.shade50,
									),
									items: ['الكل', 'pending', 'completed', 'success', 'failed', 'cancelled', 'refunded']
											.map((status) => DropdownMenuItem(
										value: status,
										child: Text(status == 'الكل' ? 'الكل' :
										status == 'pending' ? 'قيد الانتظار' :
										status == 'completed' ? 'مكتملة' :
										status == 'success' ? 'نجحت' :
										status == 'failed' ? 'فشلت' :
										status == 'cancelled' ? 'ملغية' : 'مستردة'),
									))
											.toList(),
									onChanged: (value) {
										setState(() {
											_selectedStatusFilter = value!;
											_filterPayments();
										});
									},
								),
							),
						],
					),
					SizedBox(height: 16),
					DropdownButtonFormField<String>(
						value: _selectedPaymentMethodFilter,
						decoration: InputDecoration(
							labelText: "فلترة بطريقة الدفع",
							border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
							filled: true,
							fillColor: Colors.grey.shade50,
						),
						items: ['الكل', ...(_payments.map((p) => p.paymentMethod).toSet().toList())]
								.map((method) => DropdownMenuItem(value: method, child: Text(method)))
								.toList(),
						onChanged: (value) {
							setState(() {
								_selectedPaymentMethodFilter = value!;
								_filterPayments();
							});
						},
					),
				],
			),
		);
	}

	Widget _buildSortingSection() {
		return Container(
			margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
			padding: EdgeInsets.all(12),
			decoration: BoxDecoration(
				color: Colors.grey.shade50,
				borderRadius: BorderRadius.circular(10),
			),
			child: Row(
				children: [
					Icon(Icons.sort, color: Colors.grey.shade600),
					SizedBox(width: 8),
					Text("ترتيب حسب:", style: TextStyle(fontWeight: FontWeight.w500)),
					SizedBox(width: 12),
					Expanded(
						child: DropdownButton<String>(
							value: _sortBy,
							isExpanded: true,
							underline: SizedBox.shrink(),
							items: [
								DropdownMenuItem(value: 'id', child: Text('المعرف')),
								DropdownMenuItem(value: 'orderId', child: Text('رقم الطلب')),
								DropdownMenuItem(value: 'userId', child: Text('رقم المستخدم')),
								DropdownMenuItem(value: 'amount', child: Text('المبلغ')),
								DropdownMenuItem(value: 'paymentMethod', child: Text('طريقة الدفع')),
								DropdownMenuItem(value: 'status', child: Text('الحالة')),
								DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
							],
							onChanged: (value) {
								setState(() {
									_sortBy = value!;
									_filterPayments();
								});
							},
						),
					),
					IconButton(
						icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
						onPressed: () {
							setState(() {
								_sortAscending = !_sortAscending;
								_filterPayments();
							});
						},
					),
				],
			),
		);
	}

	Widget _buildDataTable() {
		return Container(
			margin: EdgeInsets.all(16),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.circular(15),
				boxShadow: [
					BoxShadow(
						color: Colors.grey.shade200,
						blurRadius: 10,
						offset: Offset(0, 3),
					),
				],
			),
			child: ClipRRect(
				borderRadius: BorderRadius.circular(15),
				child: SingleChildScrollView(
					scrollDirection: Axis.horizontal,
					child: Container(
						constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width - 32),
						child: DataTable(
							headingRowColor: MaterialStateProperty.all(Colors.indigo.shade50),
							headingTextStyle: TextStyle(
								fontWeight: FontWeight.bold,
								color: Colors.indigo.shade800,
							),
							dataRowHeight: 70,
							columnSpacing: 20,
							columns: [
								DataColumn(
									label: Text("المعرف"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'id';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(
									label: Text("رقم الطلب"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'orderId';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(
									label: Text("رقم المستخدم"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'userId';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(
									label: Text("المبلغ"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'amount';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(
									label: Text("طريقة الدفع"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'paymentMethod';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(
									label: Text("الحالة"),
									onSort: (columnIndex, ascending) {
										setState(() {
											_sortBy = 'status';
											_sortAscending = ascending;
											_filterPayments();
										});
									},
								),
								DataColumn(label: Text("تاريخ الإنشاء")),
								DataColumn(label: Text("الإجراءات")),
							],
							rows: _filteredPayments.map((paymentObj) {
								Color statusColor = paymentObj.status.toLowerCase() == 'completed' || paymentObj.status.toLowerCase() == 'success'
										? Colors.green
										: paymentObj.status.toLowerCase() == 'pending'
										? Colors.amber
										: paymentObj.status.toLowerCase() == 'failed' || paymentObj.status.toLowerCase() == 'cancelled'
										? Colors.red
										: Colors.grey;

								String statusText = paymentObj.status.toLowerCase() == 'completed' || paymentObj.status.toLowerCase() == 'success'
										? 'نجحت'
										: paymentObj.status.toLowerCase() == 'pending'
										? 'قيد الانتظار'
										: paymentObj.status.toLowerCase() == 'failed'
										? 'فشلت'
										: paymentObj.status.toLowerCase() == 'cancelled'
										? 'ملغية'
										: paymentObj.status.toLowerCase() == 'refunded'
										? 'مستردة'
										: paymentObj.status;

								String paymentMethodText = paymentObj.paymentMethod == 'credit_card'
										? 'بطاقة ائتمان'
										: paymentObj.paymentMethod == 'debit_card'
										? 'بطاقة خصم'
										: paymentObj.paymentMethod == 'paypal'
										? 'PayPal'
										: paymentObj.paymentMethod == 'bank_transfer'
										? 'تحويل بنكي'
										: paymentObj.paymentMethod == 'cash'
										? 'نقداً'
										: paymentObj.paymentMethod == 'wallet'
										? 'محفظة إلكترونية'
										: paymentObj.paymentMethod;

								return DataRow(
									color: MaterialStateProperty.resolveWith<Color?>(
												(Set<MaterialState> states) {
											if (states.contains(MaterialState.hovered)) {
												return Colors.indigo.shade50;
											}
											return null;
										},
									),
									cells: [
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.indigo.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													paymentObj.id,
													style: TextStyle(fontWeight: FontWeight.bold),
												),
											),
										),
										DataCell(Text(paymentObj.orderId)),
										DataCell(Text(paymentObj.userId)),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
												decoration: BoxDecoration(
													color: Colors.green.shade100,
													borderRadius: BorderRadius.circular(8),
												),
												child: Text(
													"${paymentObj.amount} ر.س",
													style: TextStyle(
														color: Colors.green.shade700,
														fontWeight: FontWeight.bold,
													),
												),
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: Colors.blue.shade100,
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													paymentMethodText,
													style: TextStyle(
														color: Colors.blue.shade700,
														fontWeight: FontWeight.w500,
													),
												),
											),
										),
										DataCell(
											Container(
												padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
												decoration: BoxDecoration(
													color: statusColor.withOpacity(0.2),
													borderRadius: BorderRadius.circular(20),
												),
												child: Text(
													statusText,
													style: TextStyle(
														color: statusColor,
														fontWeight: FontWeight.w500,
													),
												),
											),
										),
										DataCell(Text(paymentObj.createdAt)),
										DataCell(
											Row(
												mainAxisSize: MainAxisSize.min,
												children: [
													Container(
														decoration: BoxDecoration(
															color: Colors.indigo.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.edit, size: 18, color: Colors.indigo.shade600),
															tooltip: "تعديل",
															onPressed: () => _showAddEditDialog(paymentObj: paymentObj),
														),
													),
													SizedBox(width: 8),
													Container(
														decoration: BoxDecoration(
															color: Colors.red.shade50,
															borderRadius: BorderRadius.circular(8),
														),
														child: IconButton(
															icon: Icon(Icons.delete, size: 18, color: Colors.red.shade600),
															tooltip: "حذف",
															onPressed: () => _showDeleteConfirmation(paymentObj),
														),
													),
												],
											),
										),
									],
								);
							}).toList(),
						),
					),
				),
			),
		);
	}

	void _showDeleteConfirmation(Payment paymentObj) {
		showDialog(
			context: context,
			builder: (BuildContext context) {
				return AlertDialog(
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
					title: Row(
						children: [
							Icon(Icons.warning, color: Colors.red.shade600),
							SizedBox(width: 8),
							Text("تأكيد الحذف"),
						],
					),
					content: Text("هل أنت متأكد من حذف الدفعة رقم '${paymentObj.id}' للطلب ${paymentObj.orderId}؟"),
					actions: [
						TextButton(
							child: Text("إلغاء", style: TextStyle(color: Colors.grey.shade600)),
							onPressed: () => Navigator.of(context).pop(),
						),
						ElevatedButton(
							style: ElevatedButton.styleFrom(
								backgroundColor: Colors.red.shade600,
								shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
							),
							child: Text("حذف", style: TextStyle(color: Colors.white)),
							onPressed: () {
								Navigator.of(context).pop();
								_deletePayment(paymentObj.id);
							},
						),
					],
				);
			},
		);
	}

	@override
	void dispose() {
		_orderIdController.dispose();
		_userIdController.dispose();
		_amountController.dispose();
		_paymentMethodController.dispose();
		_statusController.dispose();
		_searchController.dispose();
		_orderIdFilterController.dispose();
		_userIdFilterController.dispose();
		_minAmountController.dispose();
		_maxAmountController.dispose();
		_fadeController?.dispose();
		_slideController?.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.grey.shade50,
			appBar: AppBar(
				title: Text(
					"إدارة الدفعات",
					style: TextStyle(fontWeight: FontWeight.bold),
				),
				backgroundColor: Colors.indigo.shade600,
				foregroundColor: Colors.white,
				elevation: 0,
				actions: [
					IconButton(
						icon: Icon(Icons.refresh),
						onPressed: _fetchPayments,
						tooltip: "تحديث",
					),
					IconButton(
						icon: Icon(Icons.info_outline),
						onPressed: () {
							showDialog(
								context: context,
								builder: (context) => AlertDialog(
									title: Text("معلومات التطبيق"),
									content: Text("تطبيق إدارة الدفعات مع لوحة إحصائيات وطرق فلترة متقدمة"),
									actions: [
										TextButton(
											onPressed: () => Navigator.pop(context),
											child: Text("موافق"),
										),
									],
								),
							);
						},
					),
				],
			),
			body: _isLoading
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						CircularProgressIndicator(
							valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
						),
						SizedBox(height: 16),
						Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
					],
				),
			)
					: _payments.isEmpty
					? Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(Icons.payment_outlined, size: 80, color: Colors.grey.shade400),
						SizedBox(height: 16),
						Text(
							"لا توجد دفعات متاحة",
							style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
						),
						SizedBox(height: 8),
						Text(
							"اضغط على زر الإضافة لبدء إضافة الدفعات",
							style: TextStyle(color: Colors.grey.shade500),
						),
					],
				),
			)
					: SingleChildScrollView(
				child: Column(
					crossAxisAlignment: CrossAxisAlignment.start,
					children: [
						_buildDashboard(),
						_buildFilterSection(),
						_buildSortingSection(),
						Container(
							margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
							child: Text(
								"عرض ${_filteredPayments.length} من ${_payments.length} دفعة",
								style: TextStyle(
									color: Colors.grey.shade600,
									fontWeight: FontWeight.w500,
								),
							),
						),
						_buildDataTable(),
						SizedBox(height: 80), // مساحة إضافية للـ FloatingActionButton
					],
				),
			),
			floatingActionButton: FloatingActionButton.extended(
				onPressed: () => _showAddEditDialog(),
				backgroundColor: Colors.indigo.shade600,
				foregroundColor: Colors.white,
				icon: Icon(Icons.add),
				label: Text("إضافة دفعة"),
				tooltip: "إضافة دفعة جديدة",
			),
		);
	}
}

