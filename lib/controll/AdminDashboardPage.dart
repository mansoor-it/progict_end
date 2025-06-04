import 'package:flutter/material.dart';
import '../model/orders_payments_model.dart';
import '../model/user_model.dart';
import '../service/orders_payments_server.dart';
import '../service/user_server.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  List<User> users = [];
  List<Order> orders = [];
  List<Payment> payments = [];

  @override
  void initState() {
    super.initState();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    users = await UserService.getAllUsers();
    orders = await OrderPaymentService.getAllOrders();
    payments = await OrderPaymentService.getAllPayments();
    setState(() {});
  }

  Widget buildSection<T>(String title, List<T> items, Widget Function(T) itemBuilder) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        collapsedBackgroundColor: const Color(0xFFEFEBE9),
        backgroundColor: const Color(0xFFEFEBE9),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF5D4037),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _getIconForSection(title),
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4E342E),
          ),
        ),
        subtitle: Text(
          '${items.length} عنصر',
          style: const TextStyle(
            color: Color(0xFF795548),
          ),
        ),
        childrenPadding: const EdgeInsets.only(bottom: 16),
        children: [
          Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ]),
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                children: items
                    .map((item) => Column(
                  children: [
                    itemBuilder(item),
                    if (items.indexOf(item) != items.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                        color: Color(0xFFEFEBE9),
                      ),
                  ],
                ))
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForSection(String title) {
    switch (title) {
      case 'المستخدمين':
        return Icons.people;
      case 'الطلبات':
        return Icons.shopping_cart;
      case 'المدفوعات':
        return Icons.payment;
      default:
        return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'لوحة تحكم المدير',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF5D4037),
        elevation: 8,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF5F5F5),
              Color(0xFFEFEBE9),
            ],
          ),
        ),
        child: ListView(
          children: [
            const SizedBox(height: 20),
            buildSection<User>('المستخدمين', users, (user) => ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              title: Text(
                user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E342E),
                ),
              ),
              subtitle: Text(
                'البريد: ${user.email} | الحالة: ${user.status}',
                style: const TextStyle(
                  color: Color(0xFF795548),
                ),
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFFD7CCC8),
                child: Text(
                  user.name.isNotEmpty ? user.name[0] : 'U',
                  style: const TextStyle(color: Color(0xFF5D4037)),
                ),
              ),
            )),
            buildSection<Order>('الطلبات', orders, (order) => ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              title: Text(
                'طلب رقم #${order.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E342E),
                ),
              ),
              subtitle: Text(
                'المستخدم: ${order.userId} | السعر: ${order.totalPrice} ر.س | الحالة: ${order.status}',
                style: const TextStyle(
                  color: Color(0xFF795548),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.status,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
              ),
            )),
            buildSection<Payment>('المدفوعات', payments, (payment) => ListTile(
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              title: Text(
                'دفع رقم #${payment.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4E342E),
                ),
              ),
              subtitle: Text(
                'طلب: ${payment.orderId} | المبلغ: ${payment.amount} ر.س | الطريقة: ${payment.paymentMethod} | الحالة: ${payment.status}',
                style: const TextStyle(
                  color: Color(0xFF795548),
                ),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.credit_card, color: Color(0xFF5D4037)),
                  const SizedBox(height: 4),
                  Text(
                    payment.paymentMethod,
                    style: const TextStyle(
                      color: Color(0xFF5D4037),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'مكتمل':
        return Colors.green;
      case 'قيد الانتظار':
        return Colors.orange;
      case 'ملغى':
        return Colors.red;
      default:
        return const Color(0xFF5D4037);
    }
  }
}