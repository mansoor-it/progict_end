
import 'package:flutter/cupertino.dart';

import '../model/image.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled2/service/server.dart';
import 'package:untitled2/model/image.dart';
class MyHomePage extends StatefulWidget {
	const MyHomePage({Key? key}) : super(key: key);

	@override
	State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
	File? image;
	bool _isLoading = false;
	List<Images> _images = [];

	@override
	void initState() {
		super.initState();
		_getPosts();
	}

	// استدعاء كل الصور من السيرفر
	Future<void> _getPosts() async {
		setState(() {
			_isLoading = true;
		});
		await Services.getAllPosts().then((posts) {
			setState(() {
				_images = posts;
				_isLoading = false;
			});
		});
	}

	// اختيار صورة من المعرض
	Future<void> pickImage(Function(String) onImagePicked) async {
		try {
			final pickedImage =
			await ImagePicker().pickImage(source: ImageSource.gallery);
			if (pickedImage == null) return;
			File imageFile = File(pickedImage.path);
			Uint8List imageBytes = await imageFile.readAsBytes();
			String base64string = base64.encode(imageBytes);
			onImagePicked(base64string);
		} on PlatformException catch (e) {
			if (kDebugMode) {
				print(e);
			}
		}
	}

	// دالة إضافة صورة جديدة
	_addPost(String imageCode) async {
		setState(() {
			_isLoading = true;
		});
		await Services.addImage(imageCode).then((result) {
			if (result.contains('success')) {
				_getPosts();
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						backgroundColor: Colors.green,
						content: Row(
							children: [
								Icon(Icons.thumb_up, color: Colors.white),
								SizedBox(width: 5),
								Text(
									'تم إضافة الصورة',
									style: TextStyle(color: Colors.white),
								),
							],
						),
					),
				);
			}
			setState(() {
				_isLoading = false;
			});
		});
	}

	// دالة تحديث الصورة بناءً على id الخاص بها
	_updatePost(String id) async {
		await pickImage((newImageCode) async {
			setState(() {
				_isLoading = true;
			});
			String result = await Services.updateImage(id, newImageCode);
			if (result.contains('success')) {
				_getPosts();
				ScaffoldMessenger.of(context).showSnackBar(
					const SnackBar(
						backgroundColor: Colors.green,
						content: Text(
							'تم تحديث الصورة',
							style: TextStyle(color: Colors.white),
						),
					),
				);
			}
			setState(() {
				_isLoading = false;
			});
		});
	}

	// دالة حذف الصورة بناءً على id الخاص بها
	_deletePost(String id) async {
		setState(() {
			_isLoading = true;
		});
		String result = await Services.deleteImage(id);
		if (result.contains('success')) {
			_getPosts();
			ScaffoldMessenger.of(context).showSnackBar(
				const SnackBar(
					backgroundColor: Colors.green,
					content: Text(
						'تم حذف الصورة',
						style: TextStyle(color: Colors.white),
					),
				),
			);
		}
		setState(() {
			_isLoading = false;
		});
	}

	// بناء الواجهة الرئيسية مع عرض الصور وإضافة زر لإضافة صورة جديدة
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			floatingActionButton: FloatingActionButton(
				onPressed: () {
					// اختيار صورة جديدة والإضافة
					pickImage((base64String) => _addPost(base64String));
				},
				child: const Icon(Icons.add),
			),
			appBar: AppBar(
				title: const Text('Image Cloud'),
				actions: [
					if (_isLoading)
						const Padding(
							padding: EdgeInsets.all(10.0),
							child: CircularProgressIndicator(
								color: Colors.white,
							),
						),
				],
			),
			body: _images.isEmpty
					? const Center(child: Text('لا توجد صور حتى الآن'))
					: GridView.builder(
				padding: const EdgeInsets.all(8),
				gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: 3,
					crossAxisSpacing: 5.0,
					mainAxisSpacing: 5.0,
				),
				itemCount: _images.length,
				itemBuilder: (context, index) {
					final img = _images[index];
					return Stack(
						children: [
							// عرض الصورة
							Positioned.fill(
								child: Image.memory(
									base64Decode(img.imageString),
									fit: BoxFit.cover,
								),
							),
							// زر حذف
							Positioned(
								top: 0,
								right: 0,
								child: IconButton(
									icon: const Icon(
										Icons.delete,
										color: Colors.redAccent,
										size: 20,
									),
									onPressed: () => _deletePost(img.id),
								),
							),
							// زر تحديث
							Positioned(
								bottom: 0,
								right: 0,
								child: IconButton(
									icon: const Icon(
										Icons.edit,
										color: Colors.blueAccent,
										size: 20,
									),
									onPressed: () => _updatePost(img.id),
								),
							),
						],
					);
				},
			),
		);
	}
}
