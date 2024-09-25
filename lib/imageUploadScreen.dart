import 'package:flutter/material.dart';

class imageUploadScreen extends StatefulWidget {
  const imageUploadScreen({Key? key}) : super(key: key);

  @override
  State<imageUploadScreen> createState() => _imageUploadScreenState();
}

class _imageUploadScreenState extends State<imageUploadScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20, top: 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 15),
                          child: Icon(Icons.arrow_back),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          'DILO',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 100,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 100,
                          height: 100,
                        ),
                      )
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
