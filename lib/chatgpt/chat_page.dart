import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../ApiConfig.dart';

// chat_message.dart
class ChatMessage {
	final String text;
	final bool isUser; // true إذا كانت رسالة المستخدم، false إذا من الوكيل
	final DateTime timestamp;

	ChatMessage({required this.text, required this.isUser}) : timestamp = DateTime.now();
}

class ChatPage extends StatefulWidget {
	const ChatPage({Key? key}) : super(key: key);

	@override
	State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> with TickerProviderStateMixin {
	final List<ChatMessage> _messages = [];
	final TextEditingController _controller = TextEditingController();
	final FocusNode _focusNode = FocusNode();
	bool _isSending = false;
	bool _showScrollToBottom = false;

	final ScrollController _scrollController = ScrollController();
	late final AnimationController _typingIndicatorController;
	bool _isTyping = false;

	@override
	void initState() {
		super.initState();
		_scrollController.addListener(_scrollListener);
		_typingIndicatorController = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 1200),
		)..repeat(reverse: true);
	}

	@override
	void dispose() {
		_controller.dispose();
		_scrollController.dispose();
		_focusNode.dispose();
		_typingIndicatorController.dispose();
		super.dispose();
	}

	void _scrollListener() {
		if (_scrollController.offset < _scrollController.position.maxScrollExtent - 100) {
			if (!_showScrollToBottom) {
				setState(() => _showScrollToBottom = true);
			}
		} else {
			if (_showScrollToBottom) {
				setState(() => _showScrollToBottom = false);
			}
		}
	}

	Future<String> chatWithAgent(String userMessage) async {
		final uri = Uri.parse(ApiHelper.url('chat-agent.php'));
		try {
			debugPrint('Sending request to: ${uri.toString()} with message: $userMessage');
			final response = await http.post(
				uri,
				headers: {'Content-Type': 'application/json'},
				body: jsonEncode({"message": userMessage}),
			);
			debugPrint('Received status code: ${response.statusCode}');
			debugPrint('Response body: ${response.body}');

			if (response.statusCode == 200) {
				final data = jsonDecode(response.body);
				return data["reply"] ?? "لم يصدر ردّ واضح.";
			} else {
				final errorMsg = '❌ فشل الاتصال بالسيرفر (HTTP ${response.statusCode}).';
				debugPrint(errorMsg);
				return errorMsg;
			}
		} catch (e, stackTrace) {
			debugPrint('Error during chatWithAgent: $e');
			debugPrint('StackTrace: $stackTrace');
			return "❌ خطأ أثناء الاتصال: $e";
		}
	}

	void _sendMessage() async {
		final text = _controller.text.trim();
		if (text.isEmpty) return;

		final userMsg = ChatMessage(text: text, isUser: true);
		setState(() {
			_messages.insert(0, userMsg);
			_isSending = true;
			_isTyping = true;
		});
		_controller.clear();
		_focusNode.requestFocus();
		_scrollToTop();

		await Future.delayed(const Duration(milliseconds: 300));
		final agentReply = await chatWithAgent(text);

		setState(() {
			_isTyping = false;
			_messages.insert(0, ChatMessage(text: agentReply, isUser: false));
			_isSending = false;
		});
		_scrollToTop();
	}

	void _scrollToTop() {
		WidgetsBinding.instance.addPostFrameCallback((_) {
			if (_scrollController.hasClients) {
				_scrollController.animateTo(
					0,
					duration: const Duration(milliseconds: 300),
					curve: Curves.easeOut,
				);
			}
		});
	}

	void _scrollToBottomButton() {
		if (_scrollController.hasClients) {
			_scrollController.animateTo(
				_scrollController.position.maxScrollExtent,
				duration: const Duration(milliseconds: 300),
				curve: Curves.easeOut,
			);
		}
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFFEFEFEF),
			appBar: AppBar(
				title: const Text("مساعد تتبع الطلبات"),
				centerTitle: true,
				backgroundColor: Colors.deepPurple,
				elevation: 4,
			),
			body: Center(
				child: Container(
					margin: const EdgeInsets.all(16),
					padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.circular(20),
						boxShadow: const [
							BoxShadow(
								color: Colors.black12,
								blurRadius: 10,
								offset: Offset(0, 6),
							),
						],
					),
					constraints: BoxConstraints(
						maxWidth: 600,
						maxHeight: MediaQuery.of(context).size.height * 0.85,
					),
					child: Stack(
						children: [
							Column(
								children: [
									// صندوق الرسائل
									Expanded(
										child: ClipRRect(
											borderRadius: BorderRadius.circular(16),
											child: Container(
												color: const Color(0xFFF7F7F7),
												child: ListView.builder(
													controller: _scrollController,
													reverse: true,
													padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
													itemCount: _messages.length + (_isTyping ? 1 : 0),
													itemBuilder: (context, index) {
														if (_isTyping && index == 0) {
															return _buildTypingIndicator();
														}
														final msg = _messages[index - (_isTyping ? 1 : 0)];
														return _buildMessageBubble(msg);
													},
												),
											),
										),
									),
									const SizedBox(height: 8),
									// مدخل النص وزر الإرسال
									Row(
										children: [
											// حقل النص
											Expanded(
												child: Container(
													padding: const EdgeInsets.symmetric(horizontal: 16),
													decoration: BoxDecoration(
														color: Colors.grey[100],
														borderRadius: BorderRadius.circular(30),
														border: Border.all(color: Colors.grey.shade300),
													),
													child: TextField(
														controller: _controller,
														focusNode: _focusNode,
														textInputAction: TextInputAction.send,
														onSubmitted: (value) {
															if (!_isSending) _sendMessage();
														},
														style: const TextStyle(fontSize: 16),
														decoration: const InputDecoration(
															hintText: "اكتب رسالتك هنا...",
															border: InputBorder.none,
														),
													),
												),
											),
											const SizedBox(width: 8),
											// زر الإرسال أو مؤشر التحميل
											_isSending
													? SizedBox(
												width: 48,
												height: 48,
												child: Center(
													child: CircularProgressIndicator(
														strokeWidth: 3,
														valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
													),
												),
											)
													: Container(
												decoration: BoxDecoration(
													color: Colors.deepPurple,
													shape: BoxShape.circle,
													boxShadow: [
														BoxShadow(
															color: Colors.deepPurple.withOpacity(0.4),
															blurRadius: 8,
															offset: const Offset(0, 4),
														),
													],
												),
												child: IconButton(
													icon: const Icon(Icons.send, color: Colors.white),
													onPressed: _sendMessage,
												),
											),
										],
									),
								],
							),
							// زر الرجوع إلى الأسفل
							if (_showScrollToBottom)
								Positioned(
									bottom: 70,
									right: 16,
									child: GestureDetector(
										onTap: _scrollToBottomButton,
										child: Container(
											padding: const EdgeInsets.all(8),
											decoration: BoxDecoration(
												color: Colors.deepPurple,
												shape: BoxShape.circle,
												boxShadow: [
													BoxShadow(
														color: Colors.black26,
														blurRadius: 8,
														offset: const Offset(0, 4),
													),
												],
											),
											child: const Icon(
												Icons.keyboard_arrow_down,
												color: Colors.white,
												size: 28,
											),
										),
									),
								),
						],
					),
				),
			),
		);
	}

	Widget _buildMessageBubble(ChatMessage msg) {
		final alignment = msg.isUser ? Alignment.centerRight : Alignment.centerLeft;
		final bubbleColor = msg.isUser ? Colors.deepPurple[50] : Colors.grey[200];
		final textColor = msg.isUser ? Colors.deepPurple[900] : Colors.black87;
		final radius = msg.isUser
				? const BorderRadius.only(
			topLeft: Radius.circular(20),
			topRight: Radius.circular(20),
			bottomLeft: Radius.circular(20),
			bottomRight: Radius.circular(4),
		)
				: const BorderRadius.only(
			topLeft: Radius.circular(20),
			topRight: Radius.circular(20),
			bottomRight: Radius.circular(20),
			bottomLeft: Radius.circular(4),
		);
		final icon = msg.isUser ? Icons.person : Icons.smart_toy;

		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
			child: Column(
				crossAxisAlignment:
				msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
				children: [
					Row(
						mainAxisAlignment: msg.isUser
								? MainAxisAlignment.end
								: MainAxisAlignment.start,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							if (!msg.isUser)
								CircleAvatar(
									backgroundColor: Colors.grey[400],
									child: Icon(icon, size: 20, color: Colors.white),
									radius: 18,
								),
							if (!msg.isUser) const SizedBox(width: 8),
							Flexible(
								child: Container(
									padding:
									const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
									decoration: BoxDecoration(
										color: bubbleColor,
										borderRadius: radius,
									),
									child: Column(
										crossAxisAlignment: CrossAxisAlignment.start,
										children: [
											Text(
												msg.text,
												style: TextStyle(fontSize: 16, color: textColor, height: 1.3),
											),
											const SizedBox(height: 6),
											Text(
												_formatTimestamp(msg.timestamp),
												style: TextStyle(fontSize: 10, color: Colors.grey[600]),
												textAlign: TextAlign.right,
											),
										],
									),
								),
							),
							if (msg.isUser) const SizedBox(width: 8),
							if (msg.isUser)
								CircleAvatar(
									backgroundColor: Colors.deepPurple,
									child: Icon(icon, size: 20, color: Colors.white),
									radius: 18,
								),
						],
					),
				],
			),
		);
	}

	Widget _buildTypingIndicator() {
		return Padding(
			padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
			child: Row(
				mainAxisAlignment: MainAxisAlignment.start,
				children: [
					CircleAvatar(
						backgroundColor: Colors.grey[400],
						child: const Icon(Icons.smart_toy, size: 20, color: Colors.white),
						radius: 18,
					),
					const SizedBox(width: 8),
					Container(
						padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
						decoration: BoxDecoration(
							color: Colors.grey[200],
							borderRadius: const BorderRadius.only(
								topLeft: Radius.circular(20),
								topRight: Radius.circular(20),
								bottomRight: Radius.circular(20),
								bottomLeft: Radius.circular(4),
							),
						),
						child: Row(
							mainAxisSize: MainAxisSize.min,
							children: List.generate(3, (index) {
								return FadeTransition(
									opacity: CurvedAnimation(
										parent: _typingIndicatorController,
										curve: Interval(index * 0.2, 1.0, curve: Curves.easeIn),
									),
									child: Padding(
										padding: const EdgeInsets.symmetric(horizontal: 2),
										child: CircleAvatar(
											backgroundColor: Colors.grey[500],
											radius: 5,
										),
									),
								);
							}),
						),
					),
				],
			),
		);
	}

	String _formatTimestamp(DateTime dt) {
		final hours = dt.hour.toString().padLeft(2, '0');
		final mins = dt.minute.toString().padLeft(2, '0');
		return '$hours:$mins';
	}
}
