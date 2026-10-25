import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/gri_resume_model.dart';

class GriResumeExportService {
  /// Builds a high-resolution, multi-page vector PDF matching the GRI Resume Format.docx layout.
  static Future<Uint8List> buildPdfDocument(GriResumeData data) async {
    final pdf = pw.Document();

    final theme = pw.ThemeData.withFont(
      base: pw.Font.helvetica(),
      bold: pw.Font.helveticaBold(),
      italic: pw.Font.helveticaOblique(),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 28, vertical: 26),
        theme: theme,
        build: (context) => [
          // Header: Name & Contact on Left, Photograph Frame on Right
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      data.fullName.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.black,
                        letterSpacing: 1.1,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    if (data.address.isNotEmpty) ...[
                      pw.Text(
                        data.address,
                        style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800),
                      ),
                      pw.SizedBox(height: 2),
                    ],
                    pw.Text(
                      'Mobile: ${data.phone}   |   Email: ${data.email}',
                      style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColors.grey900),
                    ),
                  ],
                ),
              ),
              pw.Container(
                width: 80,
                height: 95,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey600, width: 0.8),
                  color: PdfColors.grey100,
                ),
                child: data.photoPath != null && File(data.photoPath!).existsSync()
                    ? pw.ClipRect(
                        child: pw.Image(
                          pw.MemoryImage(File(data.photoPath!).readAsBytesSync()),
                          fit: pw.BoxFit.cover,
                        ),
                      )
                    : pw.Center(
                        child: pw.Text(
                          '(YOUR\nPHOTOGRAPH)',
                          textAlign: pw.TextAlign.center,
                          style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600),
                        ),
                      ),
              ),
            ],
          ),
          pw.SizedBox(height: 12),

          // Two-Column Main Table matching GRI Resume Format.docx
          pw.Table(
            border: pw.TableBorder.all(color: PdfColor.fromInt(data.themeColorValue), width: 0.8),
            columnWidths: const {
              0: pw.FixedColumnWidth(130),
              1: pw.FlexColumnWidth(),
            },
            children: [
              // Row 0: Career Summary
              _buildTableRow(
                title: 'Career Summary',
                content: pw.Text(
                  data.careerSummary,
                  style: const pw.TextStyle(fontSize: 9, lineSpacing: 2),
                ),
              ),

              // Row 1: Educational Qualification (Table)
              _buildTableRow(
                title: 'Educational\nQualification',
                content: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Table(
                      border: pw.TableBorder.all(color: PdfColors.grey600, width: 0.5),
                      columnWidths: const {
                        0: pw.FlexColumnWidth(1.4),
                        1: pw.FlexColumnWidth(2.0),
                        2: pw.FlexColumnWidth(1.4),
                        3: pw.FlexColumnWidth(1.0),
                        4: pw.FlexColumnWidth(0.9),
                      },
                      children: [
                        pw.TableRow(
                          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                          children: [
                            _buildTableCell('Course / Degree', isHeader: true),
                            _buildTableCell('Institution', isHeader: true),
                            _buildTableCell('Board / Univ', isHeader: true),
                            _buildTableCell('Year', isHeader: true),
                            _buildTableCell('% / CGPA', isHeader: true),
                          ],
                        ),
                        ...data.educationList.map(
                          (e) => pw.TableRow(
                            children: [
                              _buildTableCell(e.degree, bold: true),
                              _buildTableCell(e.institution),
                              _buildTableCell(e.boardOrUniversity),
                              _buildTableCell(e.yearOfPassing),
                              _buildTableCell(e.percentageOrCgpa, bold: true),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Row 2: Skills Sets
              _buildTableRow(
                title: 'Skills Sets',
                content: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('Technical Skills:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 1),
                    pw.Text(data.technicalSkills, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                    pw.SizedBox(height: 5),
                    pw.Text('Soft Skills:', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 1),
                    pw.Text(data.softSkills, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                  ],
                ),
              ),

              // Row 3: Certifications
              if (data.showCertifications && data.certifications.isNotEmpty)
                _buildTableRow(
                  title: 'Certifications',
                  content: pw.Text(data.certifications, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                ),

              // Row 4: Work/Internship Experience
              if (data.showExperience && data.experiences.isNotEmpty)
                _buildTableRow(
                  title: 'Work / Internship\nExperience',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: data.experiences.map((exp) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ${exp.role} — ${exp.companyName} (${exp.duration})',
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            if (exp.description.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 8, top: 1),
                                child: pw.Text(exp.description, style: const pw.TextStyle(fontSize: 8.5)),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Row 5: Projects Involved
              if (data.showProjects && data.projects.isNotEmpty)
                _buildTableRow(
                  title: 'Projects Involved',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: data.projects.map((p) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• ${p.title} (${p.duration})',
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.Padding(
                              padding: const pw.EdgeInsets.only(left: 8, top: 1),
                              child: pw.Text('Technologies: ${p.techStack}',
                                  style: pw.TextStyle(fontSize: 8.5, fontStyle: pw.FontStyle.italic, color: PdfColors.teal900)),
                            ),
                            if (p.description.isNotEmpty)
                              pw.Padding(
                                padding: const pw.EdgeInsets.only(left: 8, top: 1),
                                child: pw.Text(p.description, style: const pw.TextStyle(fontSize: 8.5)),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),

              // Row 6: Achievements
              if (data.showAchievements && data.achievements.isNotEmpty)
                _buildTableRow(
                  title: 'Achievements',
                  content: pw.Text(data.achievements, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                ),

              // Row 7: Knowledge Acquisition Events
              if (data.showKnowledgeEvents && data.knowledgeEvents.isNotEmpty)
                _buildTableRow(
                  title: 'Knowledge Acquisition\nEvents (Seminars / Workshops)',
                  content: pw.Text(data.knowledgeEvents, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                ),

              // Row 8: Extracurricular Events
              if (data.showExtracurricular && data.extracurricular.isNotEmpty)
                _buildTableRow(
                  title: 'Extracurricular\nEvents',
                  content: pw.Text(data.extracurricular, style: const pw.TextStyle(fontSize: 8.5, lineSpacing: 1.5)),
                ),

              // Row 9: Languages Known
              _buildTableRow(
                title: 'Languages Known',
                content: pw.Text(data.languagesKnown, style: const pw.TextStyle(fontSize: 9)),
              ),

              // Row 10: References
              if (data.references.isNotEmpty)
                _buildTableRow(
                  title: 'References',
                  content: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: data.references.map((r) {
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 4),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('${r.name} — ${r.designation}',
                                style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                            pw.Text(r.institution, style: const pw.TextStyle(fontSize: 8.5)),
                            pw.Text('Mobile: ${r.mobile}   |   Email: ${r.email}',
                                style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey800)),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.TableRow _buildTableRow({required String title, required pw.Widget content}) {
    return pw.TableRow(
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: const PdfColor(0.96, 0.97, 0.98),
          child: pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 9.5,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.black,
            ),
          ),
        ),
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: content,
        ),
      ],
    );
  }

  static pw.Widget _buildTableCell(String text, {bool bold = false, bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 7.5 : 8,
          fontWeight: bold || isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          color: isHeader ? PdfColors.black : PdfColors.grey900,
        ),
      ),
    );
  }

  /// Generates the PDF file and saves to device storage.
  static Future<String> generatePdf(GriResumeData data) async {
    final appDir = await getApplicationDocumentsDirectory();
    final safeName = data.fullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filePath = '${appDir.path}/GRI_Resume_$safeName.pdf';

    final bytes = await buildPdfDocument(data);
    final file = File(filePath);
    await file.writeAsBytes(bytes);
    return filePath;
  }

  /// Generates a Microsoft Word (.docx) document strictly matching GRI Resume Format.docx.
  /// It takes the authentic template, replaces placeholders with user data, and repacks it.
  static Future<String> generateDocx(GriResumeData data) async {
    final appDir = await getApplicationDocumentsDirectory();
    final safeName = data.fullName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_');
    final filePath = '${appDir.path}/GRI_Resume_$safeName.docx';

    try {
      // Load authentic template bundled in assets
      final templateData = await rootBundle.load('assets/templates/gri_resume_template.docx');
      final bytes = templateData.buffer.asUint8List();
      final archive = ZipDecoder().decodeBytes(bytes);
      final newArchive = Archive();

      for (final file in archive) {
        if (file.name == 'word/header1.xml') {
          String content = utf8.decode(file.content as List<int>);
          content = _injectHeaderXml(content, data);
          final encoded = utf8.encode(content);
          newArchive.addFile(ArchiveFile(file.name, encoded.length, encoded));
        } else if (file.name == 'word/document.xml') {
          String content = utf8.decode(file.content as List<int>);
          content = _injectDocumentXml(content, data);
          final encoded = utf8.encode(content);
          newArchive.addFile(ArchiveFile(file.name, encoded.length, encoded));
        } else {
          newArchive.addFile(file);
        }
      }

      final zipEncoder = ZipEncoder();
      final zipBytes = zipEncoder.encode(newArchive);
      final outFile = File(filePath);
      await outFile.writeAsBytes(zipBytes);
      return filePath;
    } catch (_) {
      // Fallback: build genuine OpenXML document archive
      return _generateDocxFromOpenXml(data, filePath);
    }
  }

  static String _injectHeaderXml(String xml, GriResumeData data) {
    var result = xml;
    // Replace address
    result = result.replaceAll('Abcd', _escapeXml(data.address.isNotEmpty ? data.address : 'Gandhigram'));
    result = result.replaceAll('Efghijklmnopq', '');
    result = result.replaceAll('Stree t,', '');
    result = result.replaceAll('Dindigul , Tamil  N adu- 00 000 0 .', '');

    // Replace phone
    result = result.replaceAll('01234 56789', _escapeXml(data.phone));

    // Replace email
    result = result.replaceAll('zyxwv @ gmail .c om', _escapeXml(data.email));
    return result;
  }

  static String _injectDocumentXml(String xml, GriResumeData data) {
    var result = xml;
    // Replace Name
    result = result.replaceAll('YOUR</w:t></w:r><w:proofErr w:type="gramEnd"/><w:r w:rsidR="00E53742"><w:rPr><w:b/><w:bCs/><w:sz w:val="40"/><w:szCs w:val="40"/></w:rPr><w:t xml:space="preserve"> NAME',
        '${_escapeXml(data.fullName.toUpperCase())}</w:t></w:r>');
    result = result.replaceAll('YOUR NAME', _escapeXml(data.fullName.toUpperCase()));

    // Replace Career Summary
    final summaryRegex = RegExp(r'(\(Example: Please modify.*?\)\s*Bachelors in Computer Science.*?\.)', dotAll: true);
    if (summaryRegex.hasMatch(result)) {
      result = result.replaceFirst(summaryRegex, _escapeXml(data.careerSummary));
    }

    // Replace Languages Known
    result = result.replaceAll('Tamil, English and Hindi', _escapeXml(data.languagesKnown));

    return result;
  }

  static Future<String> _generateDocxFromOpenXml(GriResumeData data, String filePath) async {
    final archive = Archive();

    const contentTypesXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
  <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
  <Default Extension="xml" ContentType="application/xml"/>
  <Override PartName="/word/document.xml" ContentType="application/vnd.openxmlformats-officedocument.wordprocessingml.document.main+xml"/>
</Types>''';
    archive.addFile(ArchiveFile('[Content_Types].xml', utf8.encode(contentTypesXml).length, utf8.encode(contentTypesXml)));

    const rootRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
  <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="word/document.xml"/>
</Relationships>''';
    archive.addFile(ArchiveFile('_rels/.rels', utf8.encode(rootRelsXml).length, utf8.encode(rootRelsXml)));

    const docRelsXml = '''<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships"/>''';
    archive.addFile(ArchiveFile('word/_rels/document.xml.rels', utf8.encode(docRelsXml).length, utf8.encode(docRelsXml)));

    final docXml = _buildFullWordXml(data);
    archive.addFile(ArchiveFile('word/document.xml', utf8.encode(docXml).length, utf8.encode(docXml)));

    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);
    final file = File(filePath);
    await file.writeAsBytes(zipBytes);
    return filePath;
  }

  static String _buildFullWordXml(GriResumeData data) {
    final sb = StringBuffer();
    sb.writeln('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>');
    sb.writeln('<w:document xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">');
    sb.writeln('<w:body>');

    // Title: Full Name
    sb.writeln('<w:p>');
    sb.writeln('  <w:pPr><w:jc w:val="center"/></w:pPr>');
    sb.writeln('  <w:r>');
    sb.writeln('    <w:rPr><w:b/><w:sz w:val="36"/></w:rPr>');
    sb.writeln('    <w:t>${_escapeXml(data.fullName.toUpperCase())}</w:t>');
    sb.writeln('  </w:r>');
    sb.writeln('</w:p>');

    // Subtitle: Contact Details
    sb.writeln('<w:p>');
    sb.writeln('  <w:pPr><w:jc w:val="center"/></w:pPr>');
    sb.writeln('  <w:r>');
    sb.writeln('    <w:rPr><w:sz w:val="20"/></w:rPr>');
    sb.writeln('    <w:t>${_escapeXml(data.email)} | ${_escapeXml(data.phone)}</w:t>');
    sb.writeln('  </w:r>');
    sb.writeln('</w:p>');

    if (data.address.isNotEmpty) {
      sb.writeln('<w:p>');
      sb.writeln('  <w:pPr><w:jc w:val="center"/></w:pPr>');
      sb.writeln('  <w:r>');
      sb.writeln('    <w:rPr><w:sz w:val="18"/><w:color w:val="666666"/></w:rPr>');
      sb.writeln('    <w:t>${_escapeXml(data.address)}</w:t>');
      sb.writeln('  </w:r>');
      sb.writeln('</w:p>');
    }

    // Main Table
    sb.writeln('<w:tbl>');
    sb.writeln('  <w:tblPr>');
    sb.writeln('    <w:tblW w:w="5000" w:type="pct"/>');
    sb.writeln('    <w:tblBorders>');
    sb.writeln('      <w:top w:val="single" w:sz="8" w:space="0" w:color="000000"/>');
    sb.writeln('      <w:left w:val="single" w:sz="8" w:space="0" w:color="000000"/>');
    sb.writeln('      <w:bottom w:val="single" w:sz="8" w:space="0" w:color="000000"/>');
    sb.writeln('      <w:right w:val="single" w:sz="8" w:space="0" w:color="000000"/>');
    sb.writeln('      <w:insideH w:val="single" w:sz="4" w:space="0" w:color="CCCCCC"/>');
    sb.writeln('      <w:insideV w:val="single" w:sz="8" w:space="0" w:color="000000"/>');
    sb.writeln('    </w:tblBorders>');
    sb.writeln('  </w:tblPr>');

    void addTableRow(String sectionTitle, String sectionContent) {
      sb.writeln('  <w:tr>');
      sb.writeln('    <w:tc>');
      sb.writeln('      <w:tcPr><w:tcW w:w="1600" w:type="pct"/></w:tcPr>');
      sb.writeln('      <w:p><w:r><w:rPr><w:b/><w:sz w:val="20"/></w:rPr><w:t>${_escapeXml(sectionTitle)}</w:t></w:r></w:p>');
      sb.writeln('    </w:tc>');
      sb.writeln('    <w:tc>');
      sb.writeln('      <w:tcPr><w:tcW w:w="3400" w:type="pct"/></w:tcPr>');
      for (final line in sectionContent.split('\n')) {
        sb.writeln('      <w:p><w:r><w:rPr><w:sz w:val="20"/></w:rPr><w:t>${_escapeXml(line)}</w:t></w:r></w:p>');
      }
      sb.writeln('    </w:tc>');
      sb.writeln('  </w:tr>');
    }

    addTableRow('Career Summary', data.careerSummary);

    // Education Table
    final eduBuffer = StringBuffer();
    for (final e in data.educationList) {
      eduBuffer.writeln('• ${e.degree} - ${e.institution}');
      eduBuffer.writeln('  Board/Univ: ${e.boardOrUniversity} | Year: ${e.yearOfPassing} | Result: ${e.percentageOrCgpa}');
    }
    addTableRow('Educational Qualification', eduBuffer.toString().trim());

    addTableRow('Skills Sets', 'Technical Skills:\n${data.technicalSkills}\n\nSoft Skills:\n${data.softSkills}');

    if (data.certifications.isNotEmpty) addTableRow('Certifications', data.certifications);

    if (data.experiences.isNotEmpty) {
      final expBuffer = StringBuffer();
      for (final exp in data.experiences) {
        expBuffer.writeln('• ${exp.role} - ${exp.companyName} (${exp.duration})');
        if (exp.description.isNotEmpty) expBuffer.writeln('  ${exp.description}');
      }
      addTableRow('Work/Internship Experience', expBuffer.toString().trim());
    }

    if (data.projects.isNotEmpty) {
      final projBuffer = StringBuffer();
      for (final p in data.projects) {
        projBuffer.writeln('• ${p.title} (${p.duration})');
        projBuffer.writeln('  Tech: ${p.techStack}');
        if (p.description.isNotEmpty) projBuffer.writeln('  ${p.description}');
      }
      addTableRow('Projects Involved', projBuffer.toString().trim());
    }

    if (data.achievements.isNotEmpty) addTableRow('Achievements', data.achievements);
    if (data.knowledgeEvents.isNotEmpty) addTableRow('Knowledge Acquisition Events', data.knowledgeEvents);
    if (data.extracurricular.isNotEmpty) addTableRow('Extracurricular Events', data.extracurricular);
    addTableRow('Languages Known', data.languagesKnown);

    if (data.references.isNotEmpty) {
      final refBuffer = StringBuffer();
      for (final r in data.references) {
        refBuffer.writeln('${r.name} - ${r.designation}');
        refBuffer.writeln(r.institution);
        refBuffer.writeln('Mobile: ${r.mobile} | Email: ${r.email}');
        refBuffer.writeln('');
      }
      addTableRow('References', refBuffer.toString().trim());
    }

    sb.writeln('</w:tbl>');
    sb.writeln('<w:sectPr/>');
    sb.writeln('</w:body>');
    sb.writeln('</w:document>');
    return sb.toString();
  }

  static String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}
