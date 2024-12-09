import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/models/admin_request_model.dart';
import 'package:glucocare/repositories/admin_request_repository.dart';

class AdminRequestInfoPage extends StatelessWidget {
  const AdminRequestInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminRequestInfoForm();
  }
}

class AdminRequestInfoForm extends StatefulWidget {
  const AdminRequestInfoForm({super.key});

  @override
  State<AdminRequestInfoForm> createState() => _AdminRequestInfoFormState();
}

class _AdminRequestInfoFormState extends State<AdminRequestInfoForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _adminRequest() async {
    await AdminRequestRepository.insertAdminRequest();
    Fluttertoast.showToast(msg: '관리자 계정 신청이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT);
    Navigator.pop(context);
  }

  Future<void> _adminRquestCancel() async {
    await AdminRequestRepository.deleteAdminRequest();
    Fluttertoast.showToast(msg: '관리자 계정 신청이 취소되었습니다.', toastLength: Toast.LENGTH_SHORT);
    Navigator.pop(context);
  }

  bool _isApplied = false;
  void _checkApply() async {
    AdminRequestModel? tempCheck = await AdminRequestRepository.selectAdminRequest();
    setState(() {
      if(tempCheck != null) _isApplied = true;
    });
  }

  @override
  void initState() {
    super.initState();
    _checkApply();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '관리자 계정 신청 정보',
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
              if(_isApplied)
              const Center(
                child: Text(
                  '관리자 계정 심사 중...',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              if(!_isApplied)
                const Center(
                  child: Text(
                    '관리자 계정이 아닙니다.\n관리자 계정을 신청해주세요.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if(_isApplied)
              Center(
                child: ElevatedButton(
                  onPressed: _adminRequest,
                  child: const Text('신청하기'),
                ),
              ),
              if(!_isApplied)
                Center(
                  child: ElevatedButton(
                    onPressed: _adminRquestCancel,
                    child: const Text('신청 취소하기'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}