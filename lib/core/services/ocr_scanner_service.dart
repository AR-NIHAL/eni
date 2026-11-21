import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'medicine_ocr_parser.dart';

class OcrScannerService {
  OcrScannerService._();
  static final OcrScannerService instance = OcrScannerService._();

  final ImagePicker _picker = ImagePicker();

  /// Captures photo via camera and processes OCR
  Future<MedicineOcrResult?> scanFromCamera() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.rear,
      imageQuality: 90,
    );

    if (image == null) return null;
    return await processImageFile(image.path);
  }

  /// Picks photo from gallery and processes OCR
  Future<MedicineOcrResult?> scanFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 90,
    );

    if (image == null) return null;
    return await processImageFile(image.path);
  }

  /// Processes text recognition on an image file path
  Future<MedicineOcrResult> processImageFile(String path) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      try {
        final inputImage = InputImage.fromFilePath(path);
        final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

        final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
        await textRecognizer.close();

        return MedicineOcrParser.parse(recognizedText.text, imagePath: path);
      } catch (e) {
        debugPrint('ML Kit OCR error: $e');
      }
    }

    // Fallback for Web/Desktop platforms or when native ML Kit engine is absent
    return MedicineOcrResult(
      rawText: 'Scanned image: $path',
      imagePath: path,
    );
  }

  /// Sample mock scans for testing without physical medicine packets
  static MedicineOcrResult getSampleScan(String sampleName) {
    switch (sampleName.toLowerCase()) {
      case 'maxpro':
        return MedicineOcrParser.parse('''
Maxpro 20 mg Capsule
Esomeprazole Magnesium Trihydrate USP
20 mg
Renata Limited
Batch: E204
Exp: 12/28
''');
      case 'pregabalin':
        return MedicineOcrParser.parse('''
Pregabalin 75mg Capsules
Each hard gelatin capsule contains Pregabalin INN 75 mg
Square Pharmaceuticals Ltd.
Store below 30°C
''');
      case 'augmentin':
        return MedicineOcrParser.parse('''
Augmentin 625mg Tablets
Amoxicillin and Clavulanate Potassium Tablets USP
625 mg
GSK
''');
      case 'paracetamol':
      default:
        return MedicineOcrParser.parse('''
Napa Extra 500mg + 65mg
Paracetamol 500 mg and Caffeine 65 mg
Beximco Pharmaceuticals Ltd
''');
    }
  }
}
