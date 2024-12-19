import 'package:daoldiag/service/openai_service.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const HomeForm(),
    );
  }
}

class HomeForm extends StatefulWidget {
  const HomeForm({super.key});

  @override
  State<HomeForm> createState() => _HomeFormState();
}

class _HomeFormState extends State<HomeForm> {
  final TextEditingController _textController = TextEditingController();
  String _response = '';

  Future<void> _getAnswer() async {
    String question = _textController.text;
    String answer = await OpenaiService.sendQuestion(question);
    setState(() {
      _response = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('DaolDiag'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
              controller: _textController,
            ),
            ElevatedButton(
                onPressed: _getAnswer,
                child: Text('send question'),
            ),
            Text('==Answer=='),
            Text(_response),
          ],
        ),
      ),
    );
  }
}
