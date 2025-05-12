import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../model/banners_model.dart';
import '../service/banners_server.dart';

class BannerManagementPage extends StatefulWidget {
	const BannerManagementPage({Key? key}) : super(key: key);

	@override
	State<BannerManagementPage> createState() => _BannerManagementPageState();
}

class _BannerManagementPageState extends State<BannerManagementPage> {
	bool _isLoading = false;
	List<BannerModel> _banners = [];
	List<BannerModel> _filteredBanners = [];
	String searchQuery = '';

	@override
	void initState() {
		super.initState();
		_fetchBanners();
	}

	Future<void> _fetchBanners() async {
		print('----- Starting fetch banners -----');
		setState(() => _isLoading = true);
		try {
			List<BannerModel> banners = await BannerService.getAllBanners();
			print('Fetched ${banners.length} banners');
			setState(() {
				_banners = banners;
				_applyFilter();
			});
		} catch (e, stackTrace) {
			print('!!! Error fetching banners: $e');
			print('Stack trace: $stackTrace');
			_showErrorSnackbar('خطأ في جلب البيانات: $e');
		} finally {
			setState(() => _isLoading = false);
		}
	}

	void _applyFilter() {
		print('Applying filter with query: $searchQuery');
		setState(() {
			_filteredBanners = searchQuery.isEmpty
					? List.from(_banners)
					: _banners.where((banner) =>
			banner.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
					banner.link.toLowerCase().contains(searchQuery.toLowerCase())).toList();
		});
		print('Filtered banners count: ${_filteredBanners.length}');
	}

	Uint8List? _decodeBase64Image(String base64Str) {
		try {
			if (base64Str.contains(',')) base64Str = base64Str.split(',').last;
			return base64Decode(base64Str);
		} catch (e, stackTrace) {
			print('!!! Error decoding image: $e');
			print('Stack trace: $stackTrace');
			return null;
		}
	}

	Future<String?> _pickImage() async {
		print('----- Starting image pick -----');
		try {
			final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
			if (pickedImage == null) {
				print('Image pick canceled');
				return null;
			}
			print('Picked image path: ${pickedImage.path}');
			final bytes = await File(pickedImage.path).readAsBytes();
			print('Image size: ${bytes.lengthInBytes} bytes');
			return base64.encode(bytes);
		} catch (e, stackTrace) {
			print('!!! Error picking image: $e');
			print('Stack trace: $stackTrace');
			_showErrorSnackbar('خطأ في اختيار الصورة');
			return null;
		}
	}

	void _showErrorSnackbar(String message) {
		print('!!! Showing error: $message');
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.red),
		);
	}

	void _showSuccessSnackbar(String message) {
		print('✓✓✓ Showing success: $message');
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text(message), backgroundColor: Colors.green),
		);
	}

	void _showBannerForm({BannerModel? banner}) {
		print('----- Showing banner form -----');
		final formKey = GlobalKey<FormState>();
		TextEditingController titleController = TextEditingController(text: banner?.title ?? '');
		TextEditingController linkController = TextEditingController(text: banner?.link ?? '');
		TextEditingController typeController = TextEditingController(text: banner?.type ?? '');
		TextEditingController altController = TextEditingController(text: banner?.alt ?? '');
		TextEditingController statusController = TextEditingController(text: banner?.status ?? '1');
		String imageBase64 = banner?.image ?? '';

		showDialog(
			context: context,
			builder: (context) => StatefulBuilder(
				builder: (context, setStateDialog) {
					return AlertDialog(
						title: Text(banner == null ? 'إضافة بانر جديد' : 'تعديل البانر'),
						content: Form(
							key: formKey,
							child: SingleChildScrollView(
								child: Column(
									mainAxisSize: MainAxisSize.min,
									children: [
										GestureDetector(
											onTap: () async {
												print('----- Starting image pick from form -----');
												String? image = await _pickImage();
												if (image != null) {
													print('New image selected (base64 length: ${image.length})');
													setStateDialog(() => imageBase64 = image);
												}
											},
											child: CircleAvatar(
												radius: 50,
												backgroundColor: Colors.grey[200],
												backgroundImage: imageBase64.isNotEmpty
														? MemoryImage(_decodeBase64Image(imageBase64)!)
														: null,
												child: imageBase64.isEmpty
														? const Icon(Icons.camera_alt, size: 40)
														: null,
											),
										),
										const SizedBox(height: 20),
										TextFormField(
											controller: titleController,
											decoration: const InputDecoration(labelText: 'العنوان'),
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										TextFormField(
											controller: linkController,
											decoration: const InputDecoration(labelText: 'الرابط'),
											validator: (value) => value!.isEmpty ? 'مطلوب' : null,
										),
										TextFormField(
											controller: typeController,
											decoration: const InputDecoration(labelText: 'النوع'),
										),
										TextFormField(
											controller: altController,
											decoration: const InputDecoration(labelText: 'النص البديل'),
										),
										DropdownButtonFormField<String>(
											value: statusController.text,
											items: const [
												DropdownMenuItem(value: '1', child: Text('مفعل')),
												DropdownMenuItem(value: '0', child: Text('غير مفعل')),
											],
											onChanged: (value) {
												print('Status changed to: $value');
												statusController.text = value ?? '1';
											},
											decoration: const InputDecoration(labelText: 'حالة البانر'),
										),
									],
								),
							),
						),
						actions: [
							TextButton(
								child: const Text('إلغاء'),
								onPressed: () {
									print('Form canceled');
									Navigator.pop(context);
								},
							),
							ElevatedButton(
								child: const Text('حفظ'),
								onPressed: () async {
									print('----- Trying to save banner -----');
									if (!formKey.currentState!.validate()) {
										print('Validation failed');
										return;
									}

									Navigator.pop(context);
									setState(() => _isLoading = true);

									try {
										String result;
										if (banner == null) {
											print('Creating new banner with data:');
											print('Title: ${titleController.text}');
											print('Link: ${linkController.text}');
											print('Type: ${typeController.text}');
											print('Alt: ${altController.text}');
											print('Status: ${statusController.text}');
											print('Image length: ${imageBase64.length}');

											BannerModel newBanner = BannerModel.create(
												id: '0',
												image: imageBase64,
												type: typeController.text,
												link: linkController.text,
												title: titleController.text,
												alt: altController.text,
												status: statusController.text,
											);
											result = await BannerService.addBanner(newBanner);
										} else {
											print('Updating banner ID ${banner.id} with data:');
											print('New title: ${titleController.text}');
											print('New link: ${linkController.text}');
											print('New type: ${typeController.text}');
											print('New alt: ${altController.text}');
											print('New status: ${statusController.text}');
											print('New image length: ${imageBase64.length}');

											BannerModel updatedBanner = banner.copyWith(
												image: imageBase64,
												type: typeController.text,
												link: linkController.text,
												title: titleController.text,
												alt: altController.text,
												status: statusController.text,
											);
											result = await BannerService.updateBanner(updatedBanner);
										}

										print('Server response: $result');
										if (result.toLowerCase().contains('success')) {
											await _fetchBanners();
											_showSuccessSnackbar(banner == null
													? 'تمت الإضافة بنجاح'
													: 'تم التحديث بنجاح');
										} else {
											_showErrorSnackbar(result);
										}
									} catch (e, stackTrace) {
										print('!!! Error saving banner: $e');
										print('Stack trace: $stackTrace');
										_showErrorSnackbar('حدث خطأ: $e');
									} finally {
										setState(() => _isLoading = false);
									}
								},
							),
						],
					);
				},
			),
		);
	}

	Future<void> _deleteBanner(String id) async {
		print('----- Deleting banner ID $id -----');
		setState(() => _isLoading = true);
		try {
			String result = await BannerService.deleteBanner(id);
			print('Delete response: $result');
			if (result.toLowerCase().contains('success')) {
				await _fetchBanners();
				_showSuccessSnackbar('تم الحذف بنجاح');
			} else {
				_showErrorSnackbar(result);
			}
		} catch (e, stackTrace) {
			print('!!! Error deleting banner: $e');
			print('Stack trace: $stackTrace');
			_showErrorSnackbar('حدث خطأ أثناء الحذف');
		} finally {
			setState(() => _isLoading = false);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('إدارة البنرات'),
				actions: [
					IconButton(
						icon: const Icon(Icons.add),
						onPressed: () => _showBannerForm(),
					),
				],
			),
			body: _isLoading
					? const Center(child: CircularProgressIndicator())
					: Column(
				children: [
					Padding(
						padding: const EdgeInsets.all(8.0),
						child: TextField(
							decoration: const InputDecoration(
								labelText: 'البحث',
								border: OutlineInputBorder(),
								prefixIcon: Icon(Icons.search),
							),
							onChanged: (query) {
								print('Search query: $query');
								setState(() {
									searchQuery = query;
									_applyFilter();
								});
							},
						),
					),
					Expanded(
						child: ListView.builder(
							itemCount: _filteredBanners.length,
							itemBuilder: (context, index) {
								BannerModel banner = _filteredBanners[index];
								return Card(
									margin: const EdgeInsets.all(8.0),
									child: ListTile(
										leading: CircleAvatar(
											backgroundImage: banner.image != null
													? MemoryImage(
													_decodeBase64Image(banner.image!)!)
													: null,
											child: banner.image == null
													? const Icon(Icons.camera_alt)
													: null,
										),
										title: Text(banner.title),
										subtitle: Text(banner.link),
										trailing: PopupMenuButton<String>(
											icon: const Icon(Icons.more_vert),
											onSelected: (value) {
												if (value == 'edit') {
													_showBannerForm(banner: banner);
												} else if (value == 'delete') {
													_deleteBanner(banner.id);
												}
											},
											itemBuilder: (context) => [
												const PopupMenuItem(
													value: 'edit',
													child: Text('تعديل'),
												),
												const PopupMenuItem(
													value: 'delete',
													child: Text('حذف'),
												),
											],
										),
									),
								);
							},
						),
					),
				],
			),
		);
	}
}
