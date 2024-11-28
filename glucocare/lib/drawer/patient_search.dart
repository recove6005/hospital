import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/patient_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

class PatientSearchPage extends StatelessWidget {
  const PatientSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '회원 정보 검색',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const PatientSearchForm(),
    );
  }
}

class PatientSearchForm extends StatefulWidget {
  const PatientSearchForm({super.key});

  @override
  State<PatientSearchForm> createState() => _PatientSearchFormState();
}

class _PatientSearchFormState extends State<PatientSearchForm> {
  Logger logger = Logger();
  bool _isPatienLoading = true;
  List<PatientModel> _searchModels = [];
  TextEditingController _nameController = TextEditingController();

  void _loadAllPatient() async {
    _searchModels = await PatientRepository.selectAllPatient();
    setState(() {
      _isPatienLoading = false;
    });
  }

  void _searchPatient(String str) async {
    List<PatientModel> models = await PatientRepository.selectAllPatientByName(_nameController.text);
    setState(() {
      _searchModels = models;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadAllPatient();
  }
  @override
  Widget build(BuildContext context) {
    if(_isPatienLoading) return Center(child: CircularProgressIndicator(),);
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [ // 서치 박스
        const SizedBox(height: 10,),
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
              onChanged: _searchPatient,
            ),
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
              padding: EdgeInsets.zero,
              width: 350,
              height: 200,
              child: ListView.builder(
                itemCount: _searchModels.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: ListTile(
                      leading: Icon(Icons.account_box),
                      title: Text(_searchModels[index].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_searchModels[index].gen),
                          Text(DateFormat('yyyy년 MM월 dd일').format(_searchModels[index].birthDate.toDate())),
                        ],
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("${_searchModels[index].name}님의 정보입니다.")));
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

