import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class HomepageCommissionPage extends StatefulWidget {
  const HomepageCommissionPage({super.key});

  @override
  State<HomepageCommissionPage> createState() => _HomepageCommissionPageState();
}

class _HomepageCommissionPageState extends State<HomepageCommissionPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _corpController = TextEditingController();
  final TextEditingController _callController = TextEditingController();
  final TextEditingController _emailContoller = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  Future<void> _submitCommission() async {
    // 문의 접수 로직

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
                '홈페이지 제작',
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
                  child: Image.asset('assets/images/commission_homepage_display_0.png'),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - 50,
                  height: 200,
                  child: Image.asset('assets/images/commission_homepage_display_1.png'),
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
