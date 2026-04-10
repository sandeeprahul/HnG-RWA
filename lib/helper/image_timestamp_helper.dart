import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ImageTimestampHelper {
  static Future<String?> addTimestampToImage({
    required String imagePath,
    required String storeName,
    required String mallName,
    required String locationCoords,
  }) async {
    try {
      // 1. Load the original image
      final File file = File(imagePath);
      final bytes = await file.readAsBytes();
      final ui.Image image = await decodeImageFromList(bytes);

      // 2. Setup recorder and canvas
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final double width = image.width.toDouble();
      final double height = image.height.toDouble();

      // Draw the original image
      canvas.drawImage(image, Offset.zero, Paint());

      // 3. Define branding/timestamp details
      final String timestamp = DateFormat("dd MMM yyyy, hh:mm a").format(DateTime.now());
      final double padding = width * 0.04; // Responsive padding
      final double fontSizeLarge = width * 0.035;
      final double fontSizeSmall = width * 0.025;

      // 4. Draw semi-transparent background for bottom info (professional look)
      final double rectHeight = height * 0.15;
      final paint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      
      canvas.drawRect(
        Rect.fromLTWH(0, height - rectHeight, width, rectHeight),
        paint,
      );

      // 5. Setup Text Painters
      
      // Store & Mall Name (Branding)
      final brandPainter = TextPainter(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.verified, color: Colors.green, size: fontSizeLarge),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: "  $storeName · $mallName",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSizeLarge,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // textDirection: TextDirection.LTR,
      );
      brandPainter.layout();

      // Coordinates & Time
      final detailsPainter = TextPainter(
        text: TextSpan(
          children: [
            WidgetSpan(
              child: Icon(Icons.location_on, color: Colors.blue, size: fontSizeSmall),
              alignment: PlaceholderAlignment.middle,
            ),
            TextSpan(
              text: " $locationCoords",
              style: TextStyle(color: Colors.white, fontSize: fontSizeSmall),
            ),
            TextSpan(
              text: "   |   $timestamp",
              style: TextStyle(color: Colors.white70, fontSize: fontSizeSmall),
            ),
          ],
        ),
        // textDirection: TextDirection.ltr,
      );
      detailsPainter.layout();

      // 6. Paint the text onto canvas
      brandPainter.paint(
        canvas, 
        Offset(padding, height - rectHeight + padding)
      );
      
      detailsPainter.paint(
        canvas, 
        Offset(padding, height - (rectHeight / 2) + 5)
      );

      // 7. Save the processed image
      final picture = recorder.endRecording();
      final img = await picture.toImage(width.toInt(), height.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);

      if (pngBytes == null) return null;

      final Directory directory = await getApplicationDocumentsDirectory();
      final String stampedPath = "${directory.path}/stamped_${DateTime.now().millisecondsSinceEpoch}.png";
      final File stampedFile = File(stampedPath);
      await stampedFile.writeAsBytes(pngBytes.buffer.asUint8List());

      return stampedPath;
    } catch (e) {
      print("Error adding timestamp: $e");
      return null;
    }
  }
}
