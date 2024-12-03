import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/repositories/notice_board_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../../models/notice_board_model.dart';

class NoticeBoardPage extends StatelessWidget {
  const NoticeBoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지사항', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const NoticeBoardForm(),
    );
  }
}

class NoticeBoardForm extends StatefulWidget {
  const NoticeBoardForm({super.key});

  @override
  State<NoticeBoardForm> createState() => _NoticeBoardFormState();
}

class _NoticeBoardFormState extends State<NoticeBoardForm> {
  Logger logger = Logger();
  List<NoticeBoardModel> notices = [];
  bool _isLoading = true;

  Future<void> _setStates() async {
    List<NoticeBoardModel> models = await NoticeBoardRepository.selectAllNoticies();
    setState(() {
      notices = models;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setStates();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height - 150,
        child: ListView.builder(
          itemCount: notices.length, // 공지사항 개수
          itemBuilder: (context, index) {
            return Container(
              width: 300,
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(
                    bottom: BorderSide(
                      width: 1,
                      color: Colors.grey,
                    )
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notices[index].title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      DateFormat('yyyy년 MM월 dd일 HH:mm').format(notices[index].datetime.toDate()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      notices[index].content,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
