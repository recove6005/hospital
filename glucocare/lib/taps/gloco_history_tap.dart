import 'package:flutter/material.dart';
import 'package:glucocare/models/gluco_model.dart';
import 'package:glucocare/repositories/gluco_repository.dart';
import 'package:logger/logger.dart';

class GlucoHistoryTap extends StatelessWidget {
  const GlucoHistoryTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: GlucoHistoryForm(),
    );
  }
}

class GlucoHistoryForm extends StatefulWidget {
  const GlucoHistoryForm({super.key});

  @override
  State<StatefulWidget> createState() => _GlucoHistoryForm();
}

class _GlucoHistoryForm extends State<GlucoHistoryForm> {
  Logger logger = Logger();
  bool _isLoading = true;

  List<GlucoModel> _glucoModels = [];
  int _childCount = 0;

  void _setGlucoModels() async {
    try {
      List<GlucoModel> models = await GlucoRepository.selectAllGlucoCheck();
      setState(() {
        _glucoModels = models;
        _childCount = _glucoModels.length;
        _isLoading = false;
      });
    } catch (e) {
      logger.e('[glucocare_log] Failed to load gluco histories : $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _setGlucoModels();
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const Center(child:CircularProgressIndicator());
    }
    if(_glucoModels.isEmpty) {
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
              height: 630,
              child: CustomScrollView(
                slivers: [
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      childCount: _childCount,
                          (context, index) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${_glucoModels[index].checkDate}',
                                  style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black54
                                  ),
                                ),
                              const SizedBox(height: 5,),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.orange[200],
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
                                            Text('${_glucoModels[index].checkTime} ${_glucoModels[index].checkTimeName}',
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: Image.asset('assets/images/ic_gluco_check.png'),
                                            ),
                                            SizedBox(width: 10,),
                                            Text('${_glucoModels[index].value} mg/dL',
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),)
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 5,),
                                      Container(
                                        child: Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 25,
                                              height: 25,
                                              child: Image.asset('assets/images/ic_memo.png'),
                                            ),
                                            SizedBox(width: 10,),
                                            SizedBox(
                                              width: 200,
                                              child: Text('${_glucoModels[index].state}',
                                                style: const TextStyle(
                                                  fontSize: 15,
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
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}