import 'package:aligo_app/model/project_model.dart';
import 'package:aligo_app/repo/price_repo.dart';
import 'package:aligo_app/repo/project_repo.dart';
import 'package:aligo_app/repo/subscribe_repo.dart';
import 'package:aligo_app/tabs/drawer/pages/mypage_project_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../../model/price_model.dart';
import '../../model/subscribe_model.dart';

class MypagePage extends StatefulWidget {
  const MypagePage({super.key});

  @override
  State<MypagePage> createState() => _MypagePageState();
}

class _MypagePageState extends State<MypagePage> {
  final Logger logger = Logger();
  bool _isLoading = false;

  // 유저 정보 변수
  SubscribeModel? _subscribeModel = null;
  List<ProjectModel> _projectModels = [];
  List<PriceModel> _payedPriceModels = [];

  // 구독 정보 가져오기
  Future<void> _getMySubscribeInfo() async {
    SubscribeModel? model = await SubscribeRepo.getSubscribeInfo();
    setState(() {
      _subscribeModel = model;
    });
  }

  // 결제 완료된 프로젝트 가져오기
  Future<void> _getMyPayedProjects() async {
    List<PriceModel> models = await PriceRepo.getPayedPriceModels(5);
    setState(() {
      _payedPriceModels = models;
    });
  }

  // 프로젝트 내역 가져오기
  Future<void> _getMyProjects() async {
    List<ProjectModel> models = await ProjectRepo.selectMyProjects();
    setState(() {
      _projectModels = models;
    });
  }

  // 프로젝트 진행 아이콘 설정 문자열
  IconData _getProgressIconName(index) {
    IconData iconName = Icons.mark_email_read;
    switch(_projectModels[index].progress) {
      case '0': iconName = Icons.mark_email_unread; break;
      case '1': iconName = Icons.hourglass_empty; break;
      case '2': iconName = Icons.attach_money; break;
      case '11': iconName = Icons.attach_money; break;
      case '3': iconName = Icons.done; break;
    }
    return iconName;
  }

  Future<void> _initAsyncState() async {
    setState(() {
      _isLoading = true;
    });

    await _getMySubscribeInfo();
    await _getMyPayedProjects();
    await _getMyProjects();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _initAsyncState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        title: Image.asset('assets/images/aligo_logo.png', height: 30, fit: BoxFit.cover,),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 구독 정보
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: Row(
                  children: [
                    Icon(Icons.rectangle, color: Color(0xff00a99d), size: 15,),
                    const SizedBox(width: 5,),
                    Text('구독 정보', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: 330,
                decoration: BoxDecoration(
                  color: Color(0xfff4f4f4),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if(_subscribeModel?.type == '0')
                        const SizedBox(height: 100,),
                      if(_subscribeModel?.type == '0')
                        Text('구독 내역이 없습니다.', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type == '0')
                        const SizedBox(height: 100,),
                      if(_subscribeModel?.type != '0')
                        Text('홈페이지 제작: ${_subscribeModel?.homepage}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('로고디자인: ${_subscribeModel?.logo}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('네이버 블로그: ${_subscribeModel?.blog}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('인스타그램: ${_subscribeModel?.instagram}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('네이버 플레이스: ${_subscribeModel?.naverplace}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('원내시안 및 단순디자인: ${_subscribeModel?.draft}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('디지털 사이니지: ${_subscribeModel?.signage}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('웹 배너: ${_subscribeModel?.banner}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                      if(_subscribeModel?.type != '0')
                        Text('홍보영상 편집/제작: ${_subscribeModel?.video}회', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30,),
            // 결제 내역
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Icon(Icons.rectangle, color: Color(0xff00a99d), size: 15,),
                    const SizedBox(width: 5,),
                    Text('최근 결제 내역', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: _payedPriceModels.length * 80,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _payedPriceModels.length,
                    itemBuilder: (context, index) {
                        return ListTile(
                          leading: Icon(Icons.credit_card),
                          title: Text('${_payedPriceModels[index].title}', style: TextStyle(color: Color(0xff232323), fontSize: 18),),
                          subtitle: Text(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(_payedPriceModels[index].date).toLocal())),
                        );
                    }
                ),
              ),
            ),
            const SizedBox(height: 20,),
            // 프로젝트 내역
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: Row(
                  children: [
                    Icon(Icons.rectangle, color: Color(0xff00a99d), size: 15,),
                    const SizedBox(width: 5,),
                    Text('문의 내역', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: _projectModels.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onTap: () {
                          String docId = _projectModels[index].docId;
                          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MypageProjectDetailPage(docId: docId)));
                        },
                        leading: Icon(_getProgressIconName(index)),
                        title: Text('${_projectModels[index].title}', style: TextStyle(color: Color(0xff232323), fontSize: 18),),
                        subtitle: Text(DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(_projectModels[index].date).toLocal())),
                      );
                    }
                ),
              ),
            ),
            const SizedBox(height: 100,)
          ],
        ),
      ),
    );
  }
}
