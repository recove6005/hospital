import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PillHistoryPage extends StatelessWidget {
  const PillHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: PillHistoryForm(),
    );
  }
}

class PillHistoryForm extends StatefulWidget {
  const PillHistoryForm({super.key});

  @override
  State<PillHistoryForm> createState() => _PillHistoryFormState();
}

class _PillHistoryFormState extends State<PillHistoryForm> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
