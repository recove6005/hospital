import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:glucocare/models/admin_request_model.dart';
import 'package:glucocare/repositories/admin_request_image_storage.dart';
import 'package:glucocare/repositories/admin_request_repository.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';

class AdminRequestInfoPage extends StatelessWidget {
  const AdminRequestInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const AdminRequestInfoForm();
  }
}

class AdminRequestInfoForm extends StatefulWidget {
  const AdminRequestInfoForm({super.key});

  @override
  State<AdminRequestInfoForm> createState() => _AdminRequestInfoFormState();
}

class _AdminRequestInfoFormState extends State<AdminRequestInfoForm> {
  Logger logger = Logger();
  bool _isLoading = true;
  bool _isApplied = false;
  File? _selectedImage = null;

  Future<void> _adminRequest() async {
    await AdminRequestRepository.insertAdminRequest();
    _imageUpload();
    Fluttertoast.showToast(msg: '관리자 계정 신청이 완료되었습니다.', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      _checkApply();
      _selectedImage = null;
    });
  }

  Future<void> _imageUpload() async {
    if(_selectedImage == null) {
      return;
    } else {
      setState(() {
        _isLoading = true;
      });
      await AdminRequestImageStorage.uploadFile(_selectedImage!);
    }
  }

  Future<void> _adminRquestCancel() async {
    await AdminRequestRepository.deleteAdminRequest();
    await AdminRequestImageStorage.deleteFile();
    Fluttertoast.showToast(msg: '관리자 계정 신청이 취소되었습니다.', toastLength: Toast.LENGTH_SHORT);
    setState(() {
      _checkApply();
    });
  }

  void _checkApply() async {
    AdminRequestModel? tempCheck = await AdminRequestRepository.selectAdminRequest();
    _isLoading = false;
    setState(() {
      if(tempCheck != null) _isApplied = true;
      else _isApplied = false;
    });
  }

  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      if(pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch(e) {
      logger.e('[glucocare_log] Image picker error: $e');
    }
  }

  Future<Widget> _getImage() async {
    Widget imageWidget = Image.file(_selectedImage!, width: 250, height: 250, fit: BoxFit.contain,);
    return imageWidget;
  }

  @override
  void initState() {
    super.initState();
    _checkApply();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: const Center(
        child: SizedBox(
          width: 40,
          height: 40,
          child: CircularProgressIndicator(),
        ),
      ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '관리자 계정 신청 정보',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height/10,
            ),
            if(!_isApplied)
              const Align(
                child: Center(
                  child: Text(
                    '관리자 계정이 아닙니다.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            if(!_isApplied)
              const Align(
                child: Center(
                  child: Text(
                    '관리자 계정을 신청해주세요.',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            if(!_isApplied)
              const SizedBox(height: 20,),
            if(!_isApplied && _selectedImage == null)
              Align(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: const Center(
                      child: Text(
                        '사원증 사진',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey
                        ),
                      ),
                    ),
                  )
                ),
              ),
            if(!_isApplied && _selectedImage != null)
              Align(
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey,
                      width: 2,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      _pickImage();
                    },
                    child: FutureBuilder<Widget>(
                        future: _getImage(),
                        builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
                          if(snapshot.connectionState == ConnectionState.waiting) {
                            // loading..
                            return const Center(child: CircularProgressIndicator());
                          }
                          else if(snapshot.hasError) {
                            // error..
                            return const Center(child: Text("이미지를 불러오는 중 오류가 발생했습니다."));
                          } else {
                            // completed..
                            return snapshot.data ?? Center(child: Text("이미지가 없습니다."));
                          }
                        },
                    ),
                  ),
                ),
              ),
            if(_isApplied)
              const Align(
                child: Center(
                  child: Text(
                    '관리자 계정 심사 중...',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 50),
            if(!_isApplied)
              Align(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _adminRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff28c2ce),
                      ),
                      child: const Text('신청하기', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),),
                    ),
                  ),
                ),
              ),
            if(_isApplied)
              Align(
                child: Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _adminRquestCancel,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff28c2ce),
                      ),
                      child: const Text('신청 취소하기', style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white
                      ),),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}