import 'package:flutter/material.dart';

class StoreAuditQna extends StatefulWidget {
  const StoreAuditQna({super.key});

  @override
  State<StoreAuditQna> createState() => _StoreAuditQnaState();
}

class _StoreAuditQnaState extends State<StoreAuditQna> {
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
        title: const Row(
          children: [
            Text(
              'Store Audit',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(width: 5),
            Text(
              ' - ',
              style: TextStyle(color: Colors.black),
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
