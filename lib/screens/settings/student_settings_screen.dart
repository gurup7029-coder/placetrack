import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../../services/theme_service.dart';
import '../../services/resume_viewer_service.dart';
import '../auth/login_screen.dart';
import '../resume/gri_resume_builder_screen.dart';

class StudentSettingsScreen extends StatefulWidget {
  final StudentModel student;

  const StudentSettingsScreen({
    super.key,
    required this.student,
  });

  @override
  State<StudentSettingsScreen> createState() => _StudentSettingsScreenState();
}

class _StudentSettingsScreenState extends State<StudentSettingsScreen> {
  final _service = PlacementDataService();
  final _themeService = ThemeService();

  bool _alertDrives = true;
  bool _alertRounds = true;
  bool _alertMockTests = true;

  StudentModel _getStudent() {
    return _service.students.firstWhere(
      (s) => s.id == widget.student.id,
      orElse: () => widget.student,
    );
  }

  Future<void> _pickProfilePhoto(StudentModel student) async {
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isNotEmpty && files.first.path != null) {
        final path = files.first.path!;
        _service.updateStudentProfileImage(student.id, path);
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
          SnackBar(content: Text('Could not pick image: $e')),
        );
      }
    }
  }

  void _removeProfilePhoto(StudentModel student) {
    _service.updateStudentProfileImage(student.id, '');
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile photo removed.')),
    );
  }

  void _showPhotoOptions(StudentModel student) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded, color: PlaceTrackTheme.primary),
              title: const Text('Choose Photo from Storage'),
              onTap: () {
                Navigator.pop(ctx);
                _pickProfilePhoto(student);
              },
            ),
            if (student.profileImagePath.isNotEmpty)
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Remove Current Photo', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _removeProfilePhoto(student);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to log out of PlaceTrack?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: PlaceTrackTheme.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final student = _getStudent();
    final isDark = _themeService.isDarkMode;
    final hasCustomPhoto = student.profileImagePath.isNotEmpty && File(student.profileImagePath).existsSync();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Settings & Profile'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
            onPressed: () {
              _themeService.toggleTheme();
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Profile Header with Photo Editor
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
              children: [
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      backgroundImage: hasCustomPhoto ? FileImage(File(student.profileImagePath)) : null,
                      child: !hasCustomPhoto
                          ? Text(
                              student.name.isNotEmpty ? student.name[0] : 'S',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F766E),
                              ),
                            )
                          : null,
                    ),
                    GestureDetector(
                      onTap: () => _showPhotoOptions(student),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(40),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 18,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  student.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Reg No: ${student.regNo}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withAlpha(220),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${student.department} • ${student.year}',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: Text(hasCustomPhoto ? 'Change Photo' : 'Upload Profile Photo'),
                  onPressed: () => _showPhotoOptions(student),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Theme Settings (Dark Theme & White Theme)
          const Text(
            'App Appearance (Theme)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : PlaceTrackTheme.border),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: isDark ? const Color(0xFFA855F7) : PlaceTrackTheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isDark ? 'Dark Theme Active' : 'Light Theme (White)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDark ? 'Sleek dark mode for low-light comfort' : 'Crisp white & blue corporate design',
                        style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: isDark,
                  activeThumbColor: const Color(0xFFA855F7),
                  onChanged: (val) {
                    _themeService.setDarkMode(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Resume Tools
          const Text(
            'Career & Resume Management',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildActionTile(
            context: context,
            icon: Icons.edit_document,
            iconColor: const Color(0xFF059669),
            title: 'GRI Resume Builder',
            subtitle: 'Build official GRI format resume with vector PDF and Word export',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => GriResumeBuilderScreen(student: student)),
              );
            },
          ),
          const SizedBox(height: 8),
          if (student.resumeFileName.isNotEmpty || student.resumeUrl.isNotEmpty)
            _buildActionTile(
              context: context,
              icon: Icons.picture_as_pdf_rounded,
              iconColor: const Color(0xFFDC2626),
              title: 'View Active PDF Resume',
              subtitle: student.resumeFileName.isNotEmpty ? student.resumeFileName : 'Resume.pdf',
              onTap: () {
                ResumeViewerService.openStudentResume(context: context, student: student);
              },
            ),
          const SizedBox(height: 20),

          // Notifications Preferences
          const Text(
            'Notification Preferences',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : PlaceTrackTheme.border),
            ),
            child: Column(
              children: [
                SwitchListTile(
                  activeThumbColor: PlaceTrackTheme.primary,
                  secondary: const Icon(Icons.campaign_outlined, color: PlaceTrackTheme.primary),
                  title: const Text('Campus Placement Drives', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Get notified when new company visits are posted', style: TextStyle(fontSize: 12)),
                  value: _alertDrives,
                  onChanged: (v) => setState(() => _alertDrives = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: PlaceTrackTheme.primary,
                  secondary: const Icon(Icons.check_circle_outline, color: Color(0xFF059669)),
                  title: const Text('Interview & Shortlist Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Immediate alerts when round qualification results are out', style: TextStyle(fontSize: 12)),
                  value: _alertRounds,
                  onChanged: (v) => setState(() => _alertRounds = v),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  activeThumbColor: PlaceTrackTheme.primary,
                  secondary: const Icon(Icons.quiz_outlined, color: Color(0xFF7C3AED)),
                  title: const Text('Mock Tests & Aptitude Quizzes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                  subtitle: const Text('Daily technical and reasoning practice test reminders', style: TextStyle(fontSize: 12)),
                  value: _alertMockTests,
                  onChanged: (v) => setState(() => _alertMockTests = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Help & Placement Office Info
          const Text(
            'Placement Cell Help & Support',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : PlaceTrackTheme.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.contact_support_outlined, color: PlaceTrackTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Placement Officer:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 6),
                    Text('Dr. A. Ramanathan'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.mail_outline_rounded, color: PlaceTrackTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Email Support:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 6),
                    Text('placement@college.edu'),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.phone_in_talk_outlined, color: PlaceTrackTheme.primary, size: 20),
                    SizedBox(width: 8),
                    Text('Helpline Ext:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 6),
                    Text('+91 44 2235 7000 / Ext 404'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Sign Out Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: PlaceTrackTheme.danger,
                side: const BorderSide(color: PlaceTrackTheme.danger),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out of PlaceTrack'),
              onPressed: _logout,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'PlaceTrack v1.2.0 • Build 2026.09 (Production)',
              style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = ThemeService().isDarkMode;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : PlaceTrackTheme.border),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
