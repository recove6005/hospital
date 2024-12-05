import 'package:flutter/material.dart';
import 'package:glucocare/drawer/pages/patient_info.dart';
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
  List<PatientModel> _allPatientModels = [];
  List<PatientModel> _searchModels = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _birthController = TextEditingController();

  void _loadAllPatient() async {
    _allPatientModels = await PatientRepository.selectAllPatient();
    setState(() {
      _searchModels = _allPatientModels;
      _isPatienLoading = false;
    });
  }

  // 회원 서치 로직
  void _searchPatientByName(String? keyword) {
    List<PatientModel> nameSearchedModels = [];
    if(keyword != null && keyword != '' && _searchModels.isNotEmpty) {
      for(PatientModel model in _searchModels) {
        if (model.name.contains(keyword)) nameSearchedModels.add(model);
      }
      setState(() {
        _searchModels = List.from(nameSearchedModels);
      });
    } else if(keyword != null && keyword != '' && _searchModels.isEmpty) {
      for(PatientModel model in _allPatientModels) {
        if (model.name.contains(keyword)) nameSearchedModels.add(model);
      }
      setState(() {
        _searchModels = List.from(nameSearchedModels);
      });
    }
    else {
      setState(() {
        _searchModels = List.from(_allPatientModels);
      });
    }
  }

  void _searchPatientByBirth(String? keyword) {
    List<PatientModel> birthSearchedModels = [];
    if(keyword != null && keyword != '' && _searchModels.isNotEmpty) {
      for(PatientModel model in _searchModels) {
        String formattedBirth = DateFormat('yyMMdd').format(model.birthDate.toDate());
        if(formattedBirth.contains(keyword)) birthSearchedModels.add(model);
      }
      setState(() {
        _searchModels = List.from(birthSearchedModels);
      });
    } else if(keyword != null && keyword != '' && _searchModels.isEmpty) {
      for(PatientModel model in _allPatientModels) {
        String formattedBirth = DateFormat('yyMMdd').format(model.birthDate.toDate());
        if (formattedBirth.contains(keyword)) birthSearchedModels.add(model);
      }
      setState(() {
        _searchModels = List.from(birthSearchedModels);
      });
    }
    else {
      setState(() {
        _searchModels = List.from(_allPatientModels);
      });
    }
  }

  void _moveToPatientInfoPage(PatientModel model) async {
      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => PatientInfoPage(model: model)));
      if(result) {
        _loadAllPatient();
      }
  }

  @override
  void initState() {
    super.initState();
    _loadAllPatient();
  }
  @override
  Widget build(BuildContext context) {
    if(_isPatienLoading) return const Center(child: CircularProgressIndicator(),);
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
                  prefixIcon: Icon(Icons.person_search),
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
              onChanged: _searchPatientByName,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Align(
          alignment: Alignment.center,
          child: Container(
            padding: EdgeInsets.zero,
            width: 350,
            height: 50,
            child: TextField(
              controller: _birthController,
              decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.date_range),
                  filled: true,
                  fillColor: Color(0xfff9f9f9),
                  border: InputBorder.none,
                  hintText: '생년월일 6자리',
                  hintStyle: TextStyle(
                    fontSize: 18,
                    color: Colors.grey,
                  ),
              ),
              style: const TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.start,
              textAlignVertical: TextAlignVertical.center,
              onChanged: _searchPatientByBirth,
            ),
          ),
        ),
        const SizedBox(height: 10,),
        Align(
          alignment: Alignment.center,
          child: Container(
              padding: EdgeInsets.zero,
              width: 350,
              height: MediaQuery.of(context).size.height - 300,
              child: ListView.builder(
                itemCount: _searchModels.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 3),
                    child: ListTile(
                      leading: const Icon(Icons.account_box),
                      title: Text(_searchModels[index].name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_searchModels[index].gen),
                          Text(DateFormat('yyyy년 MM월 dd일').format(_searchModels[index].birthDate.toDate())),
                        ],
                      ),
                      onTap: () {
                        _moveToPatientInfoPage(_searchModels[index]);
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