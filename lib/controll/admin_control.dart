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
  late AnimationController _loadingController;
  int _currentFooterIndex = 1; // مؤشر للعنصر النشط في الفوتر

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _fetchAdmins();
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

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
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.brown.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5D4037),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(25),
                            topRight: Radius.circular(25),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            admin == null ? 'إضافة مدير جديد' : 'تحديث بيانات المدير',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          String? picked = await _pickImage();
                          if (picked != null && mounted) {
                            setStateDialog(() {
                              imageBase64 = picked;
                            });
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFD7CCC8),
                                  borderRadius: BorderRadius.circular(60),
                                  border: Border.all(
                                    color: const Color(0xFF5D4037),
                                    width: 3,
                                  ),
                                ),
                                child: imageBase64.isNotEmpty
                                    ? Builder(builder: (context) {
                                  Uint8List? decoded = decodeBase64Image(imageBase64);
                                  return decoded != null
                                      ? ClipRRect(
                                    borderRadius: BorderRadius.circular(60),
                                    child: Image.memory(
                                      decoded,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 40, color: Colors.brown),
                                    ),
                                  )
                                      : const Icon(Icons.person, size: 40, color: Colors.brown);
                                })
                                    : const Icon(Icons.person, size: 40, color: Colors.brown),
                              ),
                              Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF5D4037),
                                  shape: BoxShape.circle,
                                  border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 2)),
                                ),
                                child: const Icon(Icons.camera_alt,
                                    size: 20,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            TextField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                labelText: 'الاسم',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: typeController,
                              decoration: const InputDecoration(
                                labelText: 'النوع',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: vendorIdController,
                              decoration: const InputDecoration(
                                labelText: 'Vendor ID',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: mobileController,
                              decoration: const InputDecoration(
                                labelText: 'الجوال',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: emailController,
                              decoration: const InputDecoration(
                                labelText: 'البريد الإلكتروني',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: passwordController,
                              decoration: const InputDecoration(
                                labelText: 'كلمة المرور',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                              obscureText: true,
                            ),
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
                                labelText: 'تأكيد الحساب',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: statusController,
                              decoration: const InputDecoration(
                                labelText: 'الحالة (0/1)',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  side: const BorderSide(color: Color(0xFF5D4037)),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
                                onPressed: () => Navigator.pop(context),
                                child: const Text('إلغاء',
                                    style: TextStyle(color: Color(0xFF5D4037))),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5D4037),
                                  padding: const EdgeInsets.symmetric(vertical: 15),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                ),
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
                                child: const Text('حفظ', style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

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

  // بناء فوتر مشابه للصورة المطلوبة
  Widget _buildFooter() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFD7CCC8),
        border: Border(top: BorderSide(color: Colors.brown.shade300, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.brown.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildFooterItem('السنة', Icons.calendar_today, index: 0),
          _buildFooterItem('المفصلة حسابي', Icons.account_balance_wallet, index: 1),
          _buildFooterItem('الرئيسية المنتجات', Icons.home, index: 2),
        ],
      ),
    );
  }

  Widget _buildFooterItem(String title, IconData icon, {required int index}) {
    bool isActive = _currentFooterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentFooterIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive ? const Color(0xFF5D4037) : Colors.brown.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: isActive ? const Color(0xFF5D4037) : Colors.brown.shade600,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primarySwatch: const MaterialColor(0xFF5D4037, {
          50: Color(0xFFEFEBE9),
          100: Color(0xFFD7CCC8),
          200: Color(0xFFBCAAA4),
          300: Color(0xFFA1887F),
          400: Color(0xFF8D6E63),
          500: Color(0xFF795548),
          600: Color(0xFF6D4C41),
          700: Color(0xFF5D4037),
          800: Color(0xFF4E342E),
          900: Color(0xFF3E2723),
        }),
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: const MaterialColor(0xFF5D4037, {
            50: Color(0xFFEFEBE9),
            100: Color(0xFFD7CCC8),
            200: Color(0xFFBCAAA4),
            300: Color(0xFFA1887F),
            400: Color(0xFF8D6E63),
            500: Color(0xFF795548),
            600: Color(0xFF6D4C41),
            700: Color(0xFF5D4037),
            800: Color(0xFF4E342E),
            900: Color(0xFF3E2723),
          }),
        ).copyWith(secondary: const Color(0xFFD7CCC8)),
        fontFamily: 'Tajawal',
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("إدارة الإداريين",
              style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Tajawal')),
          centerTitle: true,
          elevation: 8,
          backgroundColor: const Color(0xFF5D4037),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          actions: [
            if (_isLoading)
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF5D4037),
          onPressed: _showAdminDialog,
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
            side: const BorderSide(color: Colors.white, width: 2),
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFEFEBE9), Colors.white],
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(30),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _applyFilter();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'ابحث بالاسم ...',
                      hintStyle: const TextStyle(fontFamily: 'Tajawal'),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF5D4037)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: const BorderSide(color: Color(0xFF5D4037), width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: _isLoading && _admins.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(color: Color(0xFF5D4037)),
                      const SizedBox(height: 20),
                      TweenAnimationBuilder(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 500),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.scale(
                              scale: value,
                              child: const Text('جاري تحميل البيانات...',
                                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 16, fontFamily: 'Tajawal')),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                )
                    : _filteredAdmins.isEmpty
                    ? Center(
                  child: TweenAnimationBuilder(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.group_off, size: 60, color: const Color(0xFF5D4037).withOpacity(0.7)),
                              const SizedBox(height: 20),
                              const Text('لا توجد بيانات للإداريين',
                                  style: TextStyle(color: Color(0xFF5D4037), fontSize: 18, fontFamily: 'Tajawal')),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
                    : ListView.builder(
                  itemCount: _filteredAdmins.length,
                  itemBuilder: (context, index) {
                    final admin = _filteredAdmins[index];
                    return _buildAdminCard(admin);
                  },
                ),
              ),
              // إضافة الفوتر هنا
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminCard(Admin admin) {
    return GestureDetector(
      onTap: () => _showAdminDialog(admin: admin),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: BorderSide(color: Colors.brown.shade200, width: 1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Colors.brown.shade50],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD7CCC8),
                        borderRadius: BorderRadius.circular(35),
                        border: Border.all(color: const Color(0xFF5D4037), width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: admin.image.isNotEmpty
                            ? Builder(builder: (context) {
                          Uint8List? decoded = decodeBase64Image(admin.image);
                          return decoded != null
                              ? Image.memory(
                            decoded,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildPlaceholderIcon(),
                          )
                              : _buildPlaceholderIcon();
                        })
                            : _buildPlaceholderIcon(),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            admin.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Color(0xFF5D4037),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'البريد: ${admin.email}',
                            style: const TextStyle(
                              color: Color(0xFF795548),
                              overflow: TextOverflow.ellipsis,
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'الجوال: ${admin.mobile}',
                            style: const TextStyle(
                              color: Color(0xFF795548),
                              fontFamily: 'Tajawal',
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.verified_user,
                                  size: 16,
                                  color: admin.confirm == 'Yes' ? Colors.green : Colors.grey),
                              const SizedBox(width: 5),
                              Text(
                                admin.confirm == 'Yes' ? 'تم التأكيد' : 'غير مؤكد',
                                style: TextStyle(
                                  color: admin.confirm == 'Yes' ? Colors.green : Colors.grey,
                                  fontSize: 13,
                                  fontFamily: 'Tajawal',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF5D4037)),
                          onPressed: () => _showAdminDialog(admin: admin),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.redAccent),
                          onPressed: () => _deleteAdmin(admin.id),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return const Icon(Icons.person, size: 40, color: Color(0xFF5D4037));
  }
}