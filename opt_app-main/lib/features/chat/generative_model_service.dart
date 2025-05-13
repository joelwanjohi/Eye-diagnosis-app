import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final generativeChatServiceProvider = Provider<GenerativeChatService>((ref) {
  return GenerativeChatService();
});

class GenerativeChatService {
  late final GenerativeModel model;
  late final ChatSession chat;

  GenerativeChatService() {
    // Use API key directly
    final apiKey = 'AIzaSyC0mgALAiYmKS40QXu7dSX9tyEtoj1TY24';

    // Initialize the model
    model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      apiKey: apiKey,
    );

    // Start a chat session with system prompt
    chat = model.startChat(
      history: [
        Content.text(
            "You are an eye health assistant. Only answer questions related to ophthalmology, eye conditions, diagnoses, and vision health. "
            "If asked about anything else, politely redirect the conversation back to eye health topics. "
            "Be helpful, clear, and educational when discussing eye health.")
      ],
    );
  }

  Future<String> sendMessage(String message) async {
    try {
      // Send the message
      var content = Content.text(message);
      var response = await chat.sendMessage(content);

      return response.text ?? "No response received";
    } catch (e) {
      print("Error details: $e");
      return "Error connecting to the AI service. Please check your internet connection and try again.";
    }
  }
}
