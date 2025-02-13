import 'package:aligo_app/model/project_model.dart';
import 'package:aligo_app/repo/project_repo.dart';
import 'package:aligo_app/tabs/drawer/pages/project_management_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class ProjectManagementPage extends StatefulWidget {
  const ProjectManagementPage({super.key});

  @override
  State<ProjectManagementPage> createState() => _ProjectManagementPageState();
}

class _ProjectManagementPageState extends State<ProjectManagementPage> {
  final Logger logger = Logger();
  bool _isLoading = false;

  List<ProjectModel> _projectModels = [];

  // 전체 프로젝트 가져오기
  Future<void> _getAllProjects() async {
    List<ProjectModel> models = await ProjectRepo.selectAllProjects();
    setState(() {
      _projectModels = models;
    });
  }

  // 프로젝트 진행상황 위젯 반환
  Widget _getProgressName(ProjectModel model) {
    switch(model.progress) {
      case '1':
        return Container(
          width: 80,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff00a99d),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('작업중', style: TextStyle(color: Colors.white, fontSize: 15),),
        );
      case '2' :
        return Container(
          width: 80,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff00a99d),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('결제중', style: TextStyle(color: Colors.white, fontSize: 15),),
        );
      case '11' :
        return Container(
          width: 80,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff00a99d),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('입금확인중', style: TextStyle(color: Colors.white, fontSize: 15),),
        );
      case '3':
        return Container(
          width: 80,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff00a99d),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('결제완료', style: TextStyle(color: Colors.white, fontSize: 15),),
        );
      default:
        return Container(
          width: 80,
          height: 25,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xff00a99d),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text('문의접수', style: TextStyle(color: Colors.white, fontSize: 15),),
        );
    }
  }

  void _initAsyncSatate() async {
    setState(() {
      _isLoading = true;
    });

    await _getAllProjects();

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    _initAsyncSatate();
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
                    Text('프로젝트 관리', style: TextStyle(color: Color(0xff232323), fontSize: 20, fontWeight: FontWeight.bold),),
                  ],
                ),
              ),
            ),
            Align(
              child: SizedBox(
                width: MediaQuery.of(context).size.width - 50,
                child: ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _projectModels.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: Colors.grey, width: 1),
                          ),
                        ),
                        child: ListTile(
                          style: ListTileStyle.list,
                          onTap: () {
                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> ProjectManagementDetailsPage(model: _projectModels[index])));
                          },
                          leading: _getProgressName(_projectModels[index]),
                          title: Text('${_projectModels[index].title}', style: TextStyle(color: Color(0xff232323), fontSize: 18, fontWeight: FontWeight.bold),),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.apartment, size: 15,),
                                  const SizedBox(width: 5,),
                                  Text('${_projectModels[index].organization}', style: TextStyle(color: Color(0xff232323), fontSize: 16),),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.call, size: 15,),
                                  const SizedBox(width: 5,),
                                  Text('${_projectModels[index].call}', style: TextStyle(color: Color(0xff232323), fontSize: 16),),
                                ],
                              ),
                              Text('접수일자 ${DateFormat('yyyy-MM-dd').format(DateTime.fromMillisecondsSinceEpoch(_projectModels[index].date))}', style: TextStyle(color: Color(0xff232323), fontSize: 13),),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}
