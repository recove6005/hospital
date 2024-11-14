import 'package:flutter/material.dart';
import 'package:glucocare/taps/pages/gluco_check.dart';
import 'package:glucocare/taps/pages/pill_alarm_history.dart';
import 'package:glucocare/taps/pages/purse_check.dart';

class HomeTap extends StatelessWidget {
  const HomeTap({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: HomeTapForm(),
    );
  }
}

class HomeTapForm extends StatefulWidget {
  const HomeTapForm({super.key});

  @override
  State<StatefulWidget> createState() => _HomeTapForm();
}

class _HomeTapForm extends State<HomeTapForm> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Center(
              child: Image.asset('assets/images/ic_temp_logo.png'),
            )
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 350,
            height: 130,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PurseCheckPage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[300],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)
                )
              ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(width: 30,),
                    Image.asset('assets/images/ic_purse_check.png',
                    width: 50,
                    height: 50,),
                    const SizedBox(width: 10,),
                    const Text('혈압 관리',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                      ),
                    ),
                  ],
                ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: 350,
            height: 130,
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GlucoCheckPage()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30,),
                  Image.asset('assets/images/ic_gluco_check.png',
                    width: 50,
                    height: 50,),
                  const SizedBox(width: 10,),
                  const Text('혈당 관리',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: 350,
            height: 130,
            child: ElevatedButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PillAlarmHistoryPage()));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[350],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)
                  )
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(width: 30,),
                  Image.asset('assets/images/ic_pill_check.png',
                    width: 50,
                    height: 50,),
                  const SizedBox(width: 10,),
                  const Text('복약 알림',
                    style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 15,),
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 167.5,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '목표 혈압',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '120/80',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87
                        ),),
                    ],
                  ),
                ),
                const SizedBox(width: 15,),
                Container(
                  width: 167.5,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.red[300],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '최근1달 평균 혈압',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '120/80',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87
                        ),),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 350,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 167.5,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '목표 혈당',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '110',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87
                        ),),
                    ],
                  ),
                ),
                const SizedBox(width: 15,),
                Container(
                  width: 167.5,
                  height: 100,
                  decoration: BoxDecoration(
                      color: Colors.orange[200],
                      borderRadius: BorderRadius.circular(20)
                  ),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '최근1달 평균 혈당',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87
                        ),
                      ),
                      SizedBox(height: 5,),
                      Text(
                        '140',
                        style: TextStyle(
                            fontSize: 30,
                            color: Colors.black87
                        ),),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 10,),
          SizedBox(
            width: 350,
            height: 40,
            child: ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[350],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)
                  )
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('진료 예약',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

}