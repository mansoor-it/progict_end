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
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: ExpansionTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: items.map(itemBuilder).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('لوحة تحكم المدير')),
      body: ListView(
        children: [
          buildSection<User>('المستخدمين', users, (user) => ListTile(
            title: Text(user.name),
            subtitle: Text('البريد: ${user.email} | الحالة: ${user.status}'),
          )),
          buildSection<Order>('الطلبات', orders, (order) => ListTile(
            title: Text('طلب رقم #${order.id}'),
            subtitle: Text(
              'المستخدم: ${order.userId} | السعر: ${order.totalPrice} ر.س | الحالة: ${order.status}',
            ),
          )),
          buildSection<Payment>('المدفوعات', payments, (payment) => ListTile(
            title: Text('دفع رقم #${payment.id}'),
            subtitle: Text(
              'طلب: ${payment.orderId} | المبلغ: ${payment.amount} ر.س | الطريقة: ${payment.paymentMethod} | الحالة: ${payment.status}',
            ),
          )),
        ],
      ),
    );
  }
}
