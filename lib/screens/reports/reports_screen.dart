import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import '../../app/theme.dart';
import '../../services/placement_data_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  static Future<void> _exportReportPdf(BuildContext context) async {
    final service = PlacementDataService();

    // Show loading status dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 3, color: PlaceTrackTheme.primary),
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Compiling Report...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    SizedBox(height: 4),
                    Text('Generating official PDF metrics...', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      await Future.delayed(const Duration(milliseconds: 600));
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/Placement_Report_2026.pdf');

      final totalStudents = service.totalStudentsCount;
      final totalPlaced = service.totalPlacedCount;
      final placementRate = service.placementPercentage.toStringAsFixed(1);
      final highestPkg = service.highestPackage;

      final buffer = StringBuffer();
      buffer.writeln('%PDF-1.4');

      final obj1Offset = buffer.length;
      buffer.writeln('1 0 obj');
      buffer.writeln('<< /Type /Catalog /Pages 2 0 R >>');
      buffer.writeln('endobj');

      final obj2Offset = buffer.length;
      buffer.writeln('2 0 obj');
      buffer.writeln('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
      buffer.writeln('endobj');

      final obj3Offset = buffer.length;
      buffer.writeln('3 0 obj');
      buffer.writeln('<< /Type /Page /Parent 2 0 R /MediaBox [0 0 612 792] /Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>');
      buffer.writeln('endobj');

      final streamContent = '''BT
/F1 20 Tf
50 720 Td
(PLACETRACK - ANNUAL PLACEMENT REPORT 2026) Tj
0 -30 Td
/F1 12 Tf
(Generated On: 25 Sep 2026) Tj
0 -25 Td
(KEY PLACEMENT METRICS:) Tj
0 -20 Td
/F1 11 Tf
(- Total Registered Students: $totalStudents) Tj
0 -18 Td
(- Total Students Placed: $totalPlaced) Tj
0 -18 Td
(- Overall Placement Percentage: $placementRate %) Tj
0 -18 Td
(- Highest CTC Offered: $highestPkg) Tj
0 -30 Td
/F1 13 Tf
(CAMPUS PLACEMENT PARTNERS & DRIVES) Tj
0 -20 Td
/F1 11 Tf
(- Active Partner Companies: ${service.drives.length}) Tj
0 -18 Td
(- Total Recruitment Rounds Conducted: ${service.drives.fold<int>(0, (sum, d) => sum + d.rounds.length)}) Tj
0 -30 Td
/F1 10 Tf
(CONFIDENTIAL - ISSUED BY PLACEMENT & TRAINING CELL) Tj
ET''';

      final obj4Offset = buffer.length;
      buffer.writeln('4 0 obj');
      buffer.writeln('<< /Length ${streamContent.length} >>');
      buffer.writeln('stream');
      buffer.writeln(streamContent);
      buffer.writeln('endstream');
      buffer.writeln('endobj');

      final obj5Offset = buffer.length;
      buffer.writeln('5 0 obj');
      buffer.writeln('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>');
      buffer.writeln('endobj');

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
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog
      }
      await OpenFilex.open(file.path);
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Dismiss loading dialog on error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error exporting report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final service = PlacementDataService();
    final students = service.students;
    final drives = service.drives;

    final totalStudents = service.totalStudentsCount;
    final totalPlaced = service.totalPlacedCount;
    final placementRate = service.placementPercentage.toStringAsFixed(1);
    final highestPkg = service.highestPackage;

    // Calculate dynamic department statistics:
    final deptStats = <String, Map<String, int>>{};
    for (final s in students) {
      deptStats.putIfAbsent(s.department, () => {'total': 0, 'placed': 0});
      deptStats[s.department]!['total'] = deptStats[s.department]!['total']! + 1;
    }
    for (final d in drives) {
      for (final sid in d.placedStudentIds) {
        final s = students.where((st) => st.id == sid).firstOrNull;
        if (s != null && deptStats.containsKey(s.department)) {
          deptStats[s.department]!['placed'] = deptStats[s.department]!['placed']! + 1;
        }
      }
    }

    final colors = [
      const Color(0xFF2563EB),
      const Color(0xFF7E3AF2),
      const Color(0xFF0E9F6E),
      const Color(0xFFEA580C),
      const Color(0xFFD97706),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Reports & Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            tooltip: 'Export PDF Report',
            onPressed: () => _exportReportPdf(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Executive Summary Banner
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Annual Placement Summary 2026', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    InkWell(
                      onTap: () => _exportReportPdf(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white12,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.download_rounded, color: Colors.tealAccent, size: 14),
                            SizedBox(width: 4),
                            Text('Export PDF', style: TextStyle(color: Colors.tealAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSummaryItem('Total Batch', '$totalStudents Students'),
                    _buildSummaryItem('Placed', '$totalPlaced Placed'),
                    _buildSummaryItem('Success Rate', '$placementRate%'),
                    _buildSummaryItem('Highest CTC', highestPkg),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Department wise Breakdown (Dynamic)
          const Text('Department Performance & Placement Rate', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PlaceTrackTheme.textPrimary)),
          const SizedBox(height: 10),

          if (deptStats.isEmpty)
            const Text('No department data available.')
          else
            ...deptStats.entries.toList().asMap().entries.map((entry) {
              final idx = entry.key;
              final deptEntry = entry.value;
              final deptName = deptEntry.key;
              final total = deptEntry.value['total'] ?? 1;
              final placed = deptEntry.value['placed'] ?? 0;
              final pct = total > 0 ? (placed / total) : 0.0;
              final color = colors[idx % colors.length];

              return _buildDeptRow(
                deptName,
                '$placed / $total Placed (${(pct * 100).toStringAsFixed(0)}%)',
                pct > 0 ? pct : 0.05,
                color,
              );
            }),

          const SizedBox(height: 20),

          // Placed Students List
          const Text('Recently Placed Candidates', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PlaceTrackTheme.textPrimary)),
          const SizedBox(height: 10),
          ...drives.expand((d) {
            return d.placedStudentIds.map((sid) {
              final student = students.firstWhere((s) => s.id == sid, orElse: () => students[0]);
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFECFDF5),
                      child: Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('${student.regNo} • ${student.department} (${student.year})', style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(d.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: PlaceTrackTheme.primary)),
                        Text(d.packageLpa, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11, color: Color(0xFF059669))),
                      ],
                    ),
                  ],
                ),
              );
            });
          }),
        ],
      ),
    );
  }

  static Widget _buildSummaryItem(String label, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    );
  }

  static Widget _buildDeptRow(String dept, String text, double val, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(dept, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: val.clamp(0.0, 1.0),
            backgroundColor: const Color(0xFFF1F5F9),
            color: color,
            minHeight: 6,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}
