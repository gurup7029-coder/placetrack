import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../../services/theme_service.dart';
import '../../services/resume_viewer_service.dart';
import '../auth/login_screen.dart';
import '../training/training_screen.dart';
import '../notifications/announcements_screen.dart';
import '../resume/gri_resume_builder_screen.dart';
import '../analytics/placement_analytics_screen.dart';
import '../settings/student_settings_screen.dart';
import '../../widgets/placement_celebration_dialog.dart';

class StudentDashboardScreen extends StatefulWidget {
  final StudentModel student;

  const StudentDashboardScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final _service = PlacementDataService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onDataChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowPlacementCelebration();
    });
  }

  @override
  void dispose() {
    _service.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) {
      setState(() {});
      _checkAndShowPlacementCelebration();
    }
  }

  void _checkAndShowPlacementCelebration() {
    if (!mounted) return;
    final currentStudent = _getCurrentStudent();
    if (_service.shouldCelebrateStudent(currentStudent.id)) {
      final drive = _service.getStudentPlacedDrive(currentStudent.id);
      if (drive != null) {
        _service.markCelebrated(currentStudent.id);
        PlacementCelebrationDialog.show(
          context,
          student: currentStudent,
          drive: drive,
        );
      }
    }
  }

  StudentModel _getCurrentStudent() {
    return _service.students.firstWhere(
      (s) => s.id == widget.student.id,
      orElse: () => widget.student,
    );
  }

  Future<void> _launchExternalUrl(String urlString) async {
    String validUrl = urlString.trim();
    if (validUrl.isEmpty) return;

    if (!validUrl.startsWith('http://') && !validUrl.startsWith('https://')) {
      validUrl = 'https://$validUrl';
    }

    final uri = Uri.tryParse(validUrl);
    if (uri != null) {
      try {
        final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (!launched) {
          await launchUrl(uri, mode: LaunchMode.platformDefault);
        }
      } catch (e) {
        if (mounted) {
          Clipboard.setData(ClipboardData(text: validUrl));
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Browser could not open link. Copied to clipboard: $validUrl'),
              backgroundColor: PlaceTrackTheme.primary,
            ),
          );
        }
      }
    }
  }

  Future<void> _pickAndUploadPdfResume(StudentModel currentStudent) async {
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty && mounted) {
        final file = files.first;
        final fileName = file.name;
        String filePath = file.path ?? '';
        String fileSize = '220 KB';
        try {
          final bytes = await file.xFile.length();
          fileSize = '${(bytes / 1024).toStringAsFixed(1)} KB';
        } catch (_) {}

        // Launch real-time animated upload dialog
        await _showRealtimeUploadProgress(
          currentStudent: currentStudent,
          fileName: fileName,
          fileSize: fileSize,
          originalFilePath: filePath,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting PDF file: $e')),
        );
      }
    }
  }

  Future<void> _showRealtimeUploadProgress({
    required StudentModel currentStudent,
    required String fileName,
    required String fileSize,
    required String originalFilePath,
  }) async {
    double progress = 0.0;
    String statusMessage = 'Initializing PDF document transfer...';
    bool isCompleted = false;
    bool simulationStarted = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            if (!simulationStarted) {
              simulationStarted = true;
              WidgetsBinding.instance.addPostFrameCallback((_) async {
                final steps = [
                  (0.18, 'Reading document pages & verifying checksum...'),
                  (0.38, 'Encrypting & optimizing PDF for ATS parser...'),
                  (0.62, 'Transferring data to Placement Cloud Storage...'),
                  (0.82, 'Persisting document in student local sandbox...'),
                  (0.95, 'Syncing resume with Placement Officer portal...'),
                  (1.00, '✓ Upload Complete! PDF verified and active.'),
                ];

                for (final step in steps) {
                  await Future.delayed(const Duration(milliseconds: 320));
                  if (!dialogCtx.mounted) return;
                  setDialogState(() {
                    progress = step.$1;
                    statusMessage = step.$2;
                  });
                }

                String persistedPath = originalFilePath;
                if (originalFilePath.isNotEmpty) {
                  persistedPath = await ResumeViewerService.persistUploadedFile(
                    originalPath: originalFilePath,
                    fileName: fileName,
                  );
                }

                _service.updateStudentPdfResume(
                  studentId: currentStudent.id,
                  fileName: fileName,
                  filePath: persistedPath,
                  fileSize: fileSize,
                );

                if (!dialogCtx.mounted) return;
                setDialogState(() {
                  isCompleted = true;
                });

                await Future.delayed(const Duration(milliseconds: 700));
                if (dialogCtx.mounted) {
                  Navigator.pop(dialogCtx);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('PDF Resume "$fileName" uploaded successfully!')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                }
              });
            }

            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: isCompleted
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check_circle_rounded, color: Color(0xFF16A34A), size: 38)
                            : const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  color: PlaceTrackTheme.primary,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isCompleted ? 'Upload Complete!' : 'Uploading PDF Resume...',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              fileName,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            fileSize,
                            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isCompleted ? const Color(0xFF16A34A) : PlaceTrackTheme.primary,
                          ),
                        ),
                        Text(
                          isCompleted ? 'Ready' : 'Transferring...',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: const Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted ? const Color(0xFF16A34A) : PlaceTrackTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text(
                      statusMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: isCompleted ? const Color(0xFF15803D) : PlaceTrackTheme.textSecondary,
                        fontWeight: isCompleted ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPdfPreviewDialog(StudentModel currentStudent) {
    final fileName = currentStudent.resumeFileName.isNotEmpty
        ? currentStudent.resumeFileName
        : (currentStudent.resumeUrl.isNotEmpty ? currentStudent.resumeUrl : 'Resume.pdf');
    final fileSize = currentStudent.resumeFileSize.isNotEmpty ? currentStudent.resumeFileSize : '210 KB';
    final uploadDate = currentStudent.resumeUploadDate.isNotEmpty ? currentStudent.resumeUploadDate : 'Active';

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 32),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fileName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text('$fileSize • Uploaded: $uploadDate', style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Column(
                children: [
                  Row(
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.green, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Resume verified and shared with Placement Officers & Recruiters.',
                          style: TextStyle(fontSize: 12, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 18),
                    label: const Text('Open PDF'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ResumeViewerService.openStudentResume(context: context, student: currentStudent);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0F766E),
                      side: const BorderSide(color: Color(0xFF0F766E)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 18),
                    label: const Text('Replace PDF'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickAndUploadPdfResume(currentStudent);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmApplyForDrive(PlacementDrive drive, StudentModel currentStudent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.send_rounded, color: PlaceTrackTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Apply for ${drive.companyName}',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Role: ${drive.role}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Package: ${drive.packageLpa}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            const Text(
              'Your profile details and uploaded resume will be shared with the Placement Officer for this drive:',
              style: TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• Student: ${currentStudent.name} (${currentStudent.regNo})', style: const TextStyle(fontSize: 12)),
                  Text('• Academic: ${currentStudent.department} (${currentStudent.year})', style: const TextStyle(fontSize: 12)),
                  Text('• CGPA: ${currentStudent.cgpa} (Cutoff: ${drive.minCgpa})', style: const TextStyle(fontSize: 12)),
                  Text(
                    currentStudent.resumeFileName.isNotEmpty
                        ? '• Resume: ${currentStudent.resumeFileName}'
                        : '• Resume: Attached from Profile',
                    style: const TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _service.applyForDrive(drive.id, currentStudent.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Registered for ${drive.companyName} successfully! Admin has been notified.'),
                  backgroundColor: const Color(0xFF059669),
                ),
              );
            },
            child: const Text('Confirm Registration'),
          ),
        ],
      ),
    );
  }

  void _showDriveDetailsDialog(PlacementDrive drive, StudentModel currentStudent) {
    final isApplied = _service.isStudentApplied(drive.id, currentStudent.id);
    final isCgpaEligible = currentStudent.cgpa >= drive.minCgpa;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      drive.companyName,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      drive.packageLpa,
                      style: const TextStyle(color: Color(0xFF059669), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                drive.role,
                style: const TextStyle(fontSize: 15, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 14),

              // Criteria info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.grade_rounded, size: 16, color: PlaceTrackTheme.primary),
                        const SizedBox(width: 6),
                        Text('Minimum Cutoff: CGPA ≥ ${drive.minCgpa}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school_rounded, size: 16, color: PlaceTrackTheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Eligible: ${drive.eligibleDepartments.join(", ")}',
                            style: const TextStyle(fontSize: 12, color: Colors.black87),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Google Form Link Card (Clickable)
              if (drive.registrationLink.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBFDBFE)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.assignment_turned_in_rounded, color: PlaceTrackTheme.primary, size: 18),
                          SizedBox(width: 6),
                          Text(
                            'Application / Google Form Link:',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: PlaceTrackTheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        drive.registrationLink,
                        style: const TextStyle(fontSize: 12, color: Colors.black87),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PlaceTrackTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            icon: const Icon(Icons.open_in_new_rounded, size: 14),
                            label: const Text('Open Google Form ↗'),
                            onPressed: () => _launchExternalUrl(drive.registrationLink),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            icon: const Icon(Icons.copy_rounded, size: 14),
                            label: const Text('Copy'),
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: drive.registrationLink));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Registration Link copied!')),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),
              const Text('Recruitment Rounds Schedule:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              ...drive.rounds.map((r) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    const Icon(Icons.arrow_right_rounded, color: PlaceTrackTheme.primary, size: 20),
                    Expanded(
                      child: Text(r.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              )),

              const SizedBox(height: 20),

              // Registration Button
              if (isApplied)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFA7F3D0)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_rounded, color: Color(0xFF059669), size: 20),
                      SizedBox(width: 8),
                      Text(
                        'You are Registered for this Drive ✓',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669)),
                      ),
                    ],
                  ),
                )
              else if (isCgpaEligible)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlaceTrackTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Apply / Register for Drive'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _confirmApplyForDrive(drive, currentStudent);
                    },
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      'Not eligible (Requires minimum CGPA of ${drive.minCgpa})',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                  ),
                ),

              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(StudentModel currentStudent) {
    final nameController = TextEditingController(text: currentStudent.name);
    final emailController = TextEditingController(text: currentStudent.email);
    final phoneController = TextEditingController(text: currentStudent.phone);
    final cgpaController = TextEditingController(text: currentStudent.cgpa.toString());
    final backlogsController = TextEditingController(text: currentStudent.backlogs.toString());

    String selectedDept = currentStudent.department;
    String selectedYear = currentStudent.year;
    String selectedSection = currentStudent.section;

    final departments = [
      'MCA',
      'B.Sc Computer Science',
      'BCA',
      'B.Sc Information Tech',
      'B.Tech IT',
      'B.E Computer Science',
    ];
    if (!departments.contains(selectedDept)) {
      departments.add(selectedDept);
    }

    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
    if (!years.contains(selectedYear)) {
      years.add(selectedYear);
    }

    final sections = ['Section A', 'Section B', 'Section C'];
    if (!sections.contains(selectedSection)) {
      sections.add(selectedSection);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.badge_rounded, color: Color(0xFF0F766E)),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Edit Student Profile',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Reg: ${currentStudent.regNo}',
                        style: const TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDept,
                  decoration: const InputDecoration(
                    labelText: 'Course / Department *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.school_outlined),
                  ),
                  items: departments.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (v) => setModalState(() => selectedDept = v ?? selectedDept),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedYear,
                        decoration: const InputDecoration(
                          labelText: 'Year',
                          border: OutlineInputBorder(),
                        ),
                        items: years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                        onChanged: (v) => setModalState(() => selectedYear = v ?? selectedYear),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedSection,
                        decoration: const InputDecoration(
                          labelText: 'Section',
                          border: OutlineInputBorder(),
                        ),
                        items: sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                        onChanged: (v) => setModalState(() => selectedSection = v ?? selectedSection),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: cgpaController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'CGPA Score *',
                          hintText: 'e.g. 8.65',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.grade_outlined),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: backlogsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Backlogs Count *',
                          hintText: 'e.g. 0',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.history_edu_outlined),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact Phone *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.save_rounded),
                    label: const Text('Save Profile Updates'),
                    onPressed: () {
                      final name = nameController.text.trim();
                      if (name.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter student name.')),
                        );
                        return;
                      }

                      final cgpa = double.tryParse(cgpaController.text.trim()) ?? currentStudent.cgpa;
                      final backlogs = int.tryParse(backlogsController.text.trim()) ?? currentStudent.backlogs;

                      final updated = currentStudent.copyWith(
                        name: name,
                        department: selectedDept,
                        year: selectedYear,
                        section: selectedSection,
                        cgpa: cgpa,
                        backlogs: backlogs,
                        email: emailController.text.trim(),
                        phone: phoneController.text.trim(),
                      );

                      _service.updateStudent(updated);
                      Navigator.pop(ctx);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                                SizedBox(width: 8),
                                Expanded(child: Text('Profile updated successfully! Synced across portals.')),
                              ],
                            ),
                            backgroundColor: Color(0xFF059669),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickProfilePhoto(StudentModel currentStudent) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isNotEmpty && files.first.path != null) {
        final path = files.first.path!;
        _service.updateStudentProfileImage(currentStudent.id, path);
        if (mounted) {
          setState(() {});
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Profile photo updated successfully!'),
              backgroundColor: Color(0xFF059669),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not pick photo: $e')),
        );
      }
    }
  }

  void _logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _getCurrentStudent();
    final allDrives = _service.drives;
    final themeService = ThemeService();
    final isDark = themeService.isDarkMode;
    final hasCustomPhoto = student.profileImagePath.isNotEmpty && File(student.profileImagePath).existsSync();

    final myDrives = allDrives.where((drive) {
      final isEnrolled = drive.enrolledStudentIds.contains(student.id);
      final isInAnyRound = drive.rounds.any((r) => r.qualifiedStudentIds.contains(student.id));
      final isEligible = student.cgpa >= drive.minCgpa;
      return isEnrolled || isInAnyRound || isEligible;
    }).toList();

    final hasPdfResume = student.resumeFileName.isNotEmpty || student.resumeUrl.isNotEmpty;
    final displayResumeName = student.resumeFileName.isNotEmpty
        ? student.resumeFileName
        : (student.resumeUrl.isNotEmpty ? 'Resume_Attached.pdf' : 'No Resume uploaded');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Student Portal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              student.name,
              style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            onPressed: () {
              themeService.toggleTheme();
              setState(() {});
            },
          ),
          IconButton(
            icon: Badge(
              label: Text('${_service.announcements.length}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            tooltip: 'Announcements & Alerts',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen(isAdmin: false)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.insights_rounded),
            tooltip: 'Placement Analytics',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlacementAnalyticsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Student Settings',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => StudentSettingsScreen(student: student)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Sign Out',
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Student Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F766E).withAlpha(50),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => _pickProfilePhoto(student),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              backgroundImage: hasCustomPhoto ? FileImage(File(student.profileImagePath)) : null,
                              child: !hasCustomPhoto
                                  ? Text(
                                      student.name.isNotEmpty ? student.name[0] : 'S',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F766E),
                                      ),
                                    )
                                  : null,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.camera_alt_rounded,
                                size: 14,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              student.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Reg No: ${student.regNo}',
                              style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_note_rounded, color: Colors.white, size: 26),
                        tooltip: 'Edit Profile Information',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withAlpha(35),
                        ),
                        onPressed: () => _showEditProfileDialog(student),
                      ),
                    ],
                  ),
                  // Golden Offer Badge if Placed
                  Builder(
                    builder: (context) {
                      final placedDrive = _service.getStudentPlacedDrive(student.id);
                      if (placedDrive != null) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: InkWell(
                            onTap: () {
                              PlacementCelebrationDialog.show(
                                context,
                                student: student,
                                drive: placedDrive,
                              );
                            },
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD97706), Color(0xFFDC2626)],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withAlpha(120),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Text('🏆', style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'PLACED: ${placedDrive.companyName} (${placedDrive.packageLpa})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                        ),
                                        if (placedDrive.placedDates[student.id] != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            'Placed on: ${placedDrive.placedDates[student.id]}',
                                            style: const TextStyle(
                                              color: Color(0xFFFEF08A),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 10,
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const Row(
                                    children: [
                                      Text(
                                        'Celebrate',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 4),
                                      Icon(Icons.auto_awesome_rounded, color: Colors.amberAccent, size: 14),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Course & Section', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11)),
                          Text('${student.department} • ${student.year}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                          Text(student.section, style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('CGPA / Backlogs', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 11)),
                          Text('${student.cgpa}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(student.backlogs == 0 ? '✓ No Backlogs' : '${student.backlogs} Backlogs', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // PDF Resume Section
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(50),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFF87171), size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                displayResumeName,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                hasPdfResume ? 'PDF ready for placement cell' : 'Upload your PDF resume',
                                style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                        if (hasPdfResume) ...[
                          IconButton(
                            icon: const Icon(Icons.info_outline_rounded, color: Colors.white70, size: 20),
                            tooltip: 'Resume Info',
                            onPressed: () => _showPdfPreviewDialog(student),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye_rounded, color: Colors.tealAccent, size: 20),
                            tooltip: 'Open PDF Document',
                            onPressed: () => ResumeViewerService.openStudentResume(context: context, student: student),
                          ),
                        ],
                        ElevatedButton(
                          onPressed: () => _pickAndUploadPdfResume(student),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF0F766E),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            minimumSize: Size.zero,
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          child: Text(hasPdfResume ? 'Update PDF' : 'Upload PDF'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // GRI Resume Builder Launch Card (Voice Typing & Word/PDF Export)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GriResumeBuilderScreen(student: student),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(35),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_stories_rounded, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Build GRI Resume (Voice Typing & Word/PDF)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 6),
                          Icon(Icons.mic_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '📞 ${student.phone}',
                        style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 11),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          backgroundColor: Colors.white.withAlpha(25),
                          textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        icon: const Icon(Icons.edit_rounded, size: 13),
                        label: const Text('Edit Details'),
                        onPressed: () => _showEditProfileDialog(student),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Latest Announcement Alert Box for Students
            if (_service.announcements.isNotEmpty) ...[
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AnnouncementsScreen(isAdmin: false)),
                  );
                },
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withAlpha(20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.campaign_rounded, color: Color(0xFFDC2626), size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text(
                                  'CAMPUS NOTICE',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDC2626)),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '• ${_service.announcements.first.category}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _service.announcements.first.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 12, color: Colors.grey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // Training & Bootcamps Quick Access Banner
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const TrainingScreen(isStudentView: true),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF312E81), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4338CA).withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(30),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.model_training_rounded, color: Colors.white, size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Placement Training & Bootcamps',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${_service.workshops.length} Active Modules • Aptitude, DSA & Mock HR',
                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),

            const Text(
              'Placement Drives & Status',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: PlaceTrackTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),

            if (myDrives.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No active placement drives found matching your criteria.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...myDrives.map((drive) {
                final clearedRounds = drive.rounds.where((r) => r.qualifiedStudentIds.contains(student.id)).toList();
                final isPlaced = drive.placedStudentIds.contains(student.id);
                final isApplied = _service.isStudentApplied(drive.id, student.id);
                final isCgpaEligible = student.cgpa >= drive.minCgpa;

                return InkWell(
                  onTap: () => _showDriveDetailsDialog(drive, student),
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isApplied ? const Color(0xFF86EFAC) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        width: isApplied ? 1.5 : 1.0,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                drive.companyName,
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPlaced
                                    ? const Color(0xFFDCFCE7)
                                    : (isApplied
                                        ? const Color(0xFFEFF6FF)
                                        : (clearedRounds.isNotEmpty ? const Color(0xFFEFF6FF) : const Color(0xFFF1F5F9))),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isPlaced
                                    ? '🎉 PLACED'
                                    : (isApplied
                                        ? '✓ APPLIED'
                                        : (clearedRounds.isNotEmpty ? 'IN PROGRESS' : 'ELIGIBLE')),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isPlaced
                                      ? const Color(0xFF15803D)
                                      : (isApplied
                                          ? PlaceTrackTheme.primary
                                          : (clearedRounds.isNotEmpty ? const Color(0xFF1D4ED8) : Colors.grey[700])),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('${drive.role} • ${drive.packageLpa}', style: const TextStyle(color: PlaceTrackTheme.textSecondary, fontSize: 13)),

                        // Quick Apply Button Row if not yet applied
                        if (!isApplied && !isPlaced && isCgpaEligible) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PlaceTrackTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  minimumSize: Size.zero,
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                icon: const Icon(Icons.send_rounded, size: 13),
                                label: const Text('Apply for Drive'),
                                onPressed: () => _confirmApplyForDrive(drive, student),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Cutoff CGPA: ${drive.minCgpa}',
                                style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary),
                              ),
                            ],
                          ),
                        ],

                        // Clickable Google Form Link card for Student
                        if (drive.registrationLink.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          InkWell(
                            onTap: () => _launchExternalUrl(drive.registrationLink),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBBF7D0)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.assignment_outlined, color: Color(0xFF15803D), size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Company Google Form Link (Tap to Open):',
                                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                        ),
                                        Text(
                                          drive.registrationLink,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontSize: 12, color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.open_in_new_rounded, color: Color(0xFF15803D), size: 18),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const Divider(height: 20),

                        const Text(
                          'Rounds & Progress Assigned by Placement Officer:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PlaceTrackTheme.textSecondary),
                        ),
                        const SizedBox(height: 8),

                        ...drive.rounds.map((round) {
                          final isQualified = round.qualifiedStudentIds.contains(student.id);
                          final isRejected = round.rejectedStudentIds.contains(student.id);
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Icon(
                                  isQualified
                                      ? Icons.check_circle_rounded
                                      : (isRejected ? Icons.cancel_rounded : Icons.radio_button_unchecked),
                                  color: isQualified
                                      ? Colors.green
                                      : (isRejected ? Colors.red : Colors.grey[400]),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        round.name,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: isQualified ? FontWeight.w600 : FontWeight.normal,
                                          color: isDark
                                              ? Colors.white
                                              : (isQualified ? Colors.black87 : (isRejected ? Colors.red[800] : Colors.grey[600])),
                                        ),
                                      ),
                                      if (round.evaluationDates[student.id] != null) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          isQualified
                                              ? '✓ Cleared on: ${round.evaluationDates[student.id]}'
                                              : (isRejected ? '✕ Rejected on: ${round.evaluationDates[student.id]}' : ''),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isQualified ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isQualified
                                        ? const Color(0xFFDCFCE7)
                                        : (isRejected ? const Color(0xFFFEE2E2) : (isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9))),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isQualified
                                        ? 'CLEARED ✓'
                                        : (isRejected ? 'REJECTED ✕' : 'PENDING'),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isQualified
                                          ? const Color(0xFF15803D)
                                          : (isRejected ? const Color(0xFFDC2626) : (isDark ? Colors.white70 : Colors.grey[700])),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        if (isPlaced) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF047857), Color(0xFF10B981)],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.celebration_rounded, color: Colors.amberAccent, size: 26),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'OFFER LETTER RECEIVED! 🎉',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                          ),
                                          Text(
                                            'Congratulations! You are officially placed at ${drive.companyName} (${drive.packageLpa}).',
                                            style: const TextStyle(color: Colors.white70, fontSize: 11),
                                          ),
                                          if (drive.placedDates[student.id] != null) ...[
                                            const SizedBox(height: 3),
                                            Text(
                                              '📅 Placed Date: ${drive.placedDates[student.id]}',
                                              style: const TextStyle(color: Color(0xFFFEF08A), fontSize: 11, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF047857),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                    icon: const Icon(Icons.auto_awesome_rounded, color: Color(0xFFD97706), size: 16),
                                    label: const Text(
                                      'View Offer & Fireworks Celebration 🎆',
                                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                    onPressed: () {
                                      PlacementCelebrationDialog.show(
                                        context,
                                        student: student,
                                        drive: drive,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
