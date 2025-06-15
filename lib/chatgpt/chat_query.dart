// lib/pages/chat_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'api_service.dart';

class ChatScreen extends StatefulWidget {
	const ChatScreen({Key? key}) : super(key: key);

	@override
	_ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
	final TextEditingController _controller = TextEditingController();
	String _response = '';
	bool _isLoading = false;
	late AnimationController _animationController;

	Future<void> _sendQuery() async {
		final query = _controller.text.trim();
		if (query.isEmpty) return;

		setState(() {
			_isLoading = true;
			_response = '';
		});

		_animationController.forward(from: 0.0); // إعادة تشغيل التأثير

		final reply = await ApiService.sendChatQuery(query);

		setState(() {
			_response = reply;
			_isLoading = false;
		});
	}

	@override
	void initState() {
		super.initState();
		_animationController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 600),
		);
	}

	@override
	void dispose() {
		_controller.dispose();
		_animationController.dispose();
		super.dispose();
	}

	Widget _buildResponseWidget() {
		if (_isLoading) {
			return FadeTransition(
				opacity: _animationController,
				child: Center(
					child: Column(
						mainAxisAlignment: MainAxisAlignment.center,
						children: [
							Text(
								"جاري التفكير...",
								style: TextStyle(color: Colors.blueGrey, fontSize: 16),
							),
							const SizedBox(height: 12),
							CircularProgressIndicator(),
						],
					),
				),
			);
		} else if (_response.isNotEmpty) {
			return FadeTransition(
				opacity: _animationController,
				child: Card(
					elevation: 4,
					shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
					child: Padding(
						padding: const EdgeInsets.all(16.0),
						child: SelectableText(
							_response,
							style: const TextStyle(fontSize: 16, height: 1.5),
						),
					),
				),
			);
		} else {
			return Opacity(
				opacity: 0.6,
				child: const Center(
					child: Text(
						'ستظهر الردود هنا بعد الإرسال.',
						textAlign: TextAlign.center,
						style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
					),
				),
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: const Text('التحدث مع النظام الذكي'),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
				elevation: 2,
			),
			body: AnnotatedRegion<SystemUiOverlayStyle>(
				value: SystemUiOverlayStyle.light,
				child: Container(
					color: Colors.grey[200],
					padding: const EdgeInsets.all(16.0),
					child: Column(
						children: [
							// حقل إدخال المستخدم
							TextField(
								controller: _controller,
								decoration: InputDecoration(
									labelText: 'اكتب استفسارك...',
									labelStyle: TextStyle(color: Colors.deepPurple),
									filled: true,
									fillColor: Colors.white,
									border: OutlineInputBorder(
										borderRadius: BorderRadius.circular(12),
										borderSide: BorderSide.none,
									),
									suffixIcon: IconButton(
										icon: Icon(
											Icons.send,
											color: _isLoading ? Colors.grey : Colors.deepPurple,
										),
										onPressed: _isLoading ? null : _sendQuery,
									),
									contentPadding: const EdgeInsets.symmetric(
											vertical: 12.0, horizontal: 16.0),
								),
								textInputAction: TextInputAction.send,
								onSubmitted: (_) {
									if (!_isLoading) _sendQuery();
								},
							),
							const SizedBox(height: 16),
							Expanded(
								child: Container(
									padding: const EdgeInsets.all(12),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.circular(12),
										boxShadow: [
											BoxShadow(
												color: Colors.black12.withOpacity(0.05),
												blurRadius: 10,
												spreadRadius: 1,
											)
										],
									),
									child: _buildResponseWidget(),
								),
							),
						],
					),
				),
			),
		);
	}
}