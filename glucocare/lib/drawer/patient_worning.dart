import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/models/purse_model.dart';
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
  List<PurseModel> _loadPurseWornings = [];
  List<GlucoModel> _loadGlucoWornings = [];

  List<PatientModel> _searchModels = [];
  TextEditingController _nameController = TextEditingController();

  bool _page = true; // true: gluco, false: purse

  void _loadPurseWorningPatient() async {

  }

  void _loadGlucoWorningPatient() async {

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
    //_loadGlucoWorningPatient();
    //_loadPurseWorningPatient();
  }

  @override
  Widget build(BuildContext context) {
    //if(_isGlucoWornLoading) return const Center(child: CircularProgressIndicator(),);
    return Column(
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
                  backgroundColor: Color(0xD6EFC987),
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
            height: 580,
            decoration: const BoxDecoration(
              color: Colors.white
            ),
            child: ListView.builder(
              itemCount: 30,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                  child: ListTile(
                    leading: const Icon(Icons.account_box),
                    title: Text('옹감자여사 (남)'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('2024년 7월 7일 오후 2시 32분'),
                        Text('식후 146 mg/dL'),
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

        if(!_page)
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: EdgeInsets.zero,
              width: 350,
              height: 580,
              decoration: const BoxDecoration(
                  color: Colors.white
              ),
              child: ListView.builder(
                itemCount: 20,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: ListTile(
                      leading: const Icon(Icons.account_box),
                      title: Text('똥감자도령 (여)'),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('2024년 11월 11일 오후 1시 32분'),
                          Text('130 mg/dL'),
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

