import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

import 'generative_model_view_model.dart';

class ChatView extends ConsumerWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatMessages = ref.watch(chatProvider);
    final isLoading = ref.watch(isLoadingProvider);
    final scrollController = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Eye Health Assistant'),
        backgroundColor: const Color.fromARGB(255, 17, 134, 22),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                itemCount: chatMessages.length + (isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isLoading && index == chatMessages.length) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.deepPurple[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TypingIndicator(),
                      ),
                    );
                  }

                  final message = chatMessages[index];
                  final isUserMessage = message.isUser;

                  return Align(
                    alignment: isUserMessage
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 14),
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8,
                      ),
                      decoration: BoxDecoration(
                        color: isUserMessage
                            ? Colors.lightBlue[100]
                            : Colors.deepPurple[100],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isUserMessage
                          ? Text(
                              message.text,
                              style: TextStyle(
                                color: Colors.black,
                                height: 1.3,
                              ),
                            )
                          : MarkdownBody(
                              data: message.text,
                              styleSheet: MarkdownStyleSheet(
                                p: TextStyle(
                                  color: Colors.black,
                                  height: 1.3,
                                  fontSize: 14,
                                ),
                                strong: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                em: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Colors.black,
                                ),
                                listBullet: TextStyle(
                                  color: Colors.black,
                                ),
                              ),
                              selectable: true,
                            ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[200],
                        hintText: 'Ask about eye health...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          ref.read(chatProvider.notifier).sendMessage(text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                  SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 17, 134, 22),
                    child: IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      onPressed: () {
                        if (_controller.text.isNotEmpty) {
                          ref
                              .read(chatProvider.notifier)
                              .sendMessage(_controller.text);
                          _controller.clear();
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2300),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            SizedBox(width: 4),
            _buildDot(1),
            SizedBox(width: 4),
            _buildDot(2),
          ],
        );
      },
    );
  }

  Widget _buildDot(int index) {
    double offset = index * 0.4;
    double animationValue = ((_controller.value + offset) % 1.0);

    double opacity = animationValue < 0.6
        ? animationValue / 0.6
        : (1 - animationValue) / 0.4;
    double size = 8 + (4 * opacity);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.5 * opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
