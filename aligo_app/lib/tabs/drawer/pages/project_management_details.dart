import 'package:aligo_app/model/deposit_model.dart';
import 'package:aligo_app/model/price_model.dart';
import 'package:aligo_app/model/project_model.dart';
import 'package:aligo_app/repo/deposit_repo.dart';
import 'package:aligo_app/repo/price_repo.dart';
import 'package:aligo_app/repo/project_repo.dart';
import 'package:aligo_app/tabs/drawer/project_management.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

class ProjectManagementDetailsPage extends StatefulWidget {
  final ProjectModel model;
  const ProjectManagementDetailsPage({super.key, required this.model});

  @override
  State<ProjectManagementDetailsPage> createState() => _ProjectManagementDetailsPageState();
}

class _ProjectManagementDetailsPageState extends State<ProjectManagementDetailsPage> {
  final Logger logger = Logger();
  bool _isLoading = false;

  final TextEditingController _payRequestController = TextEditingController();

  // 프로젝트 진행 현황 설정
  String _progressName = '문의 접수';
  Future<void> _setProgressName() async {
    switch(widget.model.progress) {
      case '1' : _progressName = '작업 중'; break;
      case '2' : _progressName = '결제 중'; break;
      case '11': _progressName = '입금 확인 중'; break;
      case '3': _progressName = '결제 완료'; break;
      default: _progressName = '문의 접수';
    }
  }

  // 프로젝트 가격 정보 가져오기
  String _price = '---';
  Future<void> _getPriceInfo() async {
    PriceModel? model = await PriceRepo.getPriceModelByDocId(widget.model.docId);
    setState(() {
      if(model != null) {
        _price = model.price;
      }
    });
  }

  // 프로젝트 입금 정보 가져오기
  String _actNum = '---';
  String _owner = '---';
  Future<void> _getDepositInfo() async {
    DepositModel? model = await DepositRepo.getDepositInfoByDocId(widget.model.docId);
    setState(() {
      if(model != null) {
        _actNum = model.actNum;
        _owner = model.owner;
      }
    });
  }

  void _initAsyncState() async {
    setState(() {
      _isLoading = true;
    });

    await _setProgressName();
    await _getPriceInfo();
    await _getDepositInfo();

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
    _payRequestController.dispose();
    super.dispose();
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
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
          return false;
        },
        child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30,),
            // 구독 정보
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                height: 50,
                child: Row(
                  children: [
                    Icon(Icons.rectangle, color: Color(0xff00a99d), size: 15,),
                    const SizedBox(width: 5,),
                    Text('${widget.model.title}', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
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
                          child: Text('${widget.model.name}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                          child: Text('${widget.model.organization}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                          child: Text('${widget.model.call}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                          child: Text('${widget.model.email}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                          child: Text('${widget.model.details}', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                    Row( // 가격
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('가격', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('$_price 원', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
                    Row( // 입금 정보
                      children: [
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 1 / 4,
                          child: Text('입금 정보', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                        ),
                        SizedBox(
                          width: (MediaQuery.of(context).size.width-50) * 3 / 4,
                          child: Text('$_owner $_actNum', style: TextStyle(color: Color(0xff232323), fontSize: 20),),
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
            if(_progressName == '문의 접수')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // 프로젝트 진행현황 -> 1
                      await ProjectRepo.updateProgressTo(widget.model.docId, '1');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00a99d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    child: Text('수락', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                  const SizedBox(width: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      // 프로젝트 삭제
                      await ProjectRepo.deleteProject(widget.model.docId);
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00a99d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    child: Text('거부', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            if(_progressName == '작업 중')
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: (MediaQuery.of(context).size.width-60)*3/5,
                    height: 45,
                    child: TextField(
                      controller: _payRequestController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text('요청 가격'),
                        labelStyle: TextStyle(color: Color(0xff00a99d), fontSize: 15),
                        filled: true,
                        fillColor: Color(0xffd4d4d4),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                  const SizedBox(width: 10,),
                  SizedBox(
                    width: (MediaQuery.of(context).size.width-70)*2/5,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 결과물 파일 업로드


                        // price 컬렉션 (, 표시 지운 후)
                        PriceModel model = PriceModel(
                            date: DateTime.now().toLocal().millisecondsSinceEpoch,
                            docId: widget.model.docId,
                            payed: false,
                            paytype: '-',
                            price: _payRequestController.text.trim(),
                            title: widget.model.title,
                            uid: widget.model.uid,
                        );
                        await PriceRepo.addPriceModel(model);

                        // 진행현황 -> 2
                        await ProjectRepo.updateProgressTo(widget.model.docId, '2');
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xff00a99d),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )
                      ),
                      child: Text('결제 요청', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                    ),
                  ),
                ],
              ),
            if(_progressName == '입금 확인 중')
              Column(
                children: [
                  // deposit 컬렉션 입금자 정보, 계좌 표시
                  Text(''),
                  Text(''),
                  ElevatedButton(
                    onPressed: () async {
                      // 프로젝트 현황 -> 3
                      await ProjectRepo.updateProgressTo(widget.model.docId, '3');
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ProjectManagementPage()));
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xff00a99d),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        )
                    ),
                    child: Text('입금 확인', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),),
                  ),
                ],
              ),
            const SizedBox(height: 100,),
          ],
        ),
      ),
      ),
    );
  }
}
