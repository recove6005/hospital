import 'package:flutter/material.dart';
import 'package:glucocare/models/user_model.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:intl/intl.dart';

class MyInfoPage extends StatelessWidget {
  const MyInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('내 정보', style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const MyInfoForm(),
    );
  }
}

class MyInfoForm extends StatefulWidget {
  const MyInfoForm({super.key});

  @override
  State<MyInfoForm> createState() => _MyInfoFormState();
}

class _MyInfoFormState extends State<MyInfoForm> {
   String _name = '';
   String _gen = '';
   String _birthDate = '';
   String _state = '없음';

  Future<void> _getModel() async {
    UserModel? model = await UserRepository.selectUserByUid();
    if(model != null) {
      setState(() {
        _name = model.name;
        _gen = model.gen;
        _birthDate = DateFormat('yyyy년 MM월 dd일').format(model.birthDate.toDate());
        _state = model.state;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getModel();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 50,),
              SizedBox(
                width: 350,
                height: 80,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('$_name 님', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30,),
                    const Text('성별 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 30,),
                    Text(_gen, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 30,),
                    const Text('생일 ', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(width: 30,),
                    Text(_birthDate, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              ),
              const SizedBox(height: 30,),
              Container(
                width: 350,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('특이사항', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: Colors.black),),
                    const SizedBox(height: 5,),
                    Text(_state, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.normal, color: Colors.black),),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

