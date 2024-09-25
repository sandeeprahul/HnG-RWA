import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class ProfilePageListWidget extends StatelessWidget {
  final IconData customIcon; // Custom icon
  final String customText; // Custom text

  const ProfilePageListWidget({
    Key? key,
    required this.customIcon,
    required this.customText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 20, top: 15, bottom: 15, right: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xffdeeeff),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              customIcon, // Use the custom icon passed from OtherPage
              color: Colors.white,
            ),
          ),
           Padding(
            padding: const EdgeInsets.only(left: 10, right: 5),
            child: Text(
              customText,
              style: const TextStyle(color: Colors.black, fontSize: 16),
            ),
          ),
          const Spacer(),
          const Icon(
            Icons.arrow_forward_ios_outlined,
            size: 15,
          ),
        ],
      ),
    );
  }
}

