import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';

class OpenaiService {
  static Logger logger = Logger();

  static Future<String> sendQuestion(String question) async {
    const String apiUrl = "https://api.openai.com/v1/chat/completions";

    await dotenv.load(fileName: 'assets/config/.env');
    String? openai_key = await dotenv.env['OPENAI_KEY'];

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Authorization": "Bearer $openai_key",
          "Content-Type" : "application/json"
        },
        body: jsonEncode({
          "model" : "gpt-3.5-turbo",
          "messages" : [{"role" : "user", "content" : question,}],
        }),
      );

      if(response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Error: ${response.reasonPhrase}, ${response.body}';
      }
    } catch(e) {
        return 'Error: $e';
    }
  }
}