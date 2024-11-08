import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glucocare/taps/pages/pill_check.dart';
import 'package:logger/logger.dart';

class PillHistoryPage extends StatelessWidget {
  const PillHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        toolbarHeight: 40,
      ),
      body: const PillHistoryForm(),
    );
  }
}

class PillHistoryForm extends StatefulWidget {
  const PillHistoryForm({super.key});

  @override
  State<StatefulWidget> createState() => _PillHistoryFormState();
}

class _PillHistoryFormState extends State<PillHistoryForm> {
  Logger logger = Logger();


  void _onSaveButtonPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PillCheckPage()));
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(

      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        width: 350,
        height: 50,
        child: FloatingActionButton(
          onPressed: _onSaveButtonPressed,
          backgroundColor: Colors.grey[350],
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
