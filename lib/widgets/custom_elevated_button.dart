import 'package:flutter/material.dart';

import '../core/light_theme.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const CustomElevatedButton({
    required this.text,
    required this.onPressed,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22.0),
        ),
      ),
      onPressed: onPressed,
      child:  Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Text(text,style: lightTheme.textTheme.labelSmall!.copyWith(color: Colors.black,fontSize: 12),),
      ),
    );
  }
}