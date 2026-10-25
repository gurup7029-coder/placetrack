import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import '../../app/theme.dart';
import '../../models/gri_resume_model.dart';
import '../../models/placement_models.dart';
import '../../services/gri_resume_export_service.dart';
import '../../services/placement_data_service.dart';
import '../../services/voice_input_service.dart';
import 'package:printing/printing.dart';

class GriResumeBuilderScreen extends StatefulWidget {
  final StudentModel student;

  const GriResumeBuilderScreen({
    super.key,
    required this.student,
  });

  @override
  State<GriResumeBuilderScreen> createState() => _GriResumeBuilderScreenState();
}

class _GriResumeBuilderScreenState extends State<GriResumeBuilderScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late GriResumeData _resumeData;
  final _service = PlacementDataService();

  // Controllers for editable fields
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _careerSummaryController;
  late TextEditingController _technicalSkillsController;
  late TextEditingController _softSkillsController;
  late TextEditingController _certificationsController;
  late TextEditingController _achievementsController;
  late TextEditingController _knowledgeEventsController;
  late TextEditingController _extracurricularController;
  late TextEditingController _languagesKnownController;

  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (_tabController.index == 1) {
        _syncControllersToModel();
        if (mounted) setState(() {});
      }
    });

    // Initialize with student information and GRI template defaults
    _resumeData = GriResumeData.createDefault(
      name: widget.student.name,
      email: widget.student.email,
      phone: widget.student.phone,
      department: widget.student.department,
      year: widget.student.year,
      cgpa: widget.student.cgpa,
    );

    _nameController = TextEditingController(text: _resumeData.fullName);
    _emailController = TextEditingController(text: _resumeData.email);
    _phoneController = TextEditingController(text: _resumeData.phone);
    _addressController = TextEditingController(text: _resumeData.address);
    _careerSummaryController =
        TextEditingController(text: _resumeData.careerSummary);
    _technicalSkillsController =
        TextEditingController(text: _resumeData.technicalSkills);
    _softSkillsController = TextEditingController(text: _resumeData.softSkills);
    _certificationsController =
        TextEditingController(text: _resumeData.certifications);
    _achievementsController =
        TextEditingController(text: _resumeData.achievements);
    _knowledgeEventsController =
        TextEditingController(text: _resumeData.knowledgeEvents);
    _extracurricularController =
        TextEditingController(text: _resumeData.extracurricular);
    _languagesKnownController =
        TextEditingController(text: _resumeData.languagesKnown);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _careerSummaryController.dispose();
    _technicalSkillsController.dispose();
    _softSkillsController.dispose();
    _certificationsController.dispose();
    _achievementsController.dispose();
    _knowledgeEventsController.dispose();
    _extracurricularController.dispose();
    _languagesKnownController.dispose();
    super.dispose();
  }

  void _syncControllersToModel() {
    _resumeData.fullName = _nameController.text.trim();
    _resumeData.email = _emailController.text.trim();
    _resumeData.phone = _phoneController.text.trim();
    _resumeData.address = _addressController.text.trim();
    _resumeData.careerSummary = _careerSummaryController.text.trim();
    _resumeData.technicalSkills = _technicalSkillsController.text.trim();
    _resumeData.softSkills = _softSkillsController.text.trim();
    _resumeData.certifications = _certificationsController.text.trim();
    _resumeData.achievements = _achievementsController.text.trim();
    _resumeData.knowledgeEvents = _knowledgeEventsController.text.trim();
    _resumeData.extracurricular = _extracurricularController.text.trim();
    _resumeData.languagesKnown = _languagesKnownController.text.trim();
  }

  Future<void> _exportDocx() async {
    _syncControllersToModel();
    setState(() => _isExporting = true);
    try {
      final path = await GriResumeExportService.generateDocx(_resumeData);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.description_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Word Document (.docx) saved: ${path.split(RegExp(r"[/\\]")).last}'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2563EB),
            action: SnackBarAction(
              label: 'Open',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(path),
            ),
          ),
        );
        await OpenFilex.open(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate Word document: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _exportPdf() async {
    _syncControllersToModel();
    setState(() => _isExporting = true);
    try {
      final path = await GriResumeExportService.generatePdf(_resumeData);

      // Automatically sync as active student resume
      final fileName = 'GRI_Resume_${widget.student.name.replaceAll(" ", "_")}.pdf';
      _service.updateStudentPdfResume(
        studentId: widget.student.id,
        fileName: fileName,
        filePath: path,
        fileSize: '185 KB',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.picture_as_pdf_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('PDF Resume created & attached to your Profile!'),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF059669),
            action: SnackBarAction(
              label: 'Open PDF',
              textColor: Colors.white,
              onPressed: () => OpenFilex.open(path),
            ),
          ),
        );
        await OpenFilex.open(path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate PDF resume: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  Future<void> _pickPhoto() async {
    try {
      final res = await FilePicker.pickFiles(type: FileType.image);
      if (res.isNotEmpty && res.first.path != null) {
        setState(() {
          _resumeData.photoPath = res.first.path;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Passport photo attached to resume!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error selecting photo: $e')),
        );
      }
    }
  }

  void _removePhoto() {
    setState(() {
      _resumeData.photoPath = null;
    });
  }

  void _showAddEducationDialog([GriEducationRow? existing, int? index]) {
    final degreeCtrl = TextEditingController(text: existing?.degree ?? '');
    final instCtrl = TextEditingController(text: existing?.institution ?? '');
    final boardCtrl =
        TextEditingController(text: existing?.boardOrUniversity ?? '');
    final yearCtrl = TextEditingController(text: existing?.yearOfPassing ?? '');
    final percCtrl =
        TextEditingController(text: existing?.percentageOrCgpa ?? '');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.school_rounded, color: PlaceTrackTheme.primary),
            const SizedBox(width: 8),
            Text(existing == null ? 'Add Qualification' : 'Edit Qualification'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVoiceTextField(
                label: 'Course / Degree',
                controller: degreeCtrl,
                hint: 'e.g. B.Tech Computer Science / HSC',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'School / College / Institution',
                controller: instCtrl,
                hint: 'e.g. Gandhigram Rural Institute',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Board / University',
                controller: boardCtrl,
                hint: 'e.g. GRI Deemed University / State Board',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Year of Passing',
                controller: yearCtrl,
                hint: 'e.g. 2024 - 2027 (Pursuing)',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Percentage / CGPA',
                controller: percCtrl,
                hint: 'e.g. 8.6 CGPA / 89.2%',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (degreeCtrl.text.trim().isEmpty) return;
              setState(() {
                final newRow = GriEducationRow(
                  degree: degreeCtrl.text.trim(),
                  institution: instCtrl.text.trim(),
                  boardOrUniversity: boardCtrl.text.trim(),
                  yearOfPassing: yearCtrl.text.trim(),
                  percentageOrCgpa: percCtrl.text.trim(),
                );
                if (index != null) {
                  _resumeData.educationList[index] = newRow;
                } else {
                  _resumeData.educationList.add(newRow);
                }
              });
              Navigator.pop(dlgCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddProjectDialog([GriProjectItem? existing, int? index]) {
    final titleCtrl = TextEditingController(text: existing?.title ?? '');
    final stackCtrl = TextEditingController(text: existing?.techStack ?? '');
    final durCtrl = TextEditingController(text: existing?.duration ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.code_rounded, color: PlaceTrackTheme.primary),
            const SizedBox(width: 8),
            Text(existing == null ? 'Add Project' : 'Edit Project'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVoiceTextField(
                label: 'Project Title',
                controller: titleCtrl,
                hint: 'e.g. PlaceTrack App',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Technologies Used',
                controller: stackCtrl,
                hint: 'e.g. Flutter, Firebase, Dart',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Duration',
                controller: durCtrl,
                hint: 'e.g. 3 Months',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Project Description',
                controller: descCtrl,
                maxLines: 3,
                hint: 'Brief explanation of features & your contribution',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (titleCtrl.text.trim().isEmpty) return;
              setState(() {
                final item = GriProjectItem(
                  title: titleCtrl.text.trim(),
                  techStack: stackCtrl.text.trim(),
                  duration: durCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                if (index != null) {
                  _resumeData.projects[index] = item;
                } else {
                  _resumeData.projects.add(item);
                }
              });
              Navigator.pop(dlgCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddExperienceDialog([GriExperienceItem? existing, int? index]) {
    final compCtrl = TextEditingController(text: existing?.companyName ?? '');
    final roleCtrl = TextEditingController(text: existing?.role ?? '');
    final durCtrl = TextEditingController(text: existing?.duration ?? '');
    final descCtrl = TextEditingController(text: existing?.description ?? '');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.work_rounded, color: PlaceTrackTheme.primary),
            const SizedBox(width: 8),
            Text(existing == null ? 'Add Work / Intern' : 'Edit Work / Intern'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVoiceTextField(
                label: 'Company / Organization',
                controller: compCtrl,
                hint: 'e.g. Tech Solutions Pvt Ltd',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Role / Designation',
                controller: roleCtrl,
                hint: 'e.g. Flutter Developer Intern',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Duration',
                controller: durCtrl,
                hint: 'e.g. Aug 2025 - Nov 2025',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Key Responsibilities',
                controller: descCtrl,
                maxLines: 3,
                hint: 'Describe tasks, achievements & tools handled',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (compCtrl.text.trim().isEmpty) return;
              setState(() {
                final item = GriExperienceItem(
                  companyName: compCtrl.text.trim(),
                  role: roleCtrl.text.trim(),
                  duration: durCtrl.text.trim(),
                  description: descCtrl.text.trim(),
                );
                if (index != null) {
                  _resumeData.experiences[index] = item;
                } else {
                  _resumeData.experiences.add(item);
                }
              });
              Navigator.pop(dlgCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showAddReferenceDialog([GriReferenceItem? existing, int? index]) {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final desigCtrl = TextEditingController(text: existing?.designation ?? '');
    final instCtrl = TextEditingController(text: existing?.institution ?? 'The Gandhigram Rural Institute (GRI)');
    final mobCtrl = TextEditingController(text: existing?.mobile ?? '');
    final mailCtrl = TextEditingController(text: existing?.email ?? '');

    showDialog(
      context: context,
      builder: (dlgCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.person_pin_rounded, color: PlaceTrackTheme.primary),
            SizedBox(width: 8),
            Text('Reference Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildVoiceTextField(
                label: 'Name',
                controller: nameCtrl,
                hint: 'e.g. Dr. G. Kingsly',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Designation',
                controller: desigCtrl,
                hint: 'e.g. Placement Officer',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Institution',
                controller: instCtrl,
                hint: 'The Gandhigram Rural Institute (GRI)',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Mobile Number',
                controller: mobCtrl,
                hint: 'e.g. 9842004204',
              ),
              const SizedBox(height: 10),
              _buildVoiceTextField(
                label: 'Email',
                controller: mailCtrl,
                hint: 'e.g. griplacement@ruraluniv.ac.in',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dlgCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: PlaceTrackTheme.primary,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty) return;
              setState(() {
                final ref = GriReferenceItem(
                  name: nameCtrl.text.trim(),
                  designation: desigCtrl.text.trim(),
                  institution: instCtrl.text.trim(),
                  mobile: mobCtrl.text.trim(),
                  email: mailCtrl.text.trim(),
                );
                if (index != null) {
                  _resumeData.references[index] = ref;
                } else {
                  _resumeData.references.add(ref);
                }
              });
              Navigator.pop(dlgCtx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
            VoiceMicButton(
              fieldLabel: label,
              controller: controller,
            ),
          ],
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: PlaceTrackTheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PlaceTrackTheme.primary.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: PlaceTrackTheme.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              ?trailing,
            ],
          ),
          const Divider(height: 24, color: Color(0xFFF1F5F9)),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'GRI Resume Builder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Official Gandhigram Rural Institute Format',
              style: TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.amberAccent,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.edit_note_rounded), text: 'Edit Fields'),
            Tab(icon: Icon(Icons.remove_red_eye_rounded), text: 'Live Preview'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_rounded),
            tooltip: 'Save & Generate PDF',
            onPressed: _exportPdf,
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFormTab(),
          _buildLivePreviewTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: const BorderSide(color: Color(0xFF2563EB)),
                    foregroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.description_rounded, size: 20),
                  label: const Text('Download Word (.docx)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  onPressed: _isExporting ? null : _exportDocx,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.picture_as_pdf_rounded, size: 20),
                  label: const Text('Download PDF',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  onPressed: _isExporting ? null : _exportPdf,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Voice Typing Tip Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFEFF6FF), Color(0xFFDBEAFE)],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: const Row(
              children: [
                Icon(Icons.mic_rounded, color: Color(0xFF2563EB), size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Voice Typing Available: Tap the 🎙️ icon next to any field to speak in English or Tamil. Edit anytime directly!',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF1E40AF),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Passport Photo & Customization Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(8),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Photo Preview Container
                    Container(
                      width: 72,
                      height: 86,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.2),
                      ),
                      child: _resumeData.photoPath != null && File(_resumeData.photoPath!).existsSync()
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                File(_resumeData.photoPath!),
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.add_a_photo_outlined, color: Colors.grey, size: 24),
                                  SizedBox(height: 2),
                                  Text('PHOTO', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Passport Photograph',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Embeds directly into the official GRI resume box in Live Preview & PDF.',
                            style: TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: PlaceTrackTheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  minimumSize: Size.zero,
                                  textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                icon: const Icon(Icons.upload_rounded, size: 14),
                                label: Text(_resumeData.photoPath != null ? 'Change Photo' : 'Upload Photo'),
                                onPressed: _pickPhoto,
                              ),
                              if (_resumeData.photoPath != null) ...[
                                const SizedBox(width: 8),
                                TextButton(
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                    minimumSize: Size.zero,
                                    textStyle: const TextStyle(fontSize: 11),
                                  ),
                                  onPressed: _removePhoto,
                                  child: const Text('Remove'),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 22, color: Color(0xFFF1F5F9)),

                // Color Theme Selector
                Row(
                  children: [
                    const Text('Theme: ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    ...[
                      {'name': 'GRI Emerald', 'val': 0xFF0F766E},
                      {'name': 'Corporate Navy', 'val': 0xFF1E3A8A},
                      {'name': 'Slate Grey', 'val': 0xFF334155},
                    ].map((th) {
                      final val = th['val'] as int;
                      final isSel = _resumeData.themeColorValue == val;
                      return InkWell(
                        onTap: () => setState(() => _resumeData.themeColorValue = val),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Color(val).withAlpha(isSel ? 40 : 15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: Color(val),
                              width: isSel ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(color: Color(val), shape: BoxShape.circle),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                th['name'] as String,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                  color: Color(val),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),

                // Optional Sections Expandable
                Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    childrenPadding: EdgeInsets.zero,
                    title: const Text(
                      'Customize Visible Resume Sections',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: PlaceTrackTheme.primary),
                    ),
                    children: [
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Certifications Section', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showCertifications,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showCertifications = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Work / Internship Experience', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showExperience,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showExperience = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Projects Involved', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showProjects,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showProjects = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Achievements & Awards', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showAchievements,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showAchievements = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Knowledge Acquisition Seminars', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showKnowledgeEvents,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showKnowledgeEvents = v),
                      ),
                      SwitchListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Extracurricular Activities', style: TextStyle(fontSize: 12)),
                        value: _resumeData.showExtracurricular,
                        activeThumbColor: PlaceTrackTheme.primary,
                        onChanged: (v) => setState(() => _resumeData.showExtracurricular = v),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 1. Personal & Contact Details
          _buildSectionCard(
            title: 'Personal & Contact Information',
            icon: Icons.person_rounded,
            child: Column(
              children: [
                _buildVoiceTextField(
                  label: 'Full Name',
                  controller: _nameController,
                  hint: 'Your official name as per college record',
                ),
                const SizedBox(height: 12),
                _buildVoiceTextField(
                  label: 'Email ID',
                  controller: _emailController,
                  hint: 'student@example.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildVoiceTextField(
                  label: 'Contact Number',
                  controller: _phoneController,
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildVoiceTextField(
                  label: 'Permanent Address',
                  controller: _addressController,
                  maxLines: 2,
                  hint: 'Door No, Street, City, District, PIN Code',
                ),
              ],
            ),
          ),

          // 2. Career Summary
          _buildSectionCard(
            title: 'Career Summary / Objective',
            icon: Icons.flag_rounded,
            child: _buildVoiceTextField(
              label: 'Career Objective Statement',
              controller: _careerSummaryController,
              maxLines: 4,
              hint:
                  'A motivated graduate seeking an opportunity to leverage technical skills in a progressive organization...',
            ),
          ),

          // 3. Educational Qualifications (Table Format as requested)
          _buildSectionCard(
            title: 'Educational Qualification (Table)',
            icon: Icons.school_rounded,
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: PlaceTrackTheme.primary,
                backgroundColor: PlaceTrackTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Row', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddEducationDialog(),
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFCBD5E1)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                      columnSpacing: 16,
                      columns: const [
                        DataColumn(label: Text('Degree/Course', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Institution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Board/Univ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Year', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('%/CGPA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                        DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      ],
                      rows: _resumeData.educationList.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final row = entry.value;
                        return DataRow(
                          cells: [
                            DataCell(Text(row.degree, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12))),
                            DataCell(Text(row.institution, style: const TextStyle(fontSize: 11))),
                            DataCell(Text(row.boardOrUniversity, style: const TextStyle(fontSize: 11))),
                            DataCell(Text(row.yearOfPassing, style: const TextStyle(fontSize: 11))),
                            DataCell(Text(row.percentageOrCgpa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Color(0xFF0F766E)))),
                            DataCell(
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_rounded, size: 16, color: Colors.blue),
                                    onPressed: () => _showAddEducationDialog(row, idx),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        _resumeData.educationList.removeAt(idx);
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 4. Skills Sets (Technical & Soft Skills)
          _buildSectionCard(
            title: 'Skills Sets',
            icon: Icons.military_tech_rounded,
            child: Column(
              children: [
                _buildVoiceTextField(
                  label: 'Technical Skills (Languages, Databases, Tools)',
                  controller: _technicalSkillsController,
                  maxLines: 3,
                  hint:
                      'Programming: Java, Python, C, C++, HTML, Dart\nDatabase: MySQL, PostgreSQL\nTools: Git, VS Code',
                ),
                const SizedBox(height: 14),
                _buildVoiceTextField(
                  label: 'Soft Skills',
                  controller: _softSkillsController,
                  maxLines: 2,
                  hint:
                      'Team leadership, Good communication, Problem solving & Analytical decision-making skills',
                ),
              ],
            ),
          ),

          // 5. Certifications
          _buildSectionCard(
            title: 'Certifications',
            icon: Icons.verified_rounded,
            child: _buildVoiceTextField(
              label: 'Certificates & Online Courses',
              controller: _certificationsController,
              maxLines: 3,
              hint: '• TCS iON Career Edge\n• Google Digital Marketing Certification',
            ),
          ),

          // 6. Work / Internship Experience
          _buildSectionCard(
            title: 'Work / Internship Experience',
            icon: Icons.work_rounded,
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: PlaceTrackTheme.primary,
                backgroundColor: PlaceTrackTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Experience', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddExperienceDialog(),
            ),
            child: Column(
              children: [
                if (_resumeData.experiences.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No experience added yet. Tap "+ Add Experience" above.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic)),
                  ),
                ..._resumeData.experiences.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final exp = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.business_rounded, color: PlaceTrackTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${exp.role} • ${exp.companyName}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(exp.duration,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                              if (exp.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(exp.description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                          onPressed: () => _showAddExperienceDialog(exp, idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          onPressed: () => setState(() => _resumeData.experiences.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 7. Projects Involved
          _buildSectionCard(
            title: 'Projects Involved',
            icon: Icons.code_rounded,
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: PlaceTrackTheme.primary,
                backgroundColor: PlaceTrackTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Project', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddProjectDialog(),
            ),
            child: Column(
              children: [
                if (_resumeData.projects.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text('No projects added yet. Tap "+ Add Project" above.',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13, fontStyle: FontStyle.italic)),
                  ),
                ..._resumeData.projects.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final p = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.folder_special_rounded, color: PlaceTrackTheme.primary, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('Tech: ${p.techStack} • ${p.duration}',
                                  style: const TextStyle(color: PlaceTrackTheme.primary, fontSize: 11, fontWeight: FontWeight.w600)),
                              if (p.description.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(p.description, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                              ],
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                          onPressed: () => _showAddProjectDialog(p, idx),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.red),
                          onPressed: () => setState(() => _resumeData.projects.removeAt(idx)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          // 8. Achievements & Awards
          _buildSectionCard(
            title: 'Achievements & Awards',
            icon: Icons.emoji_events_rounded,
            child: _buildVoiceTextField(
              label: 'Achievements / Prizes Won',
              controller: _achievementsController,
              maxLines: 3,
              hint: '• 1st prize in State Level Hackathon\n• Secured University Gold Medal',
            ),
          ),

          // 9. Knowledge Acquisition Events / Seminars
          _buildSectionCard(
            title: 'Knowledge Acquisition Events / Seminars',
            icon: Icons.lightbulb_rounded,
            child: _buildVoiceTextField(
              label: 'Seminars, Conferences & Workshops Attended',
              controller: _knowledgeEventsController,
              maxLines: 3,
              hint: '• Attended National Seminar on Cloud Architecture\n• Participant in AI Symposium',
            ),
          ),

          // 10. Extracurricular Activities
          _buildSectionCard(
            title: 'Extracurricular Activities',
            icon: Icons.sports_volleyball_rounded,
            child: _buildVoiceTextField(
              label: 'Clubs, Sports, NSS & Social Activities',
              controller: _extracurricularController,
              maxLines: 2,
              hint: '• Active member of Campus Red Ribbon Club\n• Member of University Cricket Team',
            ),
          ),

          // 11. Languages Known
          _buildSectionCard(
            title: 'Languages Known',
            icon: Icons.translate_rounded,
            child: _buildVoiceTextField(
              label: 'Spoken / Written Languages',
              controller: _languagesKnownController,
              hint: 'Tamil, English, Hindi',
            ),
          ),

          // 12. References (Preloaded with Dr. G. Kingsly, Placement Officer, GRI)
          _buildSectionCard(
            title: 'References (GRI Placement Cell)',
            icon: Icons.contact_phone_rounded,
            trailing: TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: PlaceTrackTheme.primary,
                backgroundColor: PlaceTrackTheme.primary.withAlpha(20),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              ),
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Add Ref', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              onPressed: () => _showAddReferenceDialog(),
            ),
            child: Column(
              children: [
                ..._resumeData.references.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final ref = entry.value;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.person_pin_rounded, color: PlaceTrackTheme.primary, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${ref.name}, ${ref.designation}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text(ref.institution,
                                  style: const TextStyle(color: Colors.black87, fontSize: 11)),
                              Text('Mobile: ${ref.mobile} • Email: ${ref.email}',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, size: 18, color: Colors.blue),
                          onPressed: () => _showAddReferenceDialog(ref, idx),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildLivePreviewTab() {
    _syncControllersToModel();

    return PdfPreview(
      build: (format) => GriResumeExportService.buildPdfDocument(_resumeData),
      canChangeOrientation: false,
      canChangePageFormat: false,
      canDebug: false,
      allowSharing: true,
      allowPrinting: true,
      previewPageMargin: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      pdfFileName: 'GRI_Resume_${_resumeData.fullName.replaceAll(" ", "_")}.pdf',
      loadingWidget: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: PlaceTrackTheme.primary),
            SizedBox(height: 12),
            Text(
              'Rendering Official GRI Resume Document...',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
