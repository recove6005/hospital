import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/models/purse_model.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../models/patient_model.dart';
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
  List<PurseModel> _loadPurseWornings = [];
  List<GlucoModel> _loadGlucoWornings = [];

  bool _page = true; // true: gluco, false: purse

  void _loadPurseWorningPatient() async {
    // List<PurseModel> models = await PurseRepository.selectPurseWornings();
    // setState(() {
    //   _loadPurseWornings = models;
    //   _isPurseWornLoading = false;
    // });
  }

  void _loadGlucoWorningPatient() async {
    try {
      List<GlucoModel> models = await GlucoRepository.selectGlucoWornings();
      logger.d('[glucocare_log] gluco models: $models');
      if(mounted) {
        setState(() {
          _loadGlucoWornings = models;
          logger.d('[glucocare_log] load gluco wornings: $_loadGlucoWornings');
          _isGlucoWornLoading = false;
        });
      }
    } catch(e) {
      logger.e('[glucocare_log] Failed to load gluco wornings (_loadGlucoWoringPatient) : $e');
    }
  }

  Future<String> _getPatientName(String uid) async {
    PatientModel? model = await PatientRepository.selectPatientBySpecificUid(uid);
    return model!.name;
  }

  Future<String> _getPatientGen(String uid) async {
    PatientModel? model = await PatientRepository.selectPatientBySpecificUid(uid);
    return model!.gen;
  }

  Future<String> _getPatientBirth(String uid) async {
    PatientModel? model = await PatientRepository.selectPatientBySpecificUid(uid);
    String birth = DateFormat('yyyy년 MM월 dd일').format(model!.birthDate.toDate());
    return birth;
  }


  @override
  void initState() {
    super.initState();
    _loadGlucoWorningPatient();
    _loadPurseWorningPatient();
  }

  @override
  Widget build(BuildContext context) {
    if(_isGlucoWornLoading) return Center(child: CircularProgressIndicator(),);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [ // 서치 박스
        Container(
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
                child: Text('혈당'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _page = false;
                  });
                },
                child: Text('혈압'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10,),
        if(_page) Container(
          width: 300,
          height: 30,
          child: Text('혈당 관리 환자 목록'),
        ),
        if(_page)
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.zero,
            width: 350,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey
            ),
            child: ListView.builder(
              itemCount: _loadGlucoWornings.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                  child: ListTile(
                    leading: Icon(Icons.account_box),
                    title: Text('${_getPatientName(_loadGlucoWornings[index].uid).toString()} (${_getPatientGen(_loadGlucoWornings[index].uid).toString()})'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${_loadGlucoWornings[index].value} mg/dL'),
                      ],
                    ),
                    onTap: () {

                    },
                  ),
                );
              },
            ),
          ),
        ),

      ],
    );
  }
}

