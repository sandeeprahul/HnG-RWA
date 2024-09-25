import 'package:flutter/material.dart';

Widget loadingProgress() {
  return Container(
    color: const Color(0x80000000),
    child: Center(
        child: Container(
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(5)),
            padding: const EdgeInsets.all(20),
            height: 115,
            width: 150,
            child: Column(
              children: const [
                CircularProgressIndicator(),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Please wait..'),
                )
              ],
            ))),
  );
}
