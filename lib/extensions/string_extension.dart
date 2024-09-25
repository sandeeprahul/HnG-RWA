import 'package:intl/intl.dart';

extension StringExtension on String? {
  String getInitials() => this == null
      ? ''
      : this!.isNotEmpty
          ? this!.trim().split(RegExp(' +')).map((s) => s[0]).take(2).join()
          : '';

  String capitalize() {
    if (this != null) {
      return "${this![0].toUpperCase()}${this!.substring(1)}";
    } else {
      return "";
    }
  }

  bool searchCaseInSensitive(String text) {
    if (this == null) {
      return true;
    } else if (text.isEmpty) {
      return true;
    } else {
      return this!.toLowerCase().contains(text.toLowerCase());
    }
  }

  bool get isNullEmptyOrWhitespace =>
      this == null || this!.isEmpty || this!.trim().isEmpty;

  String? isStringOrNull() {
    if (this == null) {
      return null;
    } else if (this!.isEmpty) {
      return null;
    } else {
      return this;
    }
  }

  DateTime convertToDateTime() {
    final formatter = DateFormat('h:mm a');
    final convertedDateTime = formatter.parse(this!);
    return DateTime(
      1995,
      01,
      20,
      convertedDateTime.hour,
      convertedDateTime.minute,
    );
  }

  bool isValidMobileNumber() {
    if (isNullEmptyOrWhitespace) {
      return false;
    }
    RegExp regex = RegExp(r'^[+]?[0-9]{10}$');

    return regex.hasMatch(this!);
  }

  bool isValidEmail() {
    if (isNullEmptyOrWhitespace) {
      return false;
    }

    RegExp regex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');

    return regex.hasMatch(this!);
  }
}
