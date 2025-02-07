import 'package:aligo_app/main.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = false;
  final Logger logger = Logger();
  String _currentUserEmail = '';
  String _currentUserUid = '';

  // 현제 사용자 이메일, uid 가져오기
  Future<void> _getUserInfo() async {
    String email = await AuthService.getCurrentUserEmail();
    String uid = await AuthService.getCurrentUserUid();
    logger.d('aligo-log $email $uid');

    setState(() {
      _currentUserEmail = email;
      _currentUserUid = uid;
    });
  }

  // 이메일 인증 확인
  Future<void> _verifyEmailAuth() async {
    bool isVerifyed = await AuthService.verifyEmail();
    if(!isVerifyed) {
      Fluttertoast.showToast(msg: '이메일 인증을 완료한 후 다시 로그인해 주세요.', toastLength: Toast.LENGTH_LONG);
      AuthService.sendVeifyEmail();
      AuthService.logout();
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
    } else {
      Fluttertoast.showToast(msg: '인증된 사용자', toastLength: Toast.LENGTH_SHORT);
    }
  }

  // 로그아웃
  Future<void> _logout() async {
    await AuthService.logout();
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> _initStatesByAsync() async {
    setState(() {
      _isLoading = true;
    });

    await _verifyEmailAuth();
    await _getUserInfo();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _initStatesByAsync();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return Center(child: CircularProgressIndicator(color: Color(0xff00a99d),),);
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Center(
                child: Text(_currentUserEmail.toString()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('home'),
      ),
    );
  }
}
