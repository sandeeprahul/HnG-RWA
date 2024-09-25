import 'package:flutter/material.dart';

class ImagePreview extends StatelessWidget {
  final String imgUrl;
  final String employeeCode;

  const ImagePreview(this.imgUrl, this.employeeCode, {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Hero(tag: employeeCode, child: Image.network(imgUrl)));
  }
}
