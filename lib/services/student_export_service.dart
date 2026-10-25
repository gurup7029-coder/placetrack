import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import '../models/placement_models.dart';
import 'placement_data_service.dart';

class StudentExportService {
  static const List<String> availableColumns = [
    'Student Name',
    'Register Number',
    'Department / Course',
    'Year & Section',
    'CGPA Score',
    'Backlogs',
    'Email Address',
    'Phone Number',
    'Company Drive',
    'Round 1 Status',
    'Round 2 Status',
    'Final Status',
    'Package',
    'Resume File',
  ];

  static Future<void> exportStudentsCsv({
    required BuildContext context,
    required List<StudentModel> students,
    required List<String> selectedColumns,
    String? targetDriveId,
    String? filterSubtitle,
  }) async {
    try {
      final service = PlacementDataService();
      final rows = <List<dynamic>>[];

      // Header row
      rows.add(selectedColumns);

      // Data Rows
      for (final s in students) {
        final row = <dynamic>[];
        final drive = targetDriveId != null && targetDriveId.isNotEmpty
            ? service.drives.where((d) => d.id == targetDriveId).firstOrNull
            : service.drives.where((d) => d.placedStudentIds.contains(s.id)).firstOrNull;

        for (final col in selectedColumns) {
          switch (col) {
            case 'Student Name':
              row.add(s.name);
              break;
            case 'Register Number':
              row.add(s.regNo);
              break;
            case 'Department / Course':
              row.add(s.department);
              break;
            case 'Year & Section':
              row.add('${s.year} - ${s.section}');
              break;
            case 'CGPA Score':
              row.add(s.cgpa.toStringAsFixed(2));
              break;
            case 'Backlogs':
              row.add(s.backlogs);
              break;
            case 'Email Address':
              row.add(s.email);
              break;
            case 'Phone Number':
              row.add(s.phone);
              break;
            case 'Company Drive':
              if (drive != null) {
                row.add(drive.companyName);
              } else {
                row.add('All Companies');
              }
              break;
            case 'Round 1 Status':
              if (drive != null && drive.rounds.isNotEmpty) {
                final r1 = drive.rounds[0];
                if (r1.qualifiedStudentIds.contains(s.id)) {
                  row.add('Cleared');
                } else if (r1.rejectedStudentIds.contains(s.id)) {
                  row.add('Rejected');
                } else {
                  row.add('Pending');
                }
              } else {
                row.add('N/A');
              }
              break;
            case 'Round 2 Status':
              if (drive != null && drive.rounds.length > 1) {
                final r2 = drive.rounds[1];
                if (r2.qualifiedStudentIds.contains(s.id)) {
                  row.add('Cleared');
                } else if (r2.rejectedStudentIds.contains(s.id)) {
                  row.add('Rejected');
                } else {
                  row.add('Pending');
                }
              } else {
                row.add('N/A');
              }
              break;
            case 'Final Status':
              if (drive != null && drive.placedStudentIds.contains(s.id)) {
                row.add('Placed');
              } else if (drive != null &&
                  drive.rounds.any((r) => r.rejectedStudentIds.contains(s.id))) {
                row.add('Rejected');
              } else if (s.cgpa >= 7.0 && s.backlogs == 0) {
                row.add('Eligible / Active');
              } else {
                row.add('Ineligible');
              }
              break;
            case 'Package':
              if (drive != null && drive.placedStudentIds.contains(s.id)) {
                row.add(drive.packageLpa);
              } else {
                row.add('-');
              }
              break;
            case 'Resume File':
              row.add(s.resumeFileName.isNotEmpty
                  ? s.resumeFileName
                  : (s.resumeUrl.isNotEmpty ? 'Linked' : 'Not Uploaded'));
              break;
            default:
              row.add('');
          }
        }
        rows.add(row);
      }

      final csvBuffer = StringBuffer();
      for (final r in rows) {
        final line = r.map((c) {
          final s = c.toString().replaceAll('\n', ' ').replaceAll('"', '""');
          return '"$s"';
        }).join(',');
        csvBuffer.writeln(line);
      }

      final csvData = csvBuffer.toString();
      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/PlaceTrack_Students_$timestamp.csv');
      await file.writeAsString(csvData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.table_chart_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('Excel/CSV exported: ${file.path.split('/').last}')),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
          ),
        );
      }

      await OpenFilex.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export CSV: $e')),
        );
      }
    }
  }

  static Future<void> exportStudentsPdf({
    required BuildContext context,
    required List<StudentModel> students,
    required List<String> selectedColumns,
    String? targetDriveId,
    String? filterSubtitle,
  }) async {
    try {
      final service = PlacementDataService();
      final pdf = pw.Document();

      final headers = selectedColumns;
      final data = <List<String>>[];

      for (final s in students) {
        final row = <String>[];
        final drive = targetDriveId != null && targetDriveId.isNotEmpty
            ? service.drives.where((d) => d.id == targetDriveId).firstOrNull
            : service.drives.where((d) => d.placedStudentIds.contains(s.id)).firstOrNull;

        for (final col in selectedColumns) {
          switch (col) {
            case 'Student Name':
              row.add(s.name);
              break;
            case 'Register Number':
              row.add(s.regNo);
              break;
            case 'Department / Course':
              row.add(s.department);
              break;
            case 'Year & Section':
              row.add('${s.year}\n${s.section}');
              break;
            case 'CGPA Score':
              row.add(s.cgpa.toStringAsFixed(2));
              break;
            case 'Backlogs':
              row.add('${s.backlogs}');
              break;
            case 'Email Address':
              row.add(s.email);
              break;
            case 'Phone Number':
              row.add(s.phone);
              break;
            case 'Company Drive':
              row.add(drive != null ? drive.companyName : 'All');
              break;
            case 'Round 1 Status':
              if (drive != null && drive.rounds.isNotEmpty) {
                final r1 = drive.rounds[0];
                if (r1.qualifiedStudentIds.contains(s.id)) {
                  row.add('Cleared');
                } else if (r1.rejectedStudentIds.contains(s.id)) {
                  row.add('Rejected');
                } else {
                  row.add('Pending');
                }
              } else {
                row.add('-');
              }
              break;
            case 'Round 2 Status':
              if (drive != null && drive.rounds.length > 1) {
                final r2 = drive.rounds[1];
                if (r2.qualifiedStudentIds.contains(s.id)) {
                  row.add('Cleared');
                } else if (r2.rejectedStudentIds.contains(s.id)) {
                  row.add('Rejected');
                } else {
                  row.add('Pending');
                }
              } else {
                row.add('-');
              }
              break;
            case 'Final Status':
              if (drive != null && drive.placedStudentIds.contains(s.id)) {
                row.add('Placed 🎉');
              } else if (drive != null &&
                  drive.rounds.any((r) => r.rejectedStudentIds.contains(s.id))) {
                row.add('Rejected');
              } else if (s.cgpa >= 7.0 && s.backlogs == 0) {
                row.add('Eligible');
              } else {
                row.add('Ineligible');
              }
              break;
            case 'Package':
              if (drive != null && drive.placedStudentIds.contains(s.id)) {
                row.add(drive.packageLpa);
              } else {
                row.add('-');
              }
              break;
            case 'Resume File':
              row.add(s.resumeFileName.isNotEmpty ? 'Uploaded' : 'Pending');
              break;
            default:
              row.add('');
          }
        }
        data.add(row);
      }

      final pageFormat = selectedColumns.length > 5 ? PdfPageFormat.a4.landscape : PdfPageFormat.a4;

      pdf.addPage(
        pw.MultiPage(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context ctx) => [
            // College Letterhead Banner
            pw.Container(
              padding: const pw.EdgeInsets.only(bottom: 12),
              decoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.blue900, width: 2)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PLACETRACK • CAMPUS PLACEMENT CELL',
                        style: pw.TextStyle(
                          color: PdfColors.blue900,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        filterSubtitle != null && filterSubtitle.isNotEmpty
                            ? 'Report Filter: $filterSubtitle'
                            : 'Official Filtered Student Directory Report • Academic Batch 2025-26',
                        style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        'Generated: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                        style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey800),
                      ),
                      pw.Text(
                        'Total Students: ${students.length}',
                        style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 14),

            // Students Table
            pw.TableHelper.fromTextArray(
              headers: headers,
              data: data,
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              headerStyle: pw.TextStyle(
                fontSize: 8.5,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.blue800,
              ),
              cellStyle: const pw.TextStyle(
                fontSize: 8,
                color: PdfColors.black,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              headerAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 5, vertical: 4),
            ),

            pw.SizedBox(height: 16),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Verified by Placement Director & Authorized Signatory',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
                pw.Text(
                  'PlaceTrack Mobile Portal Generated Document',
                  style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                ),
              ],
            ),
          ],
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/PlaceTrack_Students_Report_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text('PDF report exported: ${file.path.split('/').last}')),
              ],
            ),
            backgroundColor: const Color(0xFF0F766E),
          ),
        );
      }

      await OpenFilex.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export PDF: $e')),
        );
      }
    }
  }
}
