import 'package:aligo_app/model/deposit_model.dart';
import 'package:aligo_app/model/project_model.dart';
import 'package:aligo_app/repo/deposit_repo.dart';
import 'package:aligo_app/repo/project_repo.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';

class MypageProjectDetailPage extends StatefulWidget {
  final String docId;
  const MypageProjectDetailPage({super.key, required this.docId});

  @override
  State<MypageProjectDetailPage> createState() => _MypageProjectDetailPageState();
}

class _MypageProjectDetailPageState extends State<MypageProjectDetailPage> {
  final Logger logger = Logger();
  bool _isLoading = false;

  TextEditingController _diposerContoller = TextEditingController();
  TextEditingController _accountNumberController = TextEditingController();

  // 프로젝트 진행 현황 설정
  String _progressName = '문의 접수';
  Future<void> _setProgressName() async {
    switch(project!.progress) {
      case '1' : _progressName = '작업 중'; break;
      case '2' : _progressName = '결제 중'; break;
      case '11': _progressName = '입금 확인 중'; break;
      case '3': _progressName = '결제 완료'; break;
      default: _progressName = '문의 접수';
    }
  }

  // 해당 프로젝트 가져오기
  ProjectModel? project;
  Future<void> _getProject() async {
    ProjectModel? model = await ProjectRepo.getProjectByDocId(widget.docId);
    setState(() {
      project = model;
    });
  }

  // 결제 다이얼로그
  void _showPaytypeDialog() {
    showDialog(
        context: context, 
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('결제 수단'),
            content: Container(
              width: MediaQuery.of(context).size.width-200,
              height: MediaQuery.of(context).size.height/7,
              child: Column(
                children: [
                  ListTile(
                    title: Text('수동 이체', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      setState(() {
                        _showPayDialog('수동 이체');
                      });
                    },
                  ),
                  ListTile(
                    title: Text('카카오페이', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
                    onTap: () {
                      Navigator.pop(dialogContext);
                      setState(() {
                        _showPayDialog('카카오페이');
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('취소'),
              ),
            ],
          );
        }
    );
  }

  // 무통장 입금 다이얼로그
  void _showPayDialog(String value) {
    if(value == '수동 이체') {
      showDialog(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: Text('수동 이체', style: TextStyle(color: Color(0xff232323), fontSize: 18,),),
            content: Container(
              width: MediaQuery.of(context).size.width-200,
              height: MediaQuery.of(context).size.height/7,
              child: Column(
                children: [
                  TextField(
                    controller: _diposerContoller,
                    decoration: InputDecoration(
                      label: Text('예금주'),
                      hintText: '예금주',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7,),
                  TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      label: Text('계좌번호'),
                      hintText: '계좌번호',
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('취소'),
              ),
              TextButton(
                  onPressed: () {
                    if(_diposerContoller.text.trim().isEmpty || _accountNumberController.text.trim().isEmpty) {
                      Fluttertoast.showToast(msg: '예금주와 계좌번호를 입력해 주세요.', toastLength: Toast.LENGTH_SHORT);
                    } else {
                      // 수동이체 정보 DB등록
                      DepositModel model = DepositModel(
                          docId: widget.docId,
                          owner: _diposerContoller.text.trim(),
                          actNum: _accountNumberController.text.trim(),
                      );
                      DepositRepo.addDepositInfo(model, widget.docId);

                      // 프로젝트 진행현황 정보 업데이트 -> 11
                      ProjectRepo.updateProgressTo11(widget.docId.toString());

                      Navigator.pop(context);
                      Navigator.pop(dialogContext);
                      Fluttertoast.showToast(msg: '입금 금액을 확인하고 있습니다.', toastLength: Toast.LENGTH_SHORT);
                    }
                  },
                  child: Text('확인'),
              ),
            ],
          );
        }
      );
    }


  }
  
  void _initAsyncState() async {
    setState(() {
      _isLoading = true;
    });

    await _getProject();
    await _setProgressName();

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
  void dispose() {
    super.dispose();
    _diposerContoller.dispose();
    _accountNumberController.dispose();
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
            const SizedBox(
              height: 20,
            ),
            // 프로젝트 타이틀
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: Row(
                  children: [
                    Icon(Icons.rectangle, color: Color(0xff00a99d), size: 15,),
                    const SizedBox(width: 5,),
                    Text(project!.title, style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            // 프로젝트 진행 현황
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width - 50,
                height: 40,
                decoration: BoxDecoration(
                  color: Color(0xff00a99d),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(_progressName, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),),
                ),
              ),
            ),
            // 프로젝트 정보
            Align(
              child: Padding(
                padding: EdgeInsets.all(25),
                child: Column(
                  children: [
                    Row( // 성함
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('성함', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('${project!.name}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    Row( // 업체명
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('업체명', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('${project!.organization}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    Row( // 연락처
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('연락처', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('${project!.call}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    Row( // 이메일
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('이메일', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('${project!.email}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                    Row( // 문의 내용
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('문의내용', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('${project!.details}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
                        ),
                      ],
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width-50,
                      height: 1,
                      margin: EdgeInsets.symmetric(vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // 버튼 - 결제하기
            if(_progressName == '결제 중')
              SizedBox(
                width: MediaQuery.of(context).size.width-50,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00a99d),
                  ),
                  onPressed: () {
                    _showPaytypeDialog();
                  },
                  child: Text('결제하기', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                ),
              ),
            // 버튼 - 수동이체 결제 확인 중
            if(_progressName == '입금 확인 중')
              SizedBox(
                width: MediaQuery.of(context).size.width-50,
                height: 100,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('입금 확인 중', style: TextStyle(color: Color(0xff00a99d), fontSize: 20, fontWeight: FontWeight.bold),),
                    Text('입금처 00은행 00-0000', style: TextStyle(color: Color(0xff00a99d), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            // 버튼 - 파일 다운로드
            if(_progressName == '결제완료')
              SizedBox(
                width: MediaQuery.of(context).size.width-50,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff00a99d),
                  ),
                  onPressed: () {

                  },
                  child: Text('파일 다운로드', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),),
                ),
              ),
            const SizedBox(
              height: 100,
            ),
          ],
        ),
      ),
    );
  }
}
