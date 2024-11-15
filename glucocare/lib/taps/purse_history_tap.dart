import 'package:flutter/material.dart';
import 'package:glucocare/repositories/purse_repository.dart';
import 'package:glucocare/services/auth_service.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

import '../models/purse_model.dart';

class PurseHistoryTap extends StatelessWidget {
  const PurseHistoryTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PurseHistoryForm(),
    );
  }
}

class PurseHistoryForm extends StatefulWidget {
  const PurseHistoryForm({super.key});

  @override
  dynamic noSuchMethod(Invocation invocation) => _PurseHistoryForm();
}

class _PurseHistoryForm extends State<PurseHistoryForm> {
  Logger logger = Logger();
  bool _isLoading = true;

  List<PurseModel> _purseModels = [];
  int _childCount = 0;

  void _setPurseModels() async {
    try {
      List<PurseModel> models = await PurseRepository.selectAllPurseCheck();
      setState(() {
        _purseModels = models;
        _childCount = _purseModels.length;
        _isLoading = false;
      });
    } catch(e) {
      logger.e('[glucocare_log] Failed to load purse check list $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setPurseModels();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child:CircularProgressIndicator());
    }
    if(_purseModels.isEmpty) {
      return Scaffold(
        body: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              children: [
                SizedBox(
                  height: 50,
                  child: Image.asset('assets/images/ic_temp_logo.png'),
                ),
                const SizedBox(height: 30,),
                const Center(
                  child: Text('혈압 측정 내역이 없습니다.'),
                )
              ]    
          ),
        ),
      );
    }
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
              height: 50,
              child: Image.asset('assets/images/ic_temp_logo.png'),
            ),
            const SizedBox(height: 10,),
            SizedBox(
              width: 350,
              height: 640,
              child: CustomScrollView(
                slivers: [
                  SliverList(delegate: SliverChildBuilderDelegate(
                   childCount: _childCount,
                      (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${_purseModels[index].checkDate}', style: TextStyle(
                              fontSize: 15,
                              color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 5,),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red[300],
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                                child: Column(
                                  children: [
                                    Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Image.asset('assets/images/ic_clock.png'),
                                          ),
                                          const SizedBox(width: 10,),
                                          Text('${_purseModels[index].checkTime} ${_purseModels[index].checkTimeName}',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Image.asset('assets/images/ic_purse_check.png'),
                                          ),
                                          const SizedBox(width: 10,),
                                          Text('${_purseModels[index].shrink}/${_purseModels[index].relax} mmHg    ${_purseModels[index].purse}회/1분',
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.black,
                                          ),),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: 10,),
                                    Container(
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            width: 25,
                                            height: 25,
                                            child: Image.asset('assets/images/ic_memo.png'),
                                          ),
                                          const SizedBox(width: 10,),
                                          SizedBox(
                                            width: 250,
                                            child:  Text(_purseModels[index].state,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}