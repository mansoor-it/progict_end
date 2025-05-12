import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/admin_model.dart';
import '../service/admin_server.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> with TickerProviderStateMixin {
  bool _isLoading = false;
  List<Admin> _admins = [];
  List<Admin> _filteredAdmins = [];
  String searchQuery = '';
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  @override
  void initState() {
    super.initState();
    _fetchAdmins();
  }

  // جلب بيانات الإداريين وتحديث القائمة
  Future<void> _fetchAdmins() async {
    setState(() {
      _isLoading = true;
    });
    try {
      List<Admin> admins = await AdminService.getAllAdmins();
      setState(() {
        _admins = admins;
        _applyFilter();
      });
    } catch (e, stackTrace) {
      print('Error fetching admins: $e');
      print('StackTrace: $stackTrace');
      if (kDebugMode) {
        debugPrint('Error fetching admins: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('خطأ في جلب البيانات: $e'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // تطبيق الفلترة بناءً على استعلام البحث
  void _applyFilter() {
    setState(() {
      if (searchQuery.isEmpty) {
        _filteredAdmins = List.from(_admins);
      } else {
        _filteredAdmins = _admins.where((admin) =>
            admin.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
      }
    });
  }

  // دالة لفك تشفير صورة Base64 مع معالجة البادئات والتوسيع
  Uint8List? decodeBase64Image(String base64Str) {
    if (base64Str.isEmpty) return null;
    try {
      if (base64Str.contains(',')) {
        base64Str = base64Str.split(',').last;
      }
      int remainder = base64Str.length % 4;
      if (remainder != 0) {
        base64Str = base64Str.padRight(base64Str.length + (4 - remainder), '=');
      }
      return base64Decode(base64Str);
    } catch (e, stackTrace) {
      print('Base64 decode error: $e');
      print('StackTrace: $stackTrace');
      if (kDebugMode) {
        debugPrint('Base64 decode error: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      return null;
    }
  }

  // دالة اختيار صورة من المعرض وتحويلها إلى Base64
  Future<String?> _pickImage() async {
    try {
      final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage == null) return null;
      File imageFile = File(pickedImage.path);
      Uint8List imageBytes = await imageFile.readAsBytes();
      return base64.encode(imageBytes);
    } on PlatformException catch (e, stackTrace) {
      print('Error picking image: $e');
      print('StackTrace: $stackTrace');
      if (kDebugMode) {
        debugPrint('Error picking image: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('خطأ في اختيار الصورة: $e'),
        ),
      );
      return null;
    }
  }

  // عرض مربع حوار لإضافة أو تحديث بيانات المدير
  void _showAdminDialog({Admin? admin}) {
    final parentContext = context;

    TextEditingController nameController =
    TextEditingController(text: admin?.name ?? '');
    TextEditingController typeController =
    TextEditingController(text: admin?.type ?? '');
    TextEditingController vendorIdController =
    TextEditingController(text: admin?.vendorId ?? '');
    TextEditingController mobileController =
    TextEditingController(text: admin?.mobile ?? '');
    TextEditingController emailController =
    TextEditingController(text: admin?.email ?? '');
    TextEditingController passwordController =
    TextEditingController(text: admin?.password ?? '');
    String confirmValue = admin?.confirm ?? 'No';
    TextEditingController statusController =
    TextEditingController(text: admin?.status ?? '0');
    String imageBase64 = admin?.image ?? '';

    showDialog(
      context: parentContext,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text(
                admin == null ? 'إضافة مدير جديد' : 'تحديث بيانات المدير',
                style: const TextStyle(color: Colors.blueAccent),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        String? picked = await _pickImage();
                        if (picked != null) {
                          setStateDialog(() {
                            imageBase64 = picked;
                          });
                        }
                      },
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: imageBase64.isNotEmpty
                            ? Builder(builder: (context) {
                          Uint8List? decoded = decodeBase64Image(imageBase64);
                          if (decoded != null) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                decoded,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 50),
                              ),
                            );
                          } else {
                            return const Icon(Icons.broken_image, size: 50);
                          }
                        })
                            : const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: 'الاسم', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: typeController,
                        decoration: const InputDecoration(
                            labelText: 'النوع', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: vendorIdController,
                        decoration: const InputDecoration(
                            labelText: 'Vendor ID', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number),
                    const SizedBox(height: 10),
                    TextField(
                        controller: mobileController,
                        decoration: const InputDecoration(
                            labelText: 'الجوال', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: 'البريد الإلكتروني', border: OutlineInputBorder()),
                        keyboardType: TextInputType.emailAddress),
                    const SizedBox(height: 10),
                    TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                            labelText: 'كلمة المرور', border: OutlineInputBorder()),
                        obscureText: true),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<String>(
                      value: confirmValue,
                      items: const [
                        DropdownMenuItem(value: 'Yes', child: Text('Yes')),
                        DropdownMenuItem(value: 'No', child: Text('No')),
                      ],
                      onChanged: (value) => setStateDialog(() {
                        confirmValue = value ?? 'No';
                      }),
                      decoration: const InputDecoration(
                          labelText: 'تأكيد الحساب', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                        controller: statusController,
                        decoration: const InputDecoration(
                            labelText: 'الحالة (0/1)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    child: const Text('إلغاء', style: TextStyle(color: Colors.red)),
                    onPressed: () => Navigator.pop(context)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                  child: const Text('حفظ'),
                  onPressed: () async {
                    Navigator.pop(context);
                    Admin newAdmin = Admin(
                      id: admin?.id ?? '0',
                      name: nameController.text,
                      type: typeController.text,
                      vendorId: vendorIdController.text,
                      mobile: mobileController.text,
                      email: emailController.text,
                      password: passwordController.text,
                      image: imageBase64,
                      confirm: confirmValue,
                      status: statusController.text,
                      emailVerifiedAt: admin?.emailVerifiedAt,
                      rememberToken: admin?.rememberToken,
                      accessToken: admin?.accessToken,
                      createdAt: admin?.createdAt,
                      updatedAt: admin?.updatedAt,
                    );
                    setState(() {
                      _isLoading = true;
                    });
                    try {
                      String result = admin == null
                          ? await AdminService.addAdmin(newAdmin)
                          : await AdminService.updateAdmin(newAdmin);
                      if (result.toLowerCase().contains("success")) {
                        await _fetchAdmins();
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(admin == null
                                ? 'تم إضافة المدير'
                                : 'تم تحديث بيانات المدير'),
                          ),
                        );
                      } else {
                        print('Error saving admin, result: $result');
                        print('StackTrace: (No stack trace available for non-exception result)');
                        if (kDebugMode) {
                          debugPrint('Error saving admin, result: $result');
                        }
                        ScaffoldMessenger.of(parentContext).showSnackBar(
                          SnackBar(
                            backgroundColor: Colors.red,
                            content: Text('خطأ: $result'),
                          ),
                        );
                      }
                    } catch (e, stackTrace) {
                      print('Exception while saving admin: $e');
                      print('StackTrace: $stackTrace');
                      if (kDebugMode) {
                        debugPrint('Exception while saving admin: $e');
                        debugPrint('StackTrace: $stackTrace');
                      }
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(
                          backgroundColor: Colors.red,
                          content: Text('حدث خطأ أثناء الحفظ: $e'),
                        ),
                      );
                    }
                    setState(() {
                      _isLoading = false;
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // دالة حذف المدير
  Future<void> _deleteAdmin(String id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      String result = await AdminService.deleteAdmin(id);
      if (result.toLowerCase().contains("success")) {
        await _fetchAdmins();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text('تم حذف المدير'),
          ),
        );
      } else {
        print('Error deleting admin, result: $result');
        if (kDebugMode) {
          debugPrint('Error deleting admin, result: $result');
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text('خطأ: $result'),
          ),
        );
      }
    } catch (e, stackTrace) {
      print('Error deleting admin: $e');
      print('StackTrace: $stackTrace');
      if (kDebugMode) {
        debugPrint('Error deleting admin: $e');
        debugPrint('StackTrace: $stackTrace');
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text('حدث خطأ أثناء الحذف: $e'),
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  // بناء واجهة المستخدم مع قائمة البحث والإداريين
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("إدارة الإداريين"),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: CircularProgressIndicator(color: Colors.white),
            )
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                searchQuery = value;
                _applyFilter();
              },
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم ...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        onPressed: _showAdminDialog,
        child: const Icon(Icons.add),
      ),
      body: _isLoading && _admins.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _filteredAdmins.isEmpty
          ? const Center(child: Text('لا توجد بيانات للإداريين حتى الآن'))
          : AnimatedList(
        key: _listKey,
        initialItemCount: _filteredAdmins.length,
        itemBuilder: (context, index, animation) {
          Admin admin = _filteredAdmins[index];
          return FadeTransition(
            opacity: animation,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Builder(builder: (context) {
                    if (admin.image.isNotEmpty) {
                      Uint8List? decoded = decodeBase64Image(admin.image);
                      return decoded != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          decoded,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                        ),
                      )
                          : const Icon(Icons.broken_image);
                    } else {
                      return const Icon(Icons.person);
                    }
                  }),
                ),
                title: Text(
                  admin.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${admin.email}'),
                    Text('Mobile: ${admin.mobile}'),
                  ],
                ),
                trailing: Wrap(
                  spacing: 5,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () => _showAdminDialog(admin: admin),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.redAccent),
                      onPressed: () => _deleteAdmin(admin.id),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
