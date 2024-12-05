import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/notice_board_model.dart';
import 'package:glucocare/repositories/notice_board_repository.dart';
import 'package:glucocare/services/auth_service.dart';

class NoticePostingPage extends StatelessWidget {
  const NoticePostingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NoticePostingForm();
  }
}

class NoticePostingForm extends StatefulWidget {
  const NoticePostingForm({super.key});

  @override
  State<NoticePostingForm> createState() => _NoticePostingFormState();
}

class _NoticePostingFormState extends State<NoticePostingForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _submitPost() async {
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('공지사항 게시글이 작성되었습니다.')),
    );

    String? uid = '';
    if(await AuthService.userLoginedFa()) {
      uid = AuthService.getCurUserUid();
    } else {
      uid = await AuthService.getCurUserId();
    }
    if(uid != null) {
      NoticeBoardModel model = NoticeBoardModel(uid: uid, title: title, content: content, datetime: Timestamp.now());
      NoticeBoardRepository.insertBoard(model);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '공지사항 작성',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: '내용',
                border: OutlineInputBorder(),
              ),
              maxLines: 10, // 여러 줄 입력 가능
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitPost,
                child: const Text('작성하기'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}