import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/services/auth_service.dart';

class AdminRequestPage extends StatelessWidget {
  const AdminRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminRequestForm();
  }
}

class AdminRequestForm extends StatefulWidget {
  const AdminRequestForm({super.key});

  @override
  State<AdminRequestForm> createState() => _AdminRequestFormState();
}

class _AdminRequestFormState extends State<AdminRequestForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _submitRequest() async {
    final title = _titleController.text;
    final content = _contentController.text;

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('제목과 내용을 입력해주세요.')),
      );
      return;
    }

    _titleController.clear();
    _contentController.clear();

    String? uid = '';
    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
    }

    if(uid != null) {

    }

    Fluttertoast.showToast(msg: '관라자 계정 신청이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '관리자 계정 신청',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: '내용',
                  floatingLabelBehavior: FloatingLabelBehavior.always,
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                maxLines: 15, // 여러 줄 입력 가능
                textAlign: TextAlign.start,
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: const Text('작성하기'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}