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
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentFooterIndex = 1; // مؤشر للعنصر النشط في الفوتر

  // Controllers للفلترة والبحث
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _vendorIdFilterController = TextEditingController();
  final TextEditingController _typeFilterController = TextEditingController();
  String _selectedStatusFilter = 'الكل';
  String _selectedConfirmFilter = 'الكل';
  String _selectedImageFilter = 'الكل';
  String _sortBy = 'id';
  bool _sortAscending = true;

  // إحصائيات
  DashboardStats? _stats;

  @override
  void initState() {
    super.initState();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _fadeController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _fadeController.forward();
    _slideController.forward();

    _fetchAdmins();
    _searchController.addListener(_applyFilter);
    _vendorIdFilterController.addListener(_applyFilter);
    _typeFilterController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _loadingController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _searchController.dispose();
    _vendorIdFilterController.dispose();
    _typeFilterController.dispose();
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
        _stats = _calculateStats();
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

  DashboardStats _calculateStats() {
    if (_admins.isEmpty) {
      return DashboardStats(
        totalAdmins: 0,
        activeAdmins: 0,
        inactiveAdmins: 0,
        confirmedAdmins: 0,
        unconfirmedAdmins: 0,
        uniqueVendors: 0,
        adminsWithImages: 0,
        adminsWithoutImages: 0,
        mostCommonType: 'غير متوفر',
        mostCommonStatus: 'غير متوفر',
        totalTypes: 0,
        confirmationRate: 0.0,
        activationRate: 0.0,
      );
    }

    int activeAdmins = _admins.where((admin) => admin.status == '1').length;
    int inactiveAdmins = _admins.where((admin) => admin.status == '0').length;
    int confirmedAdmins = _admins.where((admin) => admin.confirm.toLowerCase() == 'yes').length;
    int unconfirmedAdmins = _admins.where((admin) => admin.confirm.toLowerCase() == 'no').length;
    Set<String> uniqueVendors = _admins.map((admin) => admin.vendorId).where((id) => id.isNotEmpty).toSet();
    int adminsWithImages = _admins.where((admin) => admin.image.isNotEmpty).length;
    int adminsWithoutImages = _admins.where((admin) => admin.image.isEmpty).length;

    // حساب النوع الأكثر شيوعاً
    Map<String, int> typeCount = {};
    for (var admin in _admins) {
      if (admin.type.isNotEmpty) {
        typeCount[admin.type] = (typeCount[admin.type] ?? 0) + 1;
      }
    }
    String mostCommonType = typeCount.entries.isNotEmpty
        ? typeCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'غير متوفر';

    // حساب الحالة الأكثر شيوعاً
    Map<String, int> statusCount = {};
    for (var admin in _admins) {
      String statusText = admin.status == '1' ? 'نشط' : 'غير نشط';
      statusCount[statusText] = (statusCount[statusText] ?? 0) + 1;
    }
    String mostCommonStatus = statusCount.entries.isNotEmpty
        ? statusCount.entries.reduce((a, b) => a.value > b.value ? a : b).key
        : 'غير متوفر';

    Set<String> uniqueTypes = _admins.map((admin) => admin.type).where((type) => type.isNotEmpty).toSet();
    double confirmationRate = _admins.isNotEmpty ? (confirmedAdmins / _admins.length) * 100 : 0.0;
    double activationRate = _admins.isNotEmpty ? (activeAdmins / _admins.length) * 100 : 0.0;

    return DashboardStats(
      totalAdmins: _admins.length,
      activeAdmins: activeAdmins,
      inactiveAdmins: inactiveAdmins,
      confirmedAdmins: confirmedAdmins,
      unconfirmedAdmins: unconfirmedAdmins,
      uniqueVendors: uniqueVendors.length,
      adminsWithImages: adminsWithImages,
      adminsWithoutImages: adminsWithoutImages,
      mostCommonType: mostCommonType,
      mostCommonStatus: mostCommonStatus,
      totalTypes: uniqueTypes.length,
      confirmationRate: confirmationRate,
      activationRate: activationRate,
    );
  }

  void _applyFilter() {
    setState(() {
      _filteredAdmins = _admins.where((admin) {
        bool matchesSearch = _searchController.text.isEmpty ||
            admin.name.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            admin.email.toLowerCase().contains(_searchController.text.toLowerCase()) ||
            admin.mobile.contains(_searchController.text) ||
            admin.type.toLowerCase().contains(_searchController.text.toLowerCase());

        bool matchesVendorId = _vendorIdFilterController.text.isEmpty ||
            admin.vendorId.contains(_vendorIdFilterController.text);

        bool matchesType = _typeFilterController.text.isEmpty ||
            admin.type.toLowerCase().contains(_typeFilterController.text.toLowerCase());

        bool matchesStatus = _selectedStatusFilter == 'الكل' ||
            (_selectedStatusFilter == 'نشط' && admin.status == '1') ||
            (_selectedStatusFilter == 'غير نشط' && admin.status == '0');

        bool matchesConfirm = _selectedConfirmFilter == 'الكل' ||
            (_selectedConfirmFilter == 'مؤكد' && admin.confirm.toLowerCase() == 'yes') ||
            (_selectedConfirmFilter == 'غير مؤكد' && admin.confirm.toLowerCase() == 'no');

        bool matchesImage = _selectedImageFilter == 'الكل' ||
            (_selectedImageFilter == 'مع صورة' && admin.image.isNotEmpty) ||
            (_selectedImageFilter == 'بدون صورة' && admin.image.isEmpty);

        return matchesSearch && matchesVendorId && matchesType && matchesStatus && matchesConfirm && matchesImage;
      }).toList();

      _sortAdmins();
    });
  }

  void _sortAdmins() {
    _filteredAdmins.sort((a, b) {
      int comparison = 0;
      switch (_sortBy) {
        case 'id':
          comparison = int.parse(a.id).compareTo(int.parse(b.id));
          break;
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'type':
          comparison = a.type.compareTo(b.type);
          break;
        case 'vendorId':
          comparison = int.parse(a.vendorId.isEmpty ? '0' : a.vendorId).compareTo(int.parse(b.vendorId.isEmpty ? '0' : b.vendorId));
          break;
        case 'email':
          comparison = a.email.compareTo(b.email);
          break;
        case 'mobile':
          comparison = a.mobile.compareTo(b.mobile);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'confirm':
          comparison = a.confirm.compareTo(b.confirm);
          break;
        case 'createdAt':
          comparison = (a.createdAt ?? '').compareTo(b.createdAt ?? '');
          break;
      }
      return _sortAscending ? comparison : -comparison;
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

    // إصلاح مشكلة DropdownButtonFormField - التأكد من أن القيم تتطابق مع الخيارات المتاحة
    String confirmValue = admin?.confirm ?? 'No';
    if (confirmValue != 'Yes' && confirmValue != 'No') {
      confirmValue = 'No'; // قيمة افتراضية آمنة
    }

    String statusValue = admin?.status ?? '0';
    if (statusValue != '1' && statusValue != '0') {
      statusValue = '0'; // قيمة افتراضية آمنة
    }

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
                                DropdownMenuItem(value: 'Yes', child: Text('مؤكد')),
                                DropdownMenuItem(value: 'No', child: Text('غير مؤكد')),
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
                            DropdownButtonFormField<String>(
                              value: statusValue,
                              items: const [
                                DropdownMenuItem(value: '1', child: Text('نشط')),
                                DropdownMenuItem(value: '0', child: Text('غير نشط')),
                              ],
                              onChanged: (value) => setStateDialog(() {
                                statusValue = value ?? '0';
                              }),
                              decoration: const InputDecoration(
                                labelText: 'الحالة',
                                labelStyle: TextStyle(color: Colors.brown),
                                border: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.brown),
                                ),
                              ),
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
                                  side: const BorderSide(color: Colors.grey),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text(
                                  'إلغاء',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF5D4037),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: () async {
                                  try {
                                    Admin newAdmin = Admin(
                                      id: admin?.id ?? '',
                                      name: nameController.text,
                                      type: typeController.text,
                                      vendorId: vendorIdController.text,
                                      mobile: mobileController.text,
                                      email: emailController.text,
                                      password: passwordController.text,
                                      confirm: confirmValue,
                                      status: statusValue,
                                      image: imageBase64,
                                      createdAt: admin?.createdAt,
                                      updatedAt: admin?.updatedAt,
                                    );

                                    if (admin == null) {
                                      await AdminService.addAdmin(newAdmin);
                                      ScaffoldMessenger.of(parentContext).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text('تم إضافة المدير بنجاح'),
                                        ),
                                      );
                                    } else {
                                      await AdminService.updateAdmin(newAdmin);
                                      ScaffoldMessenger.of(parentContext).showSnackBar(
                                        const SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text('تم تحديث المدير بنجاح'),
                                        ),
                                      );
                                    }

                                    Navigator.of(context).pop();
                                    _fetchAdmins();
                                  } catch (e) {
                                    ScaffoldMessenger.of(parentContext).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text('خطأ: $e'),
                                      ),
                                    );
                                  }
                                },
                                child: Text(
                                  admin == null ? 'إضافة' : 'تحديث',
                                  style: const TextStyle(color: Colors.white),
                                ),
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

  void _deleteAdmin(Admin admin) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف المدير "${admin.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              try {
                await AdminService.deleteAdmin(admin.id);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    backgroundColor: Colors.green,
                    content: Text('تم حذف المدير بنجاح'),
                  ),
                );
                _fetchAdmins();
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: Colors.red,
                    content: Text('خطأ في الحذف: $e'),
                  ),
                );
              }
            },
            child: const Text('حذف', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    if (_stats == null) return SizedBox.shrink();

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          margin: EdgeInsets.all(16),
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.brown.shade50, Colors.brown.shade100],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.shade200.withOpacity(0.5),
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
                    Icon(Icons.dashboard, color: Colors.brown.shade700, size: 28),
                    SizedBox(width: 12),
                    Text(
                      "لوحة الإحصائيات",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown.shade800,
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
                    _buildStatCard("إجمالي المديرين", _stats!.totalAdmins.toString(), Icons.people, Colors.green),
                    _buildStatCard("مديرين نشطين", _stats!.activeAdmins.toString(), Icons.person_add, Colors.blue),
                    _buildStatCard("مديرين غير نشطين", _stats!.inactiveAdmins.toString(), Icons.person_off, Colors.orange),
                    _buildStatCard("حسابات مؤكدة", _stats!.confirmedAdmins.toString(), Icons.verified, Colors.purple),
                    _buildStatCard("حسابات غير مؤكدة", _stats!.unconfirmedAdmins.toString(), Icons.pending, Colors.red),
                    _buildStatCard("بائعين فريدين", _stats!.uniqueVendors.toString(), Icons.store, Colors.teal),
                    _buildStatCard("مع صور", _stats!.adminsWithImages.toString(), Icons.image, Colors.amber),
                    _buildStatCard("بدون صور", _stats!.adminsWithoutImages.toString(), Icons.image_not_supported, Colors.cyan),
                    _buildStatCard("النوع الأكثر شيوعاً", _stats!.mostCommonType, Icons.category, Colors.indigo),
                    _buildStatCard("الحالة الأكثر شيوعاً", _stats!.mostCommonStatus, Icons.trending_up, Colors.pink),
                    _buildStatCard("أنواع مختلفة", _stats!.totalTypes.toString(), Icons.diversity_3, Colors.brown),
                    _buildStatCard("معدل التأكيد", "${_stats!.confirmationRate.toStringAsFixed(1)}%", Icons.check_circle, Colors.green),
                    _buildStatCard("معدل التفعيل", "${_stats!.activationRate.toStringAsFixed(1)}%", Icons.toggle_on, Colors.blue),
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
              Icon(Icons.filter_list, color: Colors.brown.shade600),
              SizedBox(width: 8),
              Text(
                "البحث والفلترة",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown.shade800,
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
                    hintText: "البحث في المديرين...",
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
                  controller: _vendorIdFilterController,
                  decoration: InputDecoration(
                    hintText: "فلترة بمعرف البائع...",
                    prefixIcon: Icon(Icons.store),
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
                  controller: _typeFilterController,
                  decoration: InputDecoration(
                    hintText: "فلترة بالنوع...",
                    prefixIcon: Icon(Icons.category),
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
                child: DropdownButtonFormField<String>(
                  value: _selectedStatusFilter,
                  decoration: InputDecoration(
                    labelText: "فلترة بالحالة",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: ['الكل', 'نشط', 'غير نشط']
                      .map((status) => DropdownMenuItem(value: status, child: Text(status)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedStatusFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedConfirmFilter,
                  decoration: InputDecoration(
                    labelText: "فلترة بالتأكيد",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: ['الكل', 'مؤكد', 'غير مؤكد']
                      .map((confirm) => DropdownMenuItem(value: confirm, child: Text(confirm)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedConfirmFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedImageFilter,
                  decoration: InputDecoration(
                    labelText: "فلترة بالصورة",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: ['الكل', 'مع صورة', 'بدون صورة']
                      .map((image) => DropdownMenuItem(value: image, child: Text(image)))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedImageFilter = value!;
                      _applyFilter();
                    });
                  },
                ),
              ),
            ],
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
                DropdownMenuItem(value: 'name', child: Text('الاسم')),
                DropdownMenuItem(value: 'type', child: Text('النوع')),
                DropdownMenuItem(value: 'vendorId', child: Text('معرف البائع')),
                DropdownMenuItem(value: 'email', child: Text('البريد الإلكتروني')),
                DropdownMenuItem(value: 'mobile', child: Text('الجوال')),
                DropdownMenuItem(value: 'status', child: Text('الحالة')),
                DropdownMenuItem(value: 'confirm', child: Text('التأكيد')),
                DropdownMenuItem(value: 'createdAt', child: Text('تاريخ الإنشاء')),
              ],
              onChanged: (value) {
                setState(() {
                  _sortBy = value!;
                  _applyFilter();
                });
              },
            ),
          ),
          IconButton(
            icon: Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _sortAscending = !_sortAscending;
                _applyFilter();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard(Admin admin) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.brown.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: const Color(0xFFD7CCC8),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: const Color(0xFF5D4037), width: 2),
                ),
                child: admin.image.isNotEmpty
                    ? Builder(builder: (context) {
                  Uint8List? decoded = decodeBase64Image(admin.image);
                  return decoded != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Image.memory(
                      decoded,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.person, size: 30, color: Colors.brown),
                    ),
                  )
                      : const Icon(Icons.person, size: 30, color: Colors.brown);
                })
                    : const Icon(Icons.person, size: 30, color: Colors.brown),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      admin.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF5D4037),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      admin.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: admin.status == '1' ? Colors.green.shade100 : Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            admin.status == '1' ? 'نشط' : 'غير نشط',
                            style: TextStyle(
                              fontSize: 12,
                              color: admin.status == '1' ? Colors.green.shade700 : Colors.red.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: admin.confirm.toLowerCase() == 'yes' ? Colors.blue.shade100 : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            admin.confirm.toLowerCase() == 'yes' ? 'مؤكد' : 'غير مؤكد',
                            style: TextStyle(
                              fontSize: 12,
                              color: admin.confirm.toLowerCase() == 'yes' ? Colors.blue.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF5D4037)),
                    onPressed: () => _showAdminDialog(admin: admin),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAdmin(admin),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'إدارة المديرين',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchAdmins,
            tooltip: "تحديث",
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("معلومات التطبيق"),
                  content: const Text("تطبيق إدارة المديرين مع لوحة إحصائيات وطرق فلترة متقدمة"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("موافق"),
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
              valueColor: AlwaysStoppedAnimation<Color>(Colors.brown.shade600),
            ),
            const SizedBox(height: 16),
            Text("جاري التحميل...", style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      )
          : _admins.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              "لا توجد مديرين متاحين",
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              "اضغط على زر الإضافة لبدء إضافة المديرين",
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
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                "عرض ${_filteredAdmins.length} من ${_admins.length} مدير",
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredAdmins.length,
              itemBuilder: (context, index) {
                return _buildAdminCard(_filteredAdmins[index]);
              },
            ),
            const SizedBox(height: 80), // مساحة إضافية للـ FloatingActionButton
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdminDialog(),
        backgroundColor: const Color(0xFF5D4037),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("إضافة مدير"),
        tooltip: "إضافة مدير جديد",
      ),
    );
  }
}

// كلاس للإحصائيات
class DashboardStats {
  final int totalAdmins;
  final int activeAdmins;
  final int inactiveAdmins;
  final int confirmedAdmins;
  final int unconfirmedAdmins;
  final int uniqueVendors;
  final int adminsWithImages;
  final int adminsWithoutImages;
  final String mostCommonType;
  final String mostCommonStatus;
  final int totalTypes;
  final double confirmationRate;
  final double activationRate;

  DashboardStats({
    required this.totalAdmins,
    required this.activeAdmins,
    required this.inactiveAdmins,
    required this.confirmedAdmins,
    required this.unconfirmedAdmins,
    required this.uniqueVendors,
    required this.adminsWithImages,
    required this.adminsWithoutImages,
    required this.mostCommonType,
    required this.mostCommonStatus,
    required this.totalTypes,
    required this.confirmationRate,
    required this.activationRate,
  });
}

