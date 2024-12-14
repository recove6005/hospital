import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glucocare/main.dart';
import 'package:glucocare/repositories/consent_repository.dart';

class ConsentPersonalInfoPage extends StatelessWidget {
  const ConsentPersonalInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '개인정보 이용 동의',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const ConsentPersonalInfoForm(),
    );
  }
}

class ConsentPersonalInfoForm extends StatefulWidget {
  const ConsentPersonalInfoForm({super.key});

  @override
  State<ConsentPersonalInfoForm> createState() => _ConsentPersonalInfoFormState();
}

class _ConsentPersonalInfoFormState extends State<ConsentPersonalInfoForm> {
  bool _isLoading = true;

  Map<String,dynamic> _consentContent = {};
  String _title = '';
  String _description = '';
  List<dynamic> _sections = [];
  String _note = '';
  String _confirmationQuestion = '';

  Future<void> _loadConsentContent() async {
    try {
      String jsonString = await rootBundle.loadString('assets/data/consent.json');
      _consentContent = json.decode(jsonString);

      setState(() {
        _title = _consentContent['title'] ?? 'No title';
        _description = _consentContent['description'] ?? 'No description';
        _sections = _consentContent['sections'] ?? ['no show'];
        _note = _consentContent['note'] ?? 'Did\'t found note';
        _confirmationQuestion = _consentContent['confirmation_question'] ?? 'Did\'t found confirm question';
        _isLoading = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load json.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConsentContent();
  }

  bool _revokeOk = false;
  void _revokeOkChange(bool? revoke) {
    if(revoke != null) {
      setState(() {
        _revokeOk = revoke;
        _revokeNo = false;
      });
    }
  }
  bool _revokeNo = true;
  void _revokeNoChange(bool? revoke) {
    if(revoke != null) {
      setState(() {
        _revokeNo = revoke;
        _revokeOk = false;
      });
    }
  }

  int _index = 0;

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return Column(
      children: [
        // 정보처리방침 내용
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.center,
              child: Text(
                _title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 10,),
            Align(
              alignment: Alignment.center,
              child: Text(
                  _description
              ),
            ),
            const SizedBox(height: 10,),
            ..._sections.map((section) {
              _index = 0;
              String heading = section['heading'];
              List<dynamic> items = section['items'] ?? [];

              return Container(
                padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Text(
                        heading,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    ...items.map((item) {
                      _index++;
                      String label = item['label'] ?? '';
                      var value = item['value'] ?? '';

                      String displayValue;
                      if(value is List) {
                        displayValue = value.join(', ');
                      } else {
                        displayValue = value.toString();
                      }
                      return Column(
                        children: [
                          const SizedBox(height: 15,),
                          Row(
                            children: [
                              Text('${_index.toString()}) ', style: const TextStyle(fontWeight: FontWeight.bold),),
                              Text(label, style: const TextStyle(fontWeight: FontWeight.bold),),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('   -   ',),
                              SizedBox(
                                width: MediaQuery.of(context).size.width-80,
                                child: Text('$displayValue'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5,),
                        ],
                      );
                    }),
                  ],
                ),
              );
            }),
          ],
        ),
        // 동의 버튼
        Row(
          children: [
            Checkbox(
                value: _revokeOk,
                onChanged: _revokeOkChange,
            ),
            const Text(
                '개인정보 수집 및 이용에 동의합니다'
            ),
          ],
        ),
        // 미동의 버튼
        Row(
          children: [
            Checkbox(
              value: _revokeNo,
              onChanged: _revokeNoChange,
            ),
            const Text(
                '개인정보 수집 및 이용에 동의하지 않습니다'
            ),
          ],
        ),
        const SizedBox(height: 20,),
        if(_revokeOk)
        SizedBox(
          width: 100,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xfff9f9f9),
              side: BorderSide(width: 1, color: Colors.grey),
            ),
            onPressed: () async {
              if(_revokeOk) {
                await ConsentRepository.permitCurUserConsent();
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
              }
            },
            child: const Text('다음', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey),),
          ),
        ),
      ],
    );
  }
}