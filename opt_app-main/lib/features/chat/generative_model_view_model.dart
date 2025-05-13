import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'generative_model_service.dart';

final isLoadingProvider = StateProvider<bool>((ref) => false);

final chatProvider =
    StateNotifierProvider<ChatViewModel, List<ChatMessage>>((ref) {
  return ChatViewModel(ref);
});

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({required this.text, required this.isUser});
}

class ChatViewModel extends StateNotifier<List<ChatMessage>> {
  final StateNotifierProviderRef _ref;

  ChatViewModel(this._ref)
      : super([
          ChatMessage(
            text:
                "Hello! I'm your eye health assistant. Ask me anything about eye conditions, diagnoses, treatments, or general vision health questions.",
            isUser: false,
          ),
        ]);

  Future<void> sendMessage(String message) async {
    state = [...state, ChatMessage(text: message, isUser: true)];

    _ref.read(isLoadingProvider.notifier).state = true;

    try {
      final response =
          await _ref.read(generativeChatServiceProvider).sendMessage(message);

      state = [...state, ChatMessage(text: response, isUser: false)];
    } catch (e) {
      state = [
        ...state,
        ChatMessage(
          text:
              "I can only assist with eye health topics. Please ask me about eye conditions or vision health.",
          isUser: false,
        )
      ];
    } finally {
      _ref.read(isLoadingProvider.notifier).state = false;
    }
  }
}
