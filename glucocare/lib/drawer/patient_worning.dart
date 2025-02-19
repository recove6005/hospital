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

  Future<void> _loadSeachPurseWorningPatient(String? input) async {
    List<PurseDangerModel> models = await PurseDangerRepository.selectAllDanger();
    for(PurseDangerModel model in models) {
      UserModel? patient = await UserRepository.selectUserBySpecificUid(model.uid);
      if(patient != null && patient.name.contains(input!)) {
        _pursePatients.add(patient);
      }
    }
    setState(() {
      _purseWornings = models;
    });
  }

  Future<void> _loadSearchGlucoWorningPatient(String? input) async {
    List<GlucoDangerModel> models = await GlucoDangerRepository.selectAllDanger();
    for(GlucoDangerModel model in models) {
      UserModel? patient = await UserRepository.selectUserBySpecificUid(model.uid);
      if (patient != null && patient.name.contains(input!)) {
        _glucoPatients.add(patient);
      }
    }
    setState(() {
      _glucoWornings = models;
    });
  }

  void _searchWorningPatientByName(String? input) async {
    await _loadSeachPurseWorningPatient(input);
    await _loadSearchGlucoWorningPatient(input);
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
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          minHeight: MediaQuery.of(context).size.height,
        ),
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
            if(_page) SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 50,
              child: const Text('혈당 위험 수치 내역', style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),),
            ),
            if(!_page) SizedBox(
              width: MediaQuery.of(context).size.width - 50,
              height: 50,
              child: const Text('혈압 위험 수치 내역', style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),),
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Container(
            //     padding: EdgeInsets.zero,
            //     width: MediaQuery.of(context).size.width - 50,
            //     height: 50,
            //     child: TextField(
            //       controller: _nameController,
            //       onChanged: _searchWorningPatientByName,
            //       decoration: const InputDecoration(
            //           prefixIcon: Icon(Icons.search),
            //           filled: true,
            //           fillColor: Color(0xfff9f9f9),
            //           border: InputBorder.none,
            //           hintText: '회원 이름',
            //           hintStyle: TextStyle(
            //             fontSize: 18,
            //             color: Colors.grey,
            //           )
            //       ),
            //       style: const TextStyle(
            //         fontSize: 18,
            //       ),
            //       textAlign: TextAlign.start,
            //       textAlignVertical: TextAlignVertical.center,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20,),
            if(_page)
              Align(
                alignment: Alignment.center,
                child: Container(
                  padding: EdgeInsets.zero,
                  width: MediaQuery.of(context).size.width - 50,
                  height: _glucoWornings.length.toInt() * 150,
                  decoration: const BoxDecoration(
                      color: Colors.white
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _glucoWornings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: const Color(0xfff4f4f4),
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                        child: ListTile(
                          leading: const Icon(Icons.account_box),
                          title: Text('${_glucoPatients[index].name} (${_glucoPatients[index].gen})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5,),
                              const Text('측정 일시', style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(DateFormat('yyyy년 MM월 dd일 a hh시 mm분').format(_glucoWornings[index].checkTime.toDate().toLocal())),
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
                                  Text('${_glucoWornings[index].checkTimeName} ${_glucoWornings[index].value}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),),
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
                  width: MediaQuery.of(context).size.width - 50,
                  decoration: const BoxDecoration(
                      color: Colors.white
                  ),
                  child: ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _purseWornings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        color: const Color(0xfff4f4f4),
                        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                        child: ListTile(
                          leading: const Icon(Icons.account_box),
                          title: Text('${_pursePatients[index].name} (${_pursePatients[index].gen})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 5,),
                              const Text('측정 일시', style: TextStyle(fontWeight: FontWeight.bold),),
                              Text(DateFormat('yyyy년 MM월 dd일 a hh시 mm분').format(_purseWornings[index].checkTime.toDate())),
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
            const SizedBox(height: 100,),
          ],
        ),
      ),
    );
  }
}

