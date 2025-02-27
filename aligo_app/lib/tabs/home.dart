import 'package:aligo_app/main.dart';
import 'package:aligo_app/services/auth_service.dart';
import 'package:aligo_app/tabs/drawer/mypage.dart';
import 'package:aligo_app/tabs/drawer/project_management.dart';
import 'package:aligo_app/tabs/pages/commission_banner.dart';
import 'package:aligo_app/tabs/pages/commission_blog.dart';
import 'package:aligo_app/tabs/pages/commission_draft.dart';
import 'package:aligo_app/tabs/pages/commission_hompage.dart';
import 'package:aligo_app/tabs/pages/commission_instagram.dart';
import 'package:aligo_app/tabs/pages/commission_logo.dart';
import 'package:aligo_app/tabs/pages/commission_naverplace.dart';
import 'package:aligo_app/tabs/pages/commission_signage.dart';
import 'package:aligo_app/tabs/pages/commission_video.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import '../repo/user_repo.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool _isLoading = false;
  final Logger logger = Logger();

  // 유저 정보 변수
  String _currentUserEmail = '';
  String _currentUserUid = '';


  // 현재 사용자 이메일, uid 가져오기
  Future<void> _getUserInfo() async {
    String email = await AuthService.getCurrentUserEmail();
    String uid = await AuthService.getCurrentUserUid();

    setState(() {
      _currentUserEmail = email;
      _currentUserUid = uid;
    });
  }

  // 어드민 계정 체크
  bool _isAdmin = false;
  Future<void> _checkAdmin() async {
    bool isAdmin = await UserRepo.checkAdmin();
    setState(() {
      _isAdmin = isAdmin;
    });
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

    await _getUserInfo();
    await _checkAdmin();

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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Image.asset('assets/images/aligo_logo.png', height: 30, fit: BoxFit.cover,),
        centerTitle: true,
      ),
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
              leading: Icon(Icons.manage_accounts),
              title: Text('마이페이지'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MypagePage()));
              },
            ),
            if(_isAdmin)
            ListTile(
              leading: Icon(Icons.folder),
              title: Text('프로젝트 관리'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.card_membership),
              title: Text('구독권 구매'),
              onTap: () {

              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('로그아웃'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 20,),
            Text('Services', style: TextStyle(fontSize: 30, color: Color(0xff00a99d), fontWeight: FontWeight.bold),),
            const SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width/2-20,
                  margin: EdgeInsets.all(3),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          Image.asset('assets/images/aligo_services2.png'),
                          Positioned.fill(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomepageCommissionPage()));
                                },
                                splashColor: Color(0xff00a99d).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text('홈페이지', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                    ],
                  )
                ),
                const SizedBox(width: 10,),
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services3.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => LogoCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('로고디자인', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services4.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BlogCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('블로그 포스팅', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
                const SizedBox(width: 10,),
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services5.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>InstagramCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('인스타그램 홍보', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services6.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>NaverplaceCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('네이버 플레이스', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
                const SizedBox(width: 10,),
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services7.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>DraftCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('원내시안 및 단순디자인', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services8.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignageCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('디지털 사이니지', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
                const SizedBox(width: 10,),
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services9.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context)=>BannerCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('웹 배너', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/images/aligo_services9.png'),
                            Positioned.fill(
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => VideoCommissionPage()));
                                  },
                                  splashColor: Color(0xff00a99d).withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text('홍보영상 편집/제작', style: TextStyle(fontSize: 18, color: Color(0xff232323)),),
                      ],
                    )
                ),
                const SizedBox(width: 10,),
                Container(
                    width: MediaQuery.of(context).size.width/2-20,
                    margin: EdgeInsets.all(3),
                    child: Column(
                      children: [
                        
                      ],
                    )
                ),
              ],
            ),
            // 하단 빈 공간
            const SizedBox(height: 150,),
          ],
        ),
      ),
    );
  }
}


