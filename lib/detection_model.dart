import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(ChatApp());
}

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  List<String> chatPrompts = [];
  List<String> chatResponses = [];
  TextEditingController _promptController = TextEditingController();

  Future<String> getAIResponse(String prompt) async {
    String apiKey = '856dd221f9347d1deabe530c19b33268';
    String apiUrl = 'https://ws.detectlanguage.com/0.2/detect';

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $apiKey'},
      body: jsonEncode({
        'q': prompt,
        }),
    );

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      return jsonResponse['data']['detections'][0]['language'];
    } else {
      throw Exception('Failed to get AI response');
    }
  }

  void _addPrompt() async {
    String prompt = _promptController.text;
    String response = await getAIResponse(prompt);

    setState(() {
      chatPrompts.add(prompt);
      chatResponses.add(response);
      _promptController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Window'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: chatPrompts.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Prompt: ${chatPrompts[index]}'),
                  subtitle: Text('Response: ${chatResponses[index]}'),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Enter prompt',
                    ),
                  ),
                ),
                SizedBox(width: 16.0),
                ElevatedButton(
                  onPressed: _addPrompt,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
