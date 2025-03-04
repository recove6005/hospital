import 'package:aligo_app/repo/project_repo.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../model/project_model.dart';

class LogoCommissionPage extends StatefulWidget {
  const LogoCommissionPage({super.key});

  @override
  State<LogoCommissionPage> createState() => _LogoCommissionPageState();
}

class _LogoCommissionPageState extends State<LogoCommissionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _corpController = TextEditingController();
  final TextEditingController _callController = TextEditingController();
  final TextEditingController _emailContoller = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  // call TextField formater
  void _formatCallNumber() {
    String rawCallText = _callController.text.replaceAll(RegExp(r'[^0-9]'), '');
    if(rawCallText.length > 11) {
      rawCallText = rawCallText.substring(0, 11);
    }

    String formattedText = _applyPhoneNumberFormat(rawCallText);

    if(_callController.text != formattedText) {
      _callController.value = TextEditingValue(
        text: formattedText,
        selection: TextSelection.collapsed(offset: formattedText.length),
      );
    }

  }
  String _applyPhoneNumberFormat(String numbers) {
    if (numbers.length <= 3) return numbers;
    if (numbers.length <= 6) return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
    if (numbers.length > 6 && numbers.length <= 10) return '${numbers.substring(0, 3)}-${numbers.substring(3, 6)}-${numbers.substring(6)}';
    if (numbers.length > 10) return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
    return numbers;
  }

  // Textfield 컨트롤러 문자열 체크
  bool _checkTextFieldStrings() {
    // 빈문자열 체크
    Map<String, TextEditingController> fields = {
      '성함을 입력해 주세요.': _nameController,
      '업체명을 입력해 주세요.': _corpController,
      '연락처를 입력해 주세요.': _callController,
      '문의내용을 입력해 주세요.': _contentController,
    };

    for(var entry in fields.entries) {
      if(entry.value.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 5),
                Text(entry.key, style: TextStyle(color: Colors.black)),
              ],
            ),
            backgroundColor: Colors.white,
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return false;
      }
    }
    return true;
  }

  Future<void> _submitCommission() async {
    // TextField 문자열 체크
    if(!_checkTextFieldStrings()) return;

    // 문의 접수 DB 로직
    int date = DateTime.now().toLocal().millisecondsSinceEpoch;
    String uid = await AuthService.getCurrentUserUid();
    String email = await AuthService.getCurrentUserEmail();
    ProjectModel newProjectModel = ProjectModel(
      call: _callController.text.trim(),
      date: date,
      details: _contentController.text,
      email: _emailContoller.text.trim(),
      name: _nameController.text.trim(),
      organization: _corpController.text,
      progress: '0',
      title: '로고디자인',
      uid: uid,
      userEmail: email,
    );
    await ProjectRepo.insertProject(newProjectModel);

    // 다이얼로그, 화면 전환
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          content: Text('프로젝트 문의가 접수되었습니다. 마이페이지에서 확인해 주세요.', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Color(0xff00a99d),
              ),
              onPressed: () {
                // 창 나가기
                Navigator.pop(dialogContext);
                Navigator.pop(context);
              },
              child: Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    _callController.addListener(_formatCallNumber);
    super.initState();
  }

  @override
  void dispose() {
    // 컨트롤러 dispose
    _nameController.dispose();
    _corpController.dispose();
    _callController.removeListener(_formatCallNumber);
    _callController.dispose();
    _emailContoller.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Image.asset('assets/images/aligo_logo.png', height: 30, fit: BoxFit.cover,),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
            Align(
              child: Text(
                '로고디자인',
                style: TextStyle(
                  color: Color(0xff00a99d),
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20,),
            CarouselSlider(
              options: CarouselOptions(
                height: 250,
                autoPlay: true,
                enlargeCenterPage: true,
                enableInfiniteScroll: true,
              ),
              items: <Widget>[ // display gallery 이미지들
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 200,
                  child: Image.asset('assets/images/commission_logo_display_0.png'),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 200,
                  child: Image.asset('assets/images/commission_logo_display_1.png'),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 200,
                  child: Image.asset('assets/images/commission_logo_display_2.png'),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 200,
                  child: Image.asset('assets/images/commission_logo_display_3.png'),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 45,
              child: TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'name',
                  labelStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  hintText: '성함',
                  hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 45,
              child: TextField(
                controller: _corpController,
                decoration: InputDecoration(
                  labelText: 'corp',
                  labelStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  hintText: '업체명',
                  hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 45,
              child: TextField(
                controller: _callController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                decoration: InputDecoration(
                  labelText: 'call',
                  labelStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  hintText: '연락처',
                  hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 45,
              child: TextField(
                controller: _emailContoller,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  hintText: '이메일',
                  hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20,),
            SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              child: TextField(
                controller: _contentController,
                maxLines: 10,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'content',
                  labelStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  hintText: '문의하실 내용을 기입해 주세요.',
                  hintStyle: const TextStyle(color: Color(0xffd4d4d4), fontSize: 18),
                  filled: true,
                  fillColor: const Color(0xfff4f4f4),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 130,)
          ],
        ),
      ),
      floatingActionButton:
      SizedBox(
        width: MediaQuery.of(context).size.width-50,
        child: FloatingActionButton(
          onPressed: _submitCommission,
          backgroundColor: Color(0xff00a99d),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 4,
          child: Text('문의하기', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
