import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/models/admin_request_model.dart';
import 'package:glucocare/repositories/admin_request_image_storage.dart';
import 'package:glucocare/repositories/admin_request_repository.dart';
import 'package:glucocare/repositories/patient_repository.dart';
import 'package:logger/logger.dart';

import '../models/user_model.dart';

class MasterAdminCheckPage extends StatelessWidget {
  const MasterAdminCheckPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '어드민 신청 목록',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        backgroundColor: Colors.white,
        shadowColor: Colors.white,
      ),
      body: const MasterAdminCheckForm(),
    );
  }
}

class MasterAdminCheckForm extends StatefulWidget {
  const MasterAdminCheckForm({super.key});

  @override
  State<MasterAdminCheckForm> createState() => _MasterAdminCheckFormState();
}

class _MasterAdminCheckFormState extends State<MasterAdminCheckForm> {
  Logger logger = Logger();
  List<AdminRequestModel> _requests = [];
  List<String> _names = [];

  bool _isLoading = true;

  Future<void> _getRequestList() async {
    List<AdminRequestModel> tempList = await AdminRequestRepository.selectAllAdminRequest();
    List<String> tempNames = [];
    if(tempList.isNotEmpty) {
      for(AdminRequestModel model in tempList) {
        UserModel? user = await UserRepository.selectUserBySpecificUid(model.uid);
        if(user != null) tempNames.add(user.name);
      }
      setState(() {
        _names = tempNames;
        _requests = tempList;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setAdmin(String uid) async {
    await AdminRequestRepository.setUserUptoAdmin(uid);
    setState(() async {
      await _getRequestList();
    });
  }

  Future<void> _cancelAdmin(String uid) async {
    await AdminRequestRepository.cancelUserUptoAdmin(uid);
    setState(() async {
      await _getRequestList();
    });
  }

  OverlayEntry? _overlayEntry;
  Future<void> _showOverlay(BuildContext context, String uid) async {
    String imageUrl = await AdminRequestImageStorage.downloadFileBySpecificUid(uid);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: 50,
        child: Material(
          child: Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              height: MediaQuery.of(context).size.height - 100,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white70,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  width: 2,
                  color: Colors.grey,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      '첨부된 신분증 사진',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 20,),
                    imageUrl == ''
                        ?  const Text('nothing to show.')
                        :  Image.network(imageUrl),
                    const SizedBox(height: 30,),
                    ElevatedButton(
                      onPressed: _removeOverlay,
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: const BorderSide(
                              color: Colors.white60,
                              width: 1,
                              style: BorderStyle.solid,
                            ),
                          )
                      ),
                      child: const Icon(Icons.cancel, color: Colors.black,),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }



  @override
  void initState() {
    super.initState();
    _getRequestList();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) return const Center(child: CircularProgressIndicator(),);
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          if(_requests.isEmpty)
            Align(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height-100,
                child: const Center(
                  child: Text(
                    '어드민 계정 신청 내역이 없습니다.',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          if(_requests.isNotEmpty)
            Align(
              child: Container(
                padding: EdgeInsets.zero,
                width: 350,
                height: MediaQuery.of(context).size.height-100,
                child: ListView.builder(
                    itemCount: _requests.length,
                    itemBuilder: (context, index) {
                      return Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          border: const Border(
                            top: BorderSide(width: 1, color: Colors.grey,),
                            bottom: BorderSide(width: 1, color: Colors.grey,),
                            left: BorderSide(width: 1, color: Colors.grey,),
                            right: BorderSide(width: 1, color: Colors.grey,),
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _names[index],
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              _requests[index].uid.toString(),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if(_requests[index].accepted)
                                  ElevatedButton(
                                  onPressed: () async => await _cancelAdmin(_requests[index].uid),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white60
                                  ),
                                  child: const Icon(Icons.verified_user, color: Colors.indigo,),
                                ),
                                if(!_requests[index].accepted)
                                  ElevatedButton(
                                    onPressed: () async => await _setAdmin(_requests[index].uid),
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white60
                                    ),
                                    child: const Icon(Icons.no_accounts, color: Colors.red,),
                                  ),
                                const SizedBox(width: 20,),
                                ElevatedButton(
                                  onPressed: () => _showOverlay(context, _requests[index].uid),
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white60
                                  ),
                                  child: const Icon(Icons.picture_in_picture_alt, color: Colors.black,),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                ),
              ),
            ),
        ],
      ),
    );
  }
}

