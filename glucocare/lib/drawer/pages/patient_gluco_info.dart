import 'package:flutter/material.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:logger/logger.dart';
import '../../models/gluco_model.dart';

class PatientGlucoInfoPage extends StatelessWidget {
  final UserModel model;
  const PatientGlucoInfoPage({super.key, required this.model});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('환자 혈당 측정 내역', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: PatientGlucoInfoForm(model: model),
    );
  }
}

class PatientGlucoInfoForm extends StatefulWidget {
  final UserModel model;
  const PatientGlucoInfoForm({super.key, required this.model});

  @override
  State<PatientGlucoInfoForm> createState() => _PatientGlucoInfoFormState(model: model);
}

class _PatientGlucoInfoFormState extends State<PatientGlucoInfoForm> {
  final UserModel model;
  _PatientGlucoInfoFormState({required this.model});

  Logger logger = Logger();
  bool _isLoading = true;
  List<GlucoModel> _glucoModels = [];

  void _setState() async {
    String uid = '';
    if(model.uid != '') {
      uid = model.uid;
    } else {
      uid = model.kakaoId;
    }
    List<GlucoModel> models = await GlucoRepository.selectAllGlucoCheckBySpecificUid(uid);
    setState(() {
      _glucoModels = models;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setState();
    logger.d('$_glucoModels');
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            const SizedBox(height: 5,),
            Align(
              alignment: Alignment.center,
              child: Container(
                padding: EdgeInsets.zero,
                width: 350,
                height: MediaQuery.of(context).size.height - 150,
                child: ListView.builder(
                  itemCount: _glucoModels.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      width: MediaQuery.of(context).size.width - 50,
                      child: ListTile(
                        shape: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
                        onTap: () {

                        },
                        title: Text('${_glucoModels[index].checkDate}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${_glucoModels[index].checkTime}'),
                            Text(
                              '${_glucoModels[index].value} mg/dL',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 10,),
                            Container(
                              width: MediaQuery.of(context).size.height - 150,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: Color(0xfff4f4f4),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('메모', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                                  const SizedBox(height: 5,),
                                  if(_glucoModels[index].state == '')
                                    Text('없음',),
                                  if(_glucoModels[index].state != '')
                                  Text('${_glucoModels[index].state}'),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}