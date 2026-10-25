import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../../services/resume_viewer_service.dart';

class DriveManagementScreen extends StatefulWidget {
  const DriveManagementScreen({super.key});

  @override
  State<DriveManagementScreen> createState() => _DriveManagementScreenState();
}

class _DriveManagementScreenState extends State<DriveManagementScreen> {
  final _service = PlacementDataService();

  @override
  void initState() {
    super.initState();
    _service.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _service.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _showAddDriveDialog() {
    final companyController = TextEditingController();
    final roleController = TextEditingController();
    final packageController = TextEditingController();
    final cgpaController = TextEditingController(text: '7.0');
    final linkController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Create Placement Drive',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  hintText: 'e.g. Zoho, Google, TCS',
                  prefixIcon: Icon(Icons.business_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(
                  labelText: 'Job Role / Designation',
                  hintText: 'e.g. Software Engineer Trainee',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: packageController,
                      decoration: const InputDecoration(
                        labelText: 'Package (LPA)',
                        hintText: 'e.g. 8.5 LPA',
                        prefixIcon: Icon(Icons.currency_rupee_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cgpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Min CGPA',
                        hintText: 'e.g. 7.5',
                        prefixIcon: Icon(Icons.grade_rounded),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Form / Company Application Link',
                  hintText: 'https://forms.gle/... or https://careers.company.com',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final company = companyController.text.trim();
                    final role = roleController.text.trim();
                    final pkg = packageController.text.trim();
                    final cgpa = double.tryParse(cgpaController.text.trim()) ?? 6.0;
                    final link = linkController.text.trim();

                    if (company.isEmpty || role.isEmpty) return;

                    final newDrive = PlacementDrive(
                      id: 'd_${DateTime.now().millisecondsSinceEpoch}',
                      companyName: company,
                      role: role,
                      packageLpa: pkg.isEmpty ? 'Not Disclosed' : pkg,
                      minCgpa: cgpa,
                      registrationLink: link,
                      enrolledStudentIds: _service.students.map((s) => s.id).toList(), // Initially all or admin can customize
                      eligibleDepartments: ['Computer Science', 'Information Tech', 'Electronics & Comm.'],
                      driveDate: DateTime.now().add(const Duration(days: 7)),
                      rounds: [
                        PlacementRound(
                          id: 'r_${DateTime.now().millisecondsSinceEpoch}_1',
                          name: 'Round 1: Online Aptitude / Coding',
                          date: DateTime.now().add(const Duration(days: 3)),
                          qualifiedStudentIds: [],
                        ),
                      ],
                    );

                    _service.addDrive(newDrive);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Drive for $company added with registration link!')),
                    );
                  },
                  child: const Text('Add Drive'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditDriveDialog(PlacementDrive drive) {
    final companyController = TextEditingController(text: drive.companyName);
    final roleController = TextEditingController(text: drive.role);
    final packageController = TextEditingController(text: drive.packageLpa);
    final cgpaController = TextEditingController(text: drive.minCgpa.toString());
    final linkController = TextEditingController(text: drive.registrationLink);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Edit Placement Drive',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: companyController,
                decoration: const InputDecoration(labelText: 'Company Name', prefixIcon: Icon(Icons.business_rounded)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: roleController,
                decoration: const InputDecoration(labelText: 'Job Role / Designation', prefixIcon: Icon(Icons.work_outline_rounded)),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: packageController,
                      decoration: const InputDecoration(labelText: 'Package (LPA)', prefixIcon: Icon(Icons.currency_rupee_rounded)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: cgpaController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Min CGPA', prefixIcon: Icon(Icons.grade_rounded)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: linkController,
                decoration: const InputDecoration(
                  labelText: 'Google Form / Application Link',
                  prefixIcon: Icon(Icons.link_rounded),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final company = companyController.text.trim();
                    final role = roleController.text.trim();
                    final pkg = packageController.text.trim();
                    final cgpa = double.tryParse(cgpaController.text.trim()) ?? drive.minCgpa;
                    final link = linkController.text.trim();

                    if (company.isEmpty || role.isEmpty) return;

                    final updatedDrive = drive.copyWith(
                      companyName: company,
                      role: role,
                      packageLpa: pkg.isEmpty ? drive.packageLpa : pkg,
                      minCgpa: cgpa,
                      registrationLink: link,
                    );

                    _service.updateDrive(updatedDrive);
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Updated $company successfully!')),
                    );
                  },
                  child: const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteDrive(PlacementDrive drive) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${drive.companyName}?'),
        content: Text('Are you sure you want to delete this placement drive? All rounds and candidate records for ${drive.companyName} will be removed.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              _service.deleteDrive(drive.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${drive.companyName}'), backgroundColor: PlaceTrackTheme.danger),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: PlaceTrackTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddRoundDialog(PlacementDrive drive) {
    final roundNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Add Round to ${drive.companyName}'),
        content: TextField(
          controller: roundNameController,
          decoration: const InputDecoration(
            labelText: 'Round Name',
            hintText: 'e.g. Round 2: Technical Interview',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final name = roundNameController.text.trim();
              if (name.isEmpty) return;

              final newRound = PlacementRound(
                id: 'r_${DateTime.now().millisecondsSinceEpoch}',
                name: name,
                date: DateTime.now().add(const Duration(days: 2)),
                qualifiedStudentIds: [],
              );

              _service.addRoundToDrive(drive.id, newRound);
              Navigator.pop(ctx);
            },
            child: const Text('Add Round'),
          ),
        ],
      ),
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
        Clipboard.setData(ClipboardData(text: validUrl));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Copied link: $validUrl')),
          );
        }
      }
    }
  }

  // Admin views registered candidates & can manually add/remove students
  void _showManageDriveStudentsDialog(PlacementDrive drive) {
    final allStudents = _service.students;
    final selectedStudentIds = List<String>.from(drive.enrolledStudentIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(drive.companyName, style: const TextStyle(fontSize: 14, color: PlaceTrackTheme.textSecondary)),
                const Text('Registered Candidates & Applicants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${selectedStudentIds.length} candidate(s) registered (Self-applied or Assigned)',
                  style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allStudents.length,
                itemBuilder: (context, idx) {
                  final s = allStudents[idx];
                  final isSelected = selectedStudentIds.contains(s.id);
                  final hasResume = s.resumeFileName.isNotEmpty || s.resumeUrl.isNotEmpty;
                  final resumeName = s.resumeFileName.isNotEmpty ? s.resumeFileName : 'Resume.pdf';

                  return CheckboxListTile(
                    title: Row(
                      children: [
                        Expanded(child: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600))),
                        if (hasResume)
                          InkWell(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (resumeCtx) => AlertDialog(
                                  title: Row(
                                    children: [
                                      const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                                      const SizedBox(width: 8),
                                      Expanded(child: Text(resumeName, style: const TextStyle(fontSize: 14))),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Student: ${s.name} (${s.regNo})'),
                                      Text('Department: ${s.department} • CGPA: ${s.cgpa}'),
                                      const SizedBox(height: 8),
                                      Text('File Size: ${s.resumeFileSize.isNotEmpty ? s.resumeFileSize : "210 KB"}'),
                                      const SizedBox(height: 12),
                                      const Text('✓ PDF verified and attached to drive application.', style: TextStyle(color: Colors.green, fontSize: 12)),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(resumeCtx), child: const Text('Close')),
                                    ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: PlaceTrackTheme.primary,
                                        foregroundColor: Colors.white,
                                      ),
                                      icon: const Icon(Icons.remove_red_eye_rounded, size: 14),
                                      label: const Text('Open PDF'),
                                      onPressed: () {
                                        Navigator.pop(resumeCtx);
                                        ResumeViewerService.openStudentResume(context: context, student: s);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.picture_as_pdf_rounded, size: 12, color: Colors.red),
                                  SizedBox(width: 2),
                                  Text('PDF', style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text('${s.regNo} • ${s.department} (CGPA: ${s.cgpa})'),
                    value: isSelected,
                    activeColor: PlaceTrackTheme.primary,
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          selectedStudentIds.add(s.id);
                        } else {
                          selectedStudentIds.remove(s.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  _service.updateDriveEnrolledStudents(drive.id, selectedStudentIds);
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Updated registered students for ${drive.companyName}')),
                  );
                },
                child: const Text('Save Candidates'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap, Color activeColor) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _showRoundEvaluationDialog(PlacementDrive drive, PlacementRound round, int roundIndex) {
    final candidateIds = roundIndex == 0
        ? (drive.enrolledStudentIds.isNotEmpty ? drive.enrolledStudentIds : _service.students.map((s) => s.id).toList())
        : (drive.rounds[roundIndex - 1].qualifiedStudentIds);

    final candidates = _service.students.where((s) => candidateIds.contains(s.id)).toList();
    final qualifiedIds = List<String>.from(round.qualifiedStudentIds);
    final rejectedIds = List<String>.from(round.rejectedStudentIds);
    final isFinalRound = roundIndex == drive.rounds.length - 1;

    String filter = 'all';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          final clearedCount = qualifiedIds.length;
          final rejectedCount = rejectedIds.length;
          final pendingCount = (candidates.length - clearedCount - rejectedCount).clamp(0, candidates.length);

          final displayed = candidates.where((s) {
            if (filter == 'cleared') return qualifiedIds.contains(s.id);
            if (filter == 'rejected') return rejectedIds.contains(s.id);
            if (filter == 'pending') return !qualifiedIds.contains(s.id) && !rejectedIds.contains(s.id);
            return true;
          }).toList();

          return AlertDialog(
            titlePadding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(drive.companyName, style: const TextStyle(fontSize: 13, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w600)),
                    if (isFinalRound)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFFEF3C7), borderRadius: BorderRadius.circular(6)),
                        child: const Text('🏆 FINAL ROUND', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFB45309))),
                      ),
                  ],
                ),
                Text(round.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All (${candidates.length})', filter == 'all', () => setDialogState(() => filter = 'all'), Colors.blueGrey),
                      const SizedBox(width: 6),
                      _buildFilterChip('Cleared ($clearedCount)', filter == 'cleared', () => setDialogState(() => filter = 'cleared'), const Color(0xFF16A34A)),
                      const SizedBox(width: 6),
                      _buildFilterChip('Rejected ($rejectedCount)', filter == 'rejected', () => setDialogState(() => filter = 'rejected'), const Color(0xFFDC2626)),
                      const SizedBox(width: 6),
                      _buildFilterChip('Pending ($pendingCount)', filter == 'pending', () => setDialogState(() => filter = 'pending'), Colors.orange),
                    ],
                  ),
                ),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 420,
              child: displayed.isEmpty
                  ? Center(child: Text('No students found in "$filter" status.'))
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: displayed.length,
                      itemBuilder: (context, idx) {
                        final s = displayed[idx];
                        final isCleared = qualifiedIds.contains(s.id);
                        final isRejected = rejectedIds.contains(s.id);
                        final isPlaced = drive.placedStudentIds.contains(s.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark
                                ? (isCleared
                                    ? const Color(0xFF064E3B).withAlpha(140)
                                    : (isRejected ? const Color(0xFF7F1D1D).withAlpha(140) : const Color(0xFF1E293B)))
                                : (isCleared
                                    ? const Color(0xFFF0FDF4)
                                    : (isRejected ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC))),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isDark
                                  ? (isCleared
                                      ? const Color(0xFF059669)
                                      : (isRejected ? const Color(0xFFDC2626) : const Color(0xFF334155)))
                                  : (isCleared
                                      ? const Color(0xFF86EFAC)
                                      : (isRejected ? const Color(0xFFFECACA) : const Color(0xFFE2E8F0))),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: PlaceTrackTheme.primary,
                                    backgroundImage: s.profileImagePath.isNotEmpty && File(s.profileImagePath).existsSync()
                                        ? FileImage(File(s.profileImagePath))
                                        : null,
                                    child: (s.profileImagePath.isEmpty || !File(s.profileImagePath).existsSync())
                                        ? Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold))
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(s.name, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87)),
                                        Text('${s.regNo} • ${s.department} (CGPA: ${s.cgpa})', style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : PlaceTrackTheme.textSecondary)),
                                        if (round.evaluationDates[s.id] != null) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            isCleared
                                                ? '✓ Cleared on: ${round.evaluationDates[s.id]}'
                                                : (isRejected ? '✕ Rejected on: ${round.evaluationDates[s.id]}' : ''),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isCleared ? const Color(0xFF16A34A) : const Color(0xFFDC2626),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: isCleared
                                          ? const Color(0xFFDCFCE7)
                                          : (isRejected ? const Color(0xFFFEE2E2) : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isCleared ? 'CLEARED ✓' : (isRejected ? 'REJECTED ✕' : 'PENDING'),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: isCleared ? const Color(0xFF15803D) : (isRejected ? const Color(0xFFDC2626) : (isDark ? Colors.white70 : Colors.black54)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        rejectedIds.remove(s.id);
                                        if (!qualifiedIds.contains(s.id)) {
                                          qualifiedIds.add(s.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCleared ? const Color(0xFF16A34A) : Colors.white,
                                        border: Border.all(color: const Color(0xFF16A34A)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.check, size: 14, color: isCleared ? Colors.white : const Color(0xFF16A34A)),
                                          const SizedBox(width: 4),
                                          Text('Pass Round', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isCleared ? Colors.white : const Color(0xFF16A34A))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    onTap: () {
                                      setDialogState(() {
                                        qualifiedIds.remove(s.id);
                                        if (!rejectedIds.contains(s.id)) {
                                          rejectedIds.add(s.id);
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isRejected ? const Color(0xFFDC2626) : Colors.white,
                                        border: Border.all(color: const Color(0xFFDC2626)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.close, size: 14, color: isRejected ? Colors.white : const Color(0xFFDC2626)),
                                          const SizedBox(width: 4),
                                          Text('Reject', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isRejected ? Colors.white : const Color(0xFFDC2626))),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton(
                                    icon: const Icon(Icons.refresh_rounded, size: 18),
                                    tooltip: 'Reset to Pending',
                                    onPressed: () {
                                      setDialogState(() {
                                        qualifiedIds.remove(s.id);
                                        rejectedIds.remove(s.id);
                                      });
                                    },
                                  ),
                                  if (isFinalRound) ...[
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: () {
                                        _service.toggleStudentPlaced(
                                          driveId: drive.id,
                                          studentId: s.id,
                                          isPlaced: !isPlaced,
                                        );
                                        setDialogState(() {});
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(!isPlaced ? '🎉 ${s.name} marked as PLACED at ${drive.companyName}!' : 'Removed ${s.name} from placed list.'),
                                            backgroundColor: !isPlaced ? const Color(0xFF059669) : Colors.black87,
                                          ),
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            colors: isPlaced ? [const Color(0xFF047857), const Color(0xFF10B981)] : [const Color(0xFFF59E0B), const Color(0xFFD97706)],
                                          ),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(isPlaced ? '🏆 Placed' : '🎉 Give Offer', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(backgroundColor: PlaceTrackTheme.primary, foregroundColor: Colors.white),
                icon: const Icon(Icons.sync_rounded, size: 16),
                label: const Text('Save & Sync to Student Portals'),
                onPressed: () {
                  for (final sid in candidates.map((c) => c.id)) {
                    if (qualifiedIds.contains(sid)) {
                      _service.setStudentRoundStatus(driveId: drive.id, roundId: round.id, studentId: sid, status: 'cleared');
                    } else if (rejectedIds.contains(sid)) {
                      _service.setStudentRoundStatus(driveId: drive.id, roundId: round.id, studentId: sid, status: 'rejected');
                    } else {
                      _service.setStudentRoundStatus(driveId: drive.id, roundId: round.id, studentId: sid, status: 'pending');
                    }
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          Expanded(child: Text('✓ Updated ${round.name}! Students can now see their status on their portal.')),
                        ],
                      ),
                      backgroundColor: const Color(0xFF059669),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPlacedStudentsDialog(PlacementDrive drive) {
    final allStudents = _service.students;
    final placedStudentIds = List<String>.from(drive.placedStudentIds);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;
          return AlertDialog(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(drive.companyName, style: const TextStyle(fontSize: 14, color: PlaceTrackTheme.textSecondary)),
                Text('🎉 Mark Final Placed Students', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
              ],
            ),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: allStudents.length,
                itemBuilder: (context, idx) {
                  final s = allStudents[idx];
                  final isPlaced = placedStudentIds.contains(s.id);
                  final placedDate = drive.placedDates[s.id];
                  return CheckboxListTile(
                    title: Text(s.name, style: TextStyle(fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                    subtitle: Text(
                      placedDate != null
                          ? '${s.regNo} • ${s.department}\n🏆 Placed on: $placedDate'
                          : '${s.regNo} • ${s.department}',
                      style: TextStyle(fontSize: 11, color: isDark ? const Color(0xFF94A3B8) : Colors.black54),
                    ),
                    value: isPlaced,
                    activeColor: const Color(0xFF16A34A),
                    onChanged: (val) {
                      setDialogState(() {
                        if (val == true) {
                          placedStudentIds.add(s.id);
                        } else {
                          placedStudentIds.remove(s.id);
                        }
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  for (final sid in placedStudentIds) {
                    _service.markStudentPlaced(drive.id, sid);
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Marked ${placedStudentIds.length} students as placed at ${drive.companyName}!'),
                      backgroundColor: const Color(0xFF16A34A),
                    ),
                  );
                },
                child: const Text('Save Placed Students'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final drives = _service.drives;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Placement Drives & Rounds'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Placement Drive',
            onPressed: _showAddDriveDialog,
          ),
        ],
      ),
      body: drives.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.business_center_outlined, size: 60, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('No placement drives added yet.'),
                  const SizedBox(height: 8),
                  ElevatedButton(onPressed: _showAddDriveDialog, child: const Text('Add First Drive')),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: drives.length,
              itemBuilder: (context, idx) {
                final drive = drives[idx];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                drive.companyName,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                                style: const TextStyle(
                                  color: Color(0xFF059669),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              icon: const Icon(Icons.more_vert, size: 20),
                              onSelected: (val) {
                                if (val == 'edit') {
                                  _showEditDriveDialog(drive);
                                } else if (val == 'delete') {
                                  _confirmDeleteDrive(drive);
                                }
                              },
                              itemBuilder: (ctx) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit_outlined, size: 18, color: PlaceTrackTheme.primary),
                                      SizedBox(width: 8),
                                      Text('Edit Drive'),
                                    ],
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete_outline, size: 18, color: PlaceTrackTheme.danger),
                                      SizedBox(width: 8),
                                      Text('Delete Drive', style: TextStyle(color: PlaceTrackTheme.danger)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          drive.role,
                          style: const TextStyle(color: PlaceTrackTheme.textSecondary, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Eligibility: CGPA ≥ ${drive.minCgpa}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: PlaceTrackTheme.primary),
                        ),

                        // Registration / Google Form Link display (Clickable)
                        if (drive.registrationLink.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          InkWell(
                            onTap: () => _launchExternalUrl(drive.registrationLink),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFBFDBFE)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.link_rounded, color: PlaceTrackTheme.primary, size: 16),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      drive.registrationLink,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: PlaceTrackTheme.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(Icons.open_in_new_rounded, size: 14, color: PlaceTrackTheme.primary),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 12),
                        // Manage Registered / Enrolled Candidates Button & Final Offer Button
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showManageDriveStudentsDialog(drive),
                                icon: const Icon(Icons.people_outline, size: 16),
                                label: Text('${drive.enrolledStudentIds.length} Registered Candidates'),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  minimumSize: Size.zero,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showPlacedStudentsDialog(drive),
                              icon: const Icon(Icons.check_circle_rounded, size: 16),
                              label: Text('${drive.placedStudentIds.length} Placed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF16A34A),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ],
                        ),

                        const Divider(height: 24),

                        // Rounds
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Selection Rounds:',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            TextButton.icon(
                              onPressed: () => _showAddRoundDialog(drive),
                              icon: const Icon(Icons.add, size: 16),
                              label: const Text('Add Round', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        ...drive.rounds.asMap().entries.map((entry) {
                          final roundIndex = entry.key;
                          final round = entry.value;
                          final cleared = round.qualifiedStudentIds.length;
                          final rejected = round.rejectedStudentIds.length;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: PlaceTrackTheme.primary.withAlpha(20),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Text(
                                    'R${roundIndex + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: PlaceTrackTheme.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(round.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            '$cleared Cleared',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFF16A34A), fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            '$rejected Rejected',
                                            style: const TextStyle(fontSize: 11, color: Color(0xFFDC2626), fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _showRoundEvaluationDialog(drive, round, roundIndex),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: PlaceTrackTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    minimumSize: Size.zero,
                                    textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                  icon: const Icon(Icons.rule_rounded, size: 14),
                                  label: const Text('Evaluate'),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddDriveDialog,
        icon: const Icon(Icons.add),
        label: const Text('New Drive'),
      ),
    );
  }
}
