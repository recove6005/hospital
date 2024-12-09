import 'package:flutter/material.dart';
import 'package:glucocare/drawer/pages/patient_info.dart';
import 'package:glucocare/models/gluco_danger_model.dart';
import 'package:glucocare/models/purse_danger_model.dart';
import 'package:glucocare/repositories/gluco_danger_repository.dart';
import 'package:glucocare/repositories/purse_danger_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import '../models/user_model.dart';
import '../repositories/patient_repository.dart';

class PatientWorningPage extends StatelessWidget {
  const PatientWorningPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '위험 환자 관리',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      body: const PatientWorningForm(),
    );
  }
}

class PatientWorningForm extends StatefulWidget {
  const PatientWorningForm({super.key});

  @override
  State<PatientWorningForm> createState() => _PatientWorningFormState();
}

class _PatientWorningFormState extends State<PatientWorningForm> {
  Logger logger = Logger();
  bool _isPurseWornLoading = true;
  bool _isGlucoWornLoading = true;
  List<PurseDangerModel> _purseWornings = [];
  final List<UserModel> _pursePatients = [];
  List<GlucoDangerModel> _glucoWornings = [];
  final List<UserModel> _glucoPatients = [];

  final List<UserModel> _searchModels = [];
  final TextEditingController _nameController = TextEditingController();

  bool _page = true; // true: gluco, false: purse

  void _loadPurseWorningPatient() async {
    List<PurseDangerModel> models = await PurseDangerRepository.selectAllDanger();
    for(PurseDangerModel model in models) {
      UserModel? patient = await UserRepository.selectUserBySpecificUid(model.uid);
      if(patient != null) _pursePatients.add(patient);
    }
    setState(() {
      _purseWornings = models;
      _isPurseWornLoading = false;
    });
  }

  void _loadGlucoWorningPatient() async {
    List<GlucoDangerModel> models = await GlucoDangerRepository.selectAllDanger();
    for(GlucoDangerModel model in models) {
      UserModel? patient = await UserRepository.selectUserBySpecificUid(model.uid);
      if(patient != null) _glucoPatients.add(patient);
    }
    setState(() {
      _glucoWornings = models;
      _isGlucoWornLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadGlucoWorningPatient();
    _loadPurseWorningPatient();
  }

  @override
  Widget build(BuildContext context) {
    if(_isGlucoWornLoading || _isPurseWornLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          SizedBox(
            width: 300,
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _page = true;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xD6EFC987),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xffE6B53D),
                          )
                      )
                  ),
                  child: const Text(
                    '혈당',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _page = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xffe37979),
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(
                            width: 1,
                            color: Color(0xffec6a6a),
                          )
                      )
                  ),
                  child: const Text(
                    '혈압',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20,),
          if(_page) const SizedBox(
            width: 350,
            height: 50,
            child: Text('혈당 관리 환자 목록', style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),),
          ),
          if(!_page) const SizedBox(
            width: 350,
            height: 50,
            child: Text('혈압 관리 환자 목록', style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),),
          ),
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.zero,
              width: 350,
              height: 50,
              child: TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Color(0xfff9f9f9),
                    border: InputBorder.none,
                    hintText: '회원 이름',
                    hintStyle: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    )
                ),
                style: const TextStyle(
                  fontSize: 18,
                ),
                textAlign: TextAlign.start,
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
          const SizedBox(height: 20,),
          if(_page)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.zero,
                width: 350,
                height: 600,
                decoration: const BoxDecoration(
                    color: Colors.white
                ),
                child: ListView.builder(
                  itemCount: _glucoWornings.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                      child: ListTile(
                        leading: const Icon(Icons.account_box),
                        title: Text('${_glucoPatients[index].name} (${_glucoPatients[index].gen})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5,),
                            const Text('측정 일시', style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(DateFormat('yyyy년 MM월 dd일 a hh시 mm분', 'ko_KR').format(_glucoWornings[index].checkTime.toDate())),
                            const SizedBox(height: 5,),
                            Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const Text('측정 수치', style: TextStyle(fontWeight: FontWeight.bold),),
                            Row(
                              children: [
                                Text('${_glucoWornings[index].value}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
                                const Text(' mg/dL'),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PatientInfoPage(model: _glucoPatients[index])));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          if(!_page)
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.zero,
                width: 350,
                height: 600,
                decoration: const BoxDecoration(
                    color: Colors.white
                ),
                child: ListView.builder(
                  itemCount: _purseWornings.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                      child: ListTile(
                        leading: const Icon(Icons.account_box),
                        title: Text('${_pursePatients[index].name} (${_pursePatients[index].gen})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5,),
                            const Text('측정 일시', style: TextStyle(fontWeight: FontWeight.bold),),
                            Text(DateFormat('yyyy년 MM월 dd일 a hh시 mm분', 'ko_KR').format(_purseWornings[index].checkTime.toDate())),
                            const SizedBox(height: 5,),
                            Container(
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            const Text('측정 수치', style: TextStyle(fontWeight: FontWeight.bold),),
                            if(_purseWornings[index].shrinkDanger && _purseWornings[index].relaxDanger)
                              Row(
                                children: [
                                  Text('${_purseWornings[index].shrink}', style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                  const Text('/'),
                                  Text('${_purseWornings[index].relax}', style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                  const Text(' mmHg'),
                                ],
                              ),
                            if(_purseWornings[index].shrinkDanger && !_purseWornings[index].relaxDanger)
                              Row(
                                children: [
                                  Text('${_purseWornings[index].shrink}', style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                  const Text('/'),
                                  Text('${_purseWornings[index].relax}'),
                                  const Text(' mmHg'),
                                ],
                              ),
                            if(!_purseWornings[index].shrinkDanger && _purseWornings[index].relaxDanger)
                              Row(
                                children: [
                                  Text('${_purseWornings[index].shrink}',),
                                  const Text('/'),
                                  Text('${_purseWornings[index].relax}', style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.red),),
                                  const Text(' mmHg'),
                                ],
                              ),
                          ],
                        ),
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PatientInfoPage(model: _pursePatients[index])));
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          const SizedBox(height: 50,),
        ],
      ),
    );
  }
}

