import 'package:flutter/material.dart';

class EmployeeDiloQNA extends StatefulWidget {
  const EmployeeDiloQNA({super.key});

  @override
  State<EmployeeDiloQNA> createState() => _EmployeeDiloQNAState();
}

class _EmployeeDiloQNAState extends State<EmployeeDiloQNA> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,color: Colors.black,),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
        ),
        title: Row(
          children: [
            const Text(
              'Employee Dilo',
              style: TextStyle(color: Colors.black),
            ),
            const SizedBox(width: 5),
            Text(
              ' - ',
              style: const TextStyle(color: Colors.black),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading:
        false, // Since you're handling leading manually
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Your ListView and other UI
            Align(
                alignment: Alignment.center,
                child: Text('No data found'))
          ],
        ),
      ),
    );
    ;
  }
}
