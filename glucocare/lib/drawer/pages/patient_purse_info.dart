import 'package:flutter/material.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:logger/logger.dart';
import '../../models/purse_model.dart';

class PatientPurseInfoPage extends StatelessWidget {
  final UserModel model;
  const PatientPurseInfoPage({super.key, required this.model});

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
      body: PatientPurseInfoForm(model: model),
    );
  }
}

class PatientPurseInfoForm extends StatefulWidget {
  final UserModel model;
  const PatientPurseInfoForm({super.key, required this.model});

  @override
  State<PatientPurseInfoForm> createState() => _PatientPurseInfoFormState(model: model);
}

class _PatientPurseInfoFormState extends State<PatientPurseInfoForm> {
  final UserModel model;
  _PatientPurseInfoFormState({required this.model});

  Logger logger = Logger();
  bool _isLoading = true;
  List<PurseModel> _purseModels = [];

  void _setState() async {
    String uid = '';
    if(model.uid != '') {
      uid = model.uid;
    } else {
      uid = model.kakaoId;
    }
    List<PurseModel> models = await PurseRepository.selectAllPurseCheckBySpecificUid(uid);
    setState(() {
      _purseModels = models;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _setState();
    logger.d('$_purseModels');
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
                  itemCount: _purseModels.length,
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                      width: MediaQuery.of(context).size.width - 50,
                      child: ListTile(
                        title: Text('${_purseModels[index].checkDate} ${_purseModels[index].checkTime}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_purseModels[index].shrink}/${_purseModels[index].relax} mg/dL',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Container(
                              width: MediaQuery.of(context).size.width - 50,
                              height: 1,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                              ),
                            ),
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