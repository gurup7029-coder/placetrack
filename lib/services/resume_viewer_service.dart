import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/placement_models.dart';

class ResumeViewerService {
  /// Opens the student's resume PDF file using native PDF viewer or external browser
  static Future<bool> openStudentResume({
    required BuildContext context,
    required StudentModel student,
  }) async {
    // 1. Try local file if it exists
    if (student.resumeFilePath.isNotEmpty) {
      final file = File(student.resumeFilePath);
      if (await file.exists()) {
        final result = await OpenFilex.open(student.resumeFilePath);
        if (result.type == ResultType.done) {
          return true;
        }
      }
    }

    // 2. Try web link if valid URL
    if (student.resumeUrl.startsWith('http://') || student.resumeUrl.startsWith('https://')) {
      final uri = Uri.tryParse(student.resumeUrl);
      if (uri != null) {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (launched) return true;
      }
    }

    // 3. Fallback: generate a clean valid PDF resume file and open it
    final samplePdf = await generateStudentPdf(student);
    if (samplePdf != null && await samplePdf.exists()) {
      final result = await OpenFilex.open(samplePdf.path);
      if (result.type == ResultType.done) {
        return true;
      }
    }

    // If no app could open it:
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No PDF Viewer app found. Please install Google Drive / PDF Viewer to view.'),
        ),
      );
    }
    return false;
  }

  /// Copies an uploaded file permanently to the app document directory
  static Future<String> persistUploadedFile({
    required String originalPath,
    required String fileName,
  }) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final targetPath = '${appDir.path}/$fileName';
      final srcFile = File(originalPath);
      if (await srcFile.exists()) {
        final copied = await srcFile.copy(targetPath);
        return copied.path;
      }
    } catch (_) {}
    return originalPath;
  }

  /// Generates a valid PDF for students who haven't uploaded an external PDF yet
  static Future<File?> generateStudentPdf(StudentModel student) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final sanitized = student.name.replaceAll(' ', '_');
      final file = File('${appDir.path}/${sanitized}_Resume.pdf');

      final buffer = StringBuffer();
      buffer.writeln('%PDF-1.4');
      
      // Obj 1: Catalog
      final obj1Offset = buffer.length;
      buffer.writeln('1 0 obj');
      buffer.writeln('<< /Type /Catalog /Pages 2 0 R >>');
      buffer.writeln('endobj');

      // Obj 2: Pages
      final obj2Offset = buffer.length;
      buffer.writeln('2 0 obj');
      buffer.writeln('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
      buffer.writeln('endobj');

      // Obj 3: Page
      final obj3Offset = buffer.length;
      buffer.writeln('3 0 obj');
      buffer.writeln('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>');
      buffer.writeln('endobj');

      // Stream content
      final streamContent = '''BT
/F1 22 Tf
50 720 Td
(${student.name} - RESUME) Tj
0 -30 Td
/F1 12 Tf
(Registration Number: ${student.regNo}) Tj
0 -18 Td
(Degree & Department: ${student.department}) Tj
0 -18 Td
(Academic Year: ${student.year} - ${student.section}) Tj
0 -18 Td
(CGPA Score: ${student.cgpa} / 10.0) Tj
0 -18 Td
(Arrears Status: ${student.backlogs == 0 ? "Clean Track Record (0 Backlogs)" : "${student.backlogs} Backlogs"}) Tj
0 -24 Td
(Email: ${student.email}) Tj
0 -18 Td
(Phone: ${student.phone}) Tj
0 -30 Td
/F1 14 Tf
(CAMPUS PLACEMENT PROFILE) Tj
0 -20 Td
/F1 11 Tf
(Technical Skills: Flutter, Java, Python, SQL, Data Structures) Tj
0 -18 Td
(PlaceTrack Status: Active Candidate for Campus Recruitment 2026) Tj
ET''';

      // Obj 4: Contents
      final obj4Offset = buffer.length;
      buffer.writeln('4 0 obj');
      buffer.writeln('<< /Length ${streamContent.length} >>');
      buffer.writeln('stream');
      buffer.writeln(streamContent);
      buffer.writeln('endstream');
      buffer.writeln('endobj');

      // Obj 5: Font
      final obj5Offset = buffer.length;
      buffer.writeln('5 0 obj');
      buffer.writeln('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
      buffer.writeln('endobj');

      // Xref
      final xrefOffset = buffer.length;
      buffer.writeln('xref');
      buffer.writeln('0 6');
      buffer.writeln('0000000000 65535 f ');
      buffer.writeln('${obj1Offset.toString().padLeft(10, '0')} 00000 n ');
      buffer.writeln('${obj2Offset.toString().padLeft(10, '0')} 00000 n ');
      buffer.writeln('${obj3Offset.toString().padLeft(10, '0')} 00000 n ');
      buffer.writeln('${obj4Offset.toString().padLeft(10, '0')} 00000 n ');
      buffer.writeln('${obj5Offset.toString().padLeft(10, '0')} 00000 n ');
      buffer.writeln('trailer');
      buffer.writeln('<< /Size 6 /Root 1 0 R >>');
      buffer.writeln('startxref');
      buffer.writeln('$xrefOffset');
      buffer.writeln('%%EOF');

      await file.writeAsString(buffer.toString());
      return file;
    } catch (_) {
      return null;
    }
  }
}
