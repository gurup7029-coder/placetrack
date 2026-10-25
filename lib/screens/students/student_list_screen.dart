import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../../services/resume_viewer_service.dart';
import '../../services/student_export_service.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final _service = PlacementDataService();
  String _searchQuery = '';
  String _selectedDept = 'All Courses';
  String _selectedYear = 'All Years';
  String _selectedSection = 'All Sections';
  String _selectedCompany = 'All Companies';
  String _selectedRoundFilter = 'All Rounds';

  final List<String> _roundFilterOptions = [
    'All Rounds',
    'Round 1 Cleared',
    'Round 2 Cleared',
    'Final Round Selected / Placed',
    'Round 1 Rejected',
    'Round 2 Rejected',
  ];

  final List<String> _departments = [
    'All Courses',
    'MCA',
    'B.Sc Computer Science',
    'B.Sc Information Tech',
    'BCA',
    'B.Com CA',
    'BBA',
    'B.E. Computer Science',
    'B.E. Electronics & Comm.',
  ];

  final List<String> _years = [
    'All Years',
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
  ];

  final List<String> _sections = [
    'All Sections',
    'Section A',
    'Section B',
    'Section C',
  ];

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

  void _showStudentDetailsModal(StudentModel student) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final hasResume = student.resumeFileName.isNotEmpty || student.resumeUrl.trim().isNotEmpty;
        final resumeDisplayTitle = student.resumeFileName.isNotEmpty
            ? student.resumeFileName
            : (student.resumeUrl.isNotEmpty ? student.resumeUrl : 'Resume.pdf');
        final resumeSize = student.resumeFileSize.isNotEmpty ? student.resumeFileSize : '210 KB';

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: PlaceTrackTheme.primary,
                    backgroundImage: student.profileImagePath.isNotEmpty && File(student.profileImagePath).existsSync()
                        ? FileImage(File(student.profileImagePath))
                        : null,
                    child: (student.profileImagePath.isEmpty || !File(student.profileImagePath).existsSync())
                        ? Text(
                            student.name.isNotEmpty ? student.name[0] : 'S',
                            style: const TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          student.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reg No: ${student.regNo}',
                          style: const TextStyle(fontSize: 13, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${student.department} • ${student.year} • ${student.section}',
                          style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),

              // Academic Metrics
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('CGPA Score', style: TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            '${student.cgpa} / 10.0',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PlaceTrackTheme.primary),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: student.backlogs == 0 ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('History of Arrears', style: TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary)),
                          const SizedBox(height: 4),
                          Text(
                            student.backlogs == 0 ? '0 Backlogs (Clean)' : '${student.backlogs} Backlog(s)',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: student.backlogs == 0 ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Contact Details
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.email_outlined, color: PlaceTrackTheme.primary, size: 18),
                ),
                title: const Text('Email Address', style: TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary)),
                subtitle: Text(student.email, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const CircleAvatar(
                  radius: 18,
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.phone_outlined, color: PlaceTrackTheme.primary, size: 18),
                ),
                title: const Text('Mobile Phone', style: TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary)),
                subtitle: Text(student.phone, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              ),

              const SizedBox(height: 12),

              // Resume PDF Section for Admin
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: hasResume ? const Color(0xFFF0FDF4) : const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: hasResume ? const Color(0xFFBBF7D0) : const Color(0xFFFDE68A),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasResume ? Icons.picture_as_pdf_rounded : Icons.warning_amber_rounded,
                          color: hasResume ? Colors.red[700] : Colors.orange[800],
                          size: 24,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hasResume ? resumeDisplayTitle : 'No Resume Uploaded',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: hasResume ? Colors.black87 : Colors.orange[900],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (hasResume)
                                Text(
                                  'Size: $resumeSize • Verified PDF',
                                  style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (hasResume) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: PlaceTrackTheme.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              textStyle: const TextStyle(fontSize: 12),
                            ),
                            icon: const Icon(Icons.remove_red_eye_rounded, size: 15),
                            label: const Text('View Resume PDF'),
                            onPressed: () {
                              ResumeViewerService.openStudentResume(context: context, student: student);
                            },
                          ),
                          const SizedBox(width: 8),
                          if (student.resumeUrl.isNotEmpty)
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              icon: const Icon(Icons.copy_rounded, size: 14),
                              label: const Text('Copy Link'),
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: student.resumeUrl));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Link copied to clipboard!')),
                                );
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: PlaceTrackTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.edit_note_rounded, size: 18),
                      label: const Text('Edit Details'),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showEditStudentDialog(student);
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      side: BorderSide(color: Colors.red.shade200),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 18),
                    label: const Text('Delete'),
                    onPressed: () {
                      _service.deleteStudent(student.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${student.name} deleted.')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditStudentDialog(StudentModel student) {
    final nameController = TextEditingController(text: student.name);
    final regNoController = TextEditingController(text: student.regNo);
    final emailController = TextEditingController(text: student.email);
    final phoneController = TextEditingController(text: student.phone);
    final cgpaController = TextEditingController(text: student.cgpa.toString());
    final backlogsController = TextEditingController(text: student.backlogs.toString());

    String selectedDept = student.department;
    String selectedYear = student.year;
    String selectedSection = student.section;

    final departments = [
      'MCA',
      'B.Sc Computer Science',
      'BCA',
      'B.Sc Information Tech',
      'B.Tech IT',
      'B.E Computer Science',
    ];
    if (!departments.contains(selectedDept)) departments.add(selectedDept);

    final years = ['1st Year', '2nd Year', '3rd Year', '4th Year'];
    if (!years.contains(selectedYear)) years.add(selectedYear);

    final sections = ['Section A', 'Section B', 'Section C'];
    if (!sections.contains(selectedSection)) sections.add(selectedSection);

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
                const Row(
                  children: [
                    Icon(Icons.manage_accounts_rounded, color: PlaceTrackTheme.primary),
                    SizedBox(width: 8),
                    Text(
                      'Admin - Edit Student Record',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Student Name *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: regNoController,
                        decoration: const InputDecoration(
                          labelText: 'Reg No *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedDept,
                  decoration: const InputDecoration(
                    labelText: 'Course / Department *',
                    border: OutlineInputBorder(),
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
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: backlogsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Backlogs *',
                          hintText: 'e.g. 0',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email Address *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Phone *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: PlaceTrackTheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Update & Save Changes'),
                    onPressed: () {
                      final name = nameController.text.trim();
                      final regNo = regNoController.text.trim();
                      if (name.isEmpty || regNo.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name and Reg No cannot be empty.')),
                        );
                        return;
                      }

                      final cgpa = double.tryParse(cgpaController.text.trim()) ?? student.cgpa;
                      final backlogs = int.tryParse(backlogsController.text.trim()) ?? student.backlogs;

                      final updated = student.copyWith(
                        name: name,
                        regNo: regNo,
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Student "${updated.name}" record updated!'),
                          backgroundColor: const Color(0xFF059669),
                        ),
                      );
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

  Future<void> _pickAndImportCsv() async {
    final textController = TextEditingController(
      text: '''Name, RegNo, Course, Year, Section, CGPA, Backlogs
Deepak Kumar, 710022104018, MCA, 2nd Year, Section A, 8.80, 0
Meena Kumari, 710022104052, B.Sc Computer Science, 3rd Year, Section B, 8.15, 0
Rahul Sharma, 710022106022, BCA, 2nd Year, Section A, 7.60, 1
Swetha Priya, 710022104095, B.Sc Information Tech, 3rd Year, Section A, 9.20, 0''',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.upload_file_rounded, color: PlaceTrackTheme.primary),
            SizedBox(width: 8),
            Text('Bulk CSV Student Import', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Paste CSV text below (Name, RegNo, Course, Year, Section, CGPA, Backlogs):',
                style: TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: textController,
                maxLines: 6,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final rawText = textController.text.trim();
              if (rawText.isEmpty) return;

              final lines = rawText.split('\n');
              final importedList = <StudentModel>[];

              int startIdx = 0;
              if (lines.isNotEmpty && lines[0].toLowerCase().contains('name')) {
                startIdx = 1;
              }

              for (int i = startIdx; i < lines.length; i++) {
                final line = lines[i].trim();
                if (line.isEmpty) continue;
                final cols = line.split(',').map((c) => c.trim()).toList();

                if (cols.length >= 4) {
                  final name = cols[0];
                  final regNo = cols[1];
                  final course = cols[2];
                  final year = cols.length > 3 ? cols[3] : '3rd Year';
                  final sec = cols.length > 4 ? cols[4] : 'Section A';
                  final cgpa = cols.length > 5 ? (double.tryParse(cols[5]) ?? 7.5) : 7.5;
                  final backlogs = cols.length > 6 ? (int.tryParse(cols[6]) ?? 0) : 0;

                  importedList.add(
                    StudentModel(
                      id: 's_${DateTime.now().millisecondsSinceEpoch}_$i',
                      name: name,
                      regNo: regNo,
                      department: course,
                      year: year,
                      section: sec,
                      cgpa: cgpa,
                      backlogs: backlogs,
                      email: '$regNo@student.college.edu',
                      phone: '+91 98765 00000',
                      resumeUrl: 'https://drive.google.com/file/d/demo_$regNo/view',
                      resumeFileName: '${name.replaceAll(' ', '_')}_Resume.pdf',
                      resumeFileSize: '215 KB',
                    ),
                  );
                }
              }

              if (importedList.isNotEmpty) {
                _service.importStudents(importedList);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Successfully imported ${importedList.length} students from CSV!'),
                    backgroundColor: PlaceTrackTheme.accent,
                  ),
                );
              }
            },
            child: const Text('Import Students'),
          ),
        ],
      ),
    );
  }

  void _showAddStudentDialog() {
    final nameCtrl = TextEditingController();
    final regNoCtrl = TextEditingController();
    final cgpaCtrl = TextEditingController(text: '8.0');
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final resumeCtrl = TextEditingController();
    String dept = 'MCA';
    String year = '2nd Year';
    String section = 'Section A';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
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
                        'Add Student Record',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(labelText: 'Student Full Name', prefixIcon: Icon(Icons.person)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: regNoCtrl,
                    decoration: const InputDecoration(labelText: 'Register Number', prefixIcon: Icon(Icons.badge)),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: dept,
                    decoration: const InputDecoration(labelText: 'Course / Degree', prefixIcon: Icon(Icons.school)),
                    items: _departments.where((d) => d != 'All Courses').map((d) {
                      return DropdownMenuItem(value: d, child: Text(d));
                    }).toList(),
                    onChanged: (val) => setModalState(() => dept = val ?? dept),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: year,
                          decoration: const InputDecoration(labelText: 'Year', prefixIcon: Icon(Icons.calendar_month)),
                          items: _years.where((y) => y != 'All Years').map((y) {
                            return DropdownMenuItem(value: y, child: Text(y));
                          }).toList(),
                          onChanged: (val) => setModalState(() => year = val ?? year),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: section,
                          decoration: const InputDecoration(labelText: 'Section', prefixIcon: Icon(Icons.groups)),
                          items: _sections.where((s) => s != 'All Sections').map((s) {
                            return DropdownMenuItem(value: s, child: Text(s));
                          }).toList(),
                          onChanged: (val) => setModalState(() => section = val ?? section),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cgpaCtrl,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'CGPA', prefixIcon: Icon(Icons.grade)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: phoneCtrl,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(labelText: 'Mobile Phone', prefixIcon: Icon(Icons.phone)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: resumeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Resume PDF Name / Link',
                      hintText: 'Student_Resume.pdf',
                      prefixIcon: Icon(Icons.picture_as_pdf_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final regNo = regNoCtrl.text.trim();
                        final cgpa = double.tryParse(cgpaCtrl.text.trim()) ?? 7.0;

                        if (name.isEmpty || regNo.isEmpty) return;

                        final resumeText = resumeCtrl.text.trim();
                        final newStudent = StudentModel(
                          id: 's_${DateTime.now().millisecondsSinceEpoch}',
                          name: name,
                          regNo: regNo,
                          department: dept,
                          year: year,
                          section: section,
                          cgpa: cgpa,
                          email: emailCtrl.text.trim().isEmpty ? '$regNo@student.college.edu' : emailCtrl.text.trim(),
                          phone: phoneCtrl.text.trim().isEmpty ? '+91 90000 00000' : phoneCtrl.text.trim(),
                          resumeUrl: resumeText,
                          resumeFileName: resumeText.isNotEmpty ? resumeText : '${name.replaceAll(' ', '_')}_Resume.pdf',
                          resumeFileSize: '200 KB',
                        );

                        _service.addStudent(newStudent);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Added $name successfully!')),
                        );
                      },
                      child: const Text('Save Student Record'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showExportDialog(List<StudentModel> students) {
    if (students.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No students match the current filters to export.')),
      );
      return;
    }

    String selectedFormat = 'pdf'; // 'pdf' or 'csv'
    final selectedCols = List<String>.from(StudentExportService.availableColumns);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          final isAllSelected = selectedCols.length == StudentExportService.availableColumns.length;

          return Padding(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Export Filtered Students',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${students.length} Records',
                          style: const TextStyle(color: PlaceTrackTheme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Format Selector
                  const Text('Select Export File Format:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedFormat = 'pdf'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedFormat == 'pdf' ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedFormat == 'pdf' ? const Color(0xFFDC2626) : const Color(0xFFE2E8F0),
                                width: selectedFormat == 'pdf' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFDC2626), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'PDF Document',
                                  style: TextStyle(
                                    fontWeight: selectedFormat == 'pdf' ? FontWeight.bold : FontWeight.w500,
                                    color: selectedFormat == 'pdf' ? const Color(0xFFDC2626) : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => setModalState(() => selectedFormat = 'csv'),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                            decoration: BoxDecoration(
                              color: selectedFormat == 'csv' ? const Color(0xFFECFDF5) : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: selectedFormat == 'csv' ? const Color(0xFF059669) : const Color(0xFFE2E8F0),
                                width: selectedFormat == 'csv' ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.table_view_rounded, color: Color(0xFF059669), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Excel / CSV',
                                  style: TextStyle(
                                    fontWeight: selectedFormat == 'csv' ? FontWeight.bold : FontWeight.w500,
                                    color: selectedFormat == 'csv' ? const Color(0xFF059669) : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Column Multi-Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Columns to Include:',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            if (isAllSelected) {
                              selectedCols.clear();
                              selectedCols.add('Student Name');
                            } else {
                              selectedCols.clear();
                              selectedCols.addAll(StudentExportService.availableColumns);
                            }
                          });
                        },
                        child: Text(isAllSelected ? 'Deselect All' : 'Select All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: StudentExportService.availableColumns.map((col) {
                      final isSelected = selectedCols.contains(col);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(col, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.black87)),
                        selectedColor: PlaceTrackTheme.primary,
                        checkmarkColor: Colors.white,
                        onSelected: (val) {
                          setModalState(() {
                            if (val) {
                              selectedCols.add(col);
                            } else {
                              if (selectedCols.length > 1) {
                                selectedCols.remove(col);
                              }
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Export Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: selectedFormat == 'pdf' ? const Color(0xFFDC2626) : const Color(0xFF059669),
                        foregroundColor: Colors.white,
                      ),
                      icon: Icon(selectedFormat == 'pdf' ? Icons.picture_as_pdf_rounded : Icons.file_download_rounded),
                      label: Text('Download & Open ${selectedFormat.toUpperCase()} (${selectedCols.length} Columns)'),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        PlacementDrive? currentDrive;
                        if (_selectedCompany != 'All Companies') {
                          currentDrive = _service.drives.where((d) => d.companyName == _selectedCompany).firstOrNull;
                        }
                        final filterSubtitle = _selectedCompany != 'All Companies'
                            ? '$_selectedCompany • $_selectedRoundFilter'
                            : 'All Companies • Batch 2025-26';

                        if (selectedFormat == 'pdf') {
                          await StudentExportService.exportStudentsPdf(
                            context: context,
                            students: students,
                            selectedColumns: selectedCols,
                            targetDriveId: currentDrive?.id,
                            filterSubtitle: filterSubtitle,
                          );
                        } else {
                          await StudentExportService.exportStudentsCsv(
                            context: context,
                            students: students,
                            selectedColumns: selectedCols,
                            targetDriveId: currentDrive?.id,
                            filterSubtitle: filterSubtitle,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allStudents = _service.students;
    final drives = _service.drives;

    PlacementDrive? filterDrive;
    if (_selectedCompany != 'All Companies') {
      filterDrive = drives.where((d) => d.companyName == _selectedCompany).firstOrNull;
    }

    final filteredStudents = allStudents.where((s) {
      final matchesQuery = s.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          s.regNo.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesDept = _selectedDept == 'All Courses' || s.department == _selectedDept;
      final matchesYear = _selectedYear == 'All Years' || s.year == _selectedYear;
      final matchesSection = _selectedSection == 'All Sections' || s.section == _selectedSection;

      bool matchesDrive = true;
      if (filterDrive != null) {
        final inDrive = filterDrive.enrolledStudentIds.contains(s.id) ||
            filterDrive.placedStudentIds.contains(s.id) ||
            filterDrive.rounds.any((r) => r.qualifiedStudentIds.contains(s.id) || r.rejectedStudentIds.contains(s.id));

        if (!inDrive) {
          matchesDrive = false;
        } else {
          switch (_selectedRoundFilter) {
            case 'Round 1 Cleared':
              matchesDrive = filterDrive.rounds.isNotEmpty && filterDrive.rounds[0].qualifiedStudentIds.contains(s.id);
              break;
            case 'Round 2 Cleared':
              matchesDrive = filterDrive.rounds.length > 1 && filterDrive.rounds[1].qualifiedStudentIds.contains(s.id);
              break;
            case 'Final Round Selected / Placed':
              matchesDrive = filterDrive.placedStudentIds.contains(s.id);
              break;
            case 'Round 1 Rejected':
              matchesDrive = filterDrive.rounds.isNotEmpty && filterDrive.rounds[0].rejectedStudentIds.contains(s.id);
              break;
            case 'Round 2 Rejected':
              matchesDrive = filterDrive.rounds.length > 1 && filterDrive.rounds[1].rejectedStudentIds.contains(s.id);
              break;
            default:
              matchesDrive = true;
          }
        }
      }

      return matchesQuery && matchesDept && matchesYear && matchesSection && matchesDrive;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download_rounded),
            tooltip: 'Export Filtered Data (PDF / Excel)',
            onPressed: () => _showExportDialog(filteredStudents),
          ),
          IconButton(
            icon: const Icon(Icons.upload_file_rounded),
            tooltip: 'Import CSV',
            onPressed: _pickAndImportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.person_add_rounded),
            tooltip: 'Add Student',
            onPressed: _showAddStudentDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.all(14),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'Search by Name or Register Number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
                const SizedBox(height: 10),

                // Course Horizontal Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _departments.map((d) {
                      final isSelected = _selectedDept == d;
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: ChoiceChip(
                          label: Text(d),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _selectedDept = d),
                          selectedColor: PlaceTrackTheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : PlaceTrackTheme.textPrimary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 11,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                // Year & Section Dropdown Selectors
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedYear,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textPrimary, fontWeight: FontWeight.w600),
                            items: _years.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                            onChanged: (val) => setState(() => _selectedYear = val ?? _selectedYear),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedSection,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textPrimary, fontWeight: FontWeight.w600),
                            items: _sections.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => _selectedSection = val ?? _selectedSection),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Company Drive & Round Filter Row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBBF7D0)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCompany,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: Color(0xFF15803D), fontWeight: FontWeight.bold),
                            items: ['All Companies', ...drives.map((d) => d.companyName)]
                                .map((c) => DropdownMenuItem(value: c, child: Text(c, maxLines: 1, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() {
                              _selectedCompany = val ?? _selectedCompany;
                              if (_selectedCompany == 'All Companies') {
                                _selectedRoundFilter = 'All Rounds';
                              }
                            }),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedRoundFilter,
                            isExpanded: true,
                            style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.primary, fontWeight: FontWeight.bold),
                            items: _roundFilterOptions
                                .map((r) => DropdownMenuItem(value: r, child: Text(r, maxLines: 1, overflow: TextOverflow.ellipsis)))
                                .toList(),
                            onChanged: (val) => setState(() => _selectedRoundFilter = val ?? _selectedRoundFilter),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Live Company Round Statistics Banner
                if (filterDrive != null) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${filterDrive.companyName}:',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            Text(
                              '${filterDrive.enrolledStudentIds.length} Total',
                              style: const TextStyle(color: Colors.white70, fontSize: 10),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'R1: ${filterDrive.rounds.isNotEmpty ? filterDrive.rounds[0].qualifiedStudentIds.length : 0} ✓',
                              style: const TextStyle(color: Color(0xFF4ADE80), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'R2: ${filterDrive.rounds.length > 1 ? filterDrive.rounds[1].qualifiedStudentIds.length : 0} ✓',
                              style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Placed: ${filterDrive.placedStudentIds.length} 🏆',
                              style: const TextStyle(color: Color(0xFFFDE68A), fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),

          // Total Count Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Showing ${filteredStudents.length} of ${allStudents.length} Students',
                  style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary, fontWeight: FontWeight.w600),
                ),
                TextButton.icon(
                  onPressed: _pickAndImportCsv,
                  icon: const Icon(Icons.file_upload_outlined, size: 14),
                  label: const Text('Bulk CSV', style: TextStyle(fontSize: 11)),
                ),
              ],
            ),
          ),

          // Students List
          Expanded(
            child: filteredStudents.isEmpty
                ? const Center(
                    child: Text('No students found matching your filters.'),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredStudents.length,
                    itemBuilder: (context, idx) {
                      final s = filteredStudents[idx];
                      final hasResume = s.resumeFileName.isNotEmpty || s.resumeUrl.trim().isNotEmpty;
                      return InkWell(
                        onTap: () => _showStudentDetailsModal(s),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: PlaceTrackTheme.primary.withAlpha(20),
                                foregroundColor: PlaceTrackTheme.primary,
                                backgroundImage: s.profileImagePath.isNotEmpty && File(s.profileImagePath).existsSync()
                                    ? FileImage(File(s.profileImagePath))
                                    : null,
                                child: (s.profileImagePath.isEmpty || !File(s.profileImagePath).existsSync())
                                    ? Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(s.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                                        ),
                                        if (hasResume)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF2F2),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.picture_as_pdf_rounded, size: 11, color: Color(0xFFDC2626)),
                                                SizedBox(width: 2),
                                                Text('PDF', style: TextStyle(fontSize: 10, color: Color(0xFFDC2626), fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.regNo} • ${s.department}',
                                      style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${s.year} • ${s.section}',
                                      style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w500),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'CGPA: ${s.cgpa}',
                                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: PlaceTrackTheme.primary),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          s.backlogs == 0 ? '✓ 0 Arrears' : '⚠️ ${s.backlogs} Backlog',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: s.backlogs == 0 ? Colors.green[700] : Colors.red[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                    // Dynamic Drive & Round Status Tag
                                    Builder(
                                      builder: (context) {
                                        if (filterDrive != null) {
                                          final isPlaced = filterDrive.placedStudentIds.contains(s.id);
                                          final r2Cleared = filterDrive.rounds.length > 1 && filterDrive.rounds[1].qualifiedStudentIds.contains(s.id);
                                          final r2Rejected = filterDrive.rounds.length > 1 && filterDrive.rounds[1].rejectedStudentIds.contains(s.id);
                                          final r1Cleared = filterDrive.rounds.isNotEmpty && filterDrive.rounds[0].qualifiedStudentIds.contains(s.id);
                                          final r1Rejected = filterDrive.rounds.isNotEmpty && filterDrive.rounds[0].rejectedStudentIds.contains(s.id);

                                          String statusLabel = 'In Drive';
                                          Color tagBg = const Color(0xFFF1F5F9);
                                          Color tagFg = Colors.black87;

                                          if (isPlaced) {
                                            statusLabel = 'Placed 🎉 (${filterDrive.packageLpa})';
                                            tagBg = const Color(0xFFDCFCE7);
                                            tagFg = const Color(0xFF15803D);
                                          } else if (r2Cleared) {
                                            statusLabel = 'Round 2 Cleared ✓';
                                            tagBg = const Color(0xFFDCFCE7);
                                            tagFg = const Color(0xFF15803D);
                                          } else if (r2Rejected) {
                                            statusLabel = 'Rejected R2 ✕';
                                            tagBg = const Color(0xFFFEE2E2);
                                            tagFg = const Color(0xFFDC2626);
                                          } else if (r1Cleared) {
                                            statusLabel = 'Round 1 Cleared ✓';
                                            tagBg = const Color(0xFFEFF6FF);
                                            tagFg = PlaceTrackTheme.primary;
                                          } else if (r1Rejected) {
                                            statusLabel = 'Rejected R1 ✕';
                                            tagBg = const Color(0xFFFEE2E2);
                                            tagFg = const Color(0xFFDC2626);
                                          }

                                          return Padding(
                                            padding: const EdgeInsets.only(top: 4),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: tagBg,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                statusLabel,
                                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: tagFg),
                                              ),
                                            ),
                                          );
                                        } else {
                                          final placedDrive = drives.where((d) => d.placedStudentIds.contains(s.id)).firstOrNull;
                                          if (placedDrive != null) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDCFCE7),
                                                  borderRadius: BorderRadius.circular(4),
                                                ),
                                                child: Text(
                                                  'Placed: ${placedDrive.companyName} (${placedDrive.packageLpa})',
                                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                                                ),
                                              ),
                                            );
                                          }
                                          return const SizedBox.shrink();
                                        }
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddStudentDialog,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Student'),
      ),
    );
  }
}
