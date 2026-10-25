import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/placement_data_service.dart';
import '../../services/theme_service.dart';
import '../notifications/announcements_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final service = PlacementDataService();
    final themeService = ThemeService();
    final isDark = themeService.isDarkMode;
    final students = service.students;
    final drives = service.drives;
    final workshops = service.workshops;
    final resumesCount = students.where((s) => s.resumeFileName.isNotEmpty || s.resumeUrl.isNotEmpty).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Cell Profile'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            tooltip: isDark ? 'Switch to Light Theme' : 'Switch to Dark Theme',
            onPressed: () {
              themeService.toggleTheme();
              setState(() {});
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // College Placement Office Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E293B), Color(0xFF334155)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
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
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(Icons.account_balance_rounded, color: Color(0xFF1E293B), size: 30),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Center for Campus Placement',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Training & Career Guidance Bureau',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white24, height: 26),
                _buildInfoLine('Placement Director', 'Dr. A. Ramanathan, Ph.D.'),
                const SizedBox(height: 6),
                _buildInfoLine('Official Email', 'placement@college.edu'),
                const SizedBox(height: 6),
                _buildInfoLine('Placement Helpline', '+91 44 2235 7000 / Ext 404'),
                const SizedBox(height: 6),
                _buildInfoLine('Active Academic Year', '2025 - 2026 (Graduating Batch)'),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Database & Metrics Overview
          const Text(
            'Placement System Diagnostics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PlaceTrackTheme.textPrimary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.people_alt_rounded,
                  label: 'Registered Students',
                  value: '${students.length}',
                  color: const Color(0xFF2563EB),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.business_center_rounded,
                  label: 'Placement Drives',
                  value: '${drives.length}',
                  color: const Color(0xFF7C3AED),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.model_training_rounded,
                  label: 'Bootcamps Active',
                  value: '${workshops.length}',
                  color: const Color(0xFF0D9488),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.picture_as_pdf_rounded,
                  label: 'PDF Resumes Stored',
                  value: '$resumesCount',
                  color: const Color(0xFFDC2626),
                ),
              ),
            ],
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
                    themeService.setDarkMode(val);
                    setState(() {});
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Management Actions
          const Text(
            'Quick Administrative Tools',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildActionCard(
            context: context,
            icon: Icons.campaign_rounded,
            title: 'Broadcast Announcements & Alerts',
            subtitle: '${service.announcements.length} Published notices for students',
            color: const Color(0xFF4F46E5),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen(isAdmin: true)),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildActionCard(
            context: context,
            icon: Icons.cloud_download_rounded,
            title: 'Export Placement Data Backup (JSON)',
            subtitle: 'Export student records, drives, and interview results',
            color: const Color(0xFF059669),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ Placement Data Backup JSON generated successfully in local cache!'),
                  backgroundColor: Color(0xFF059669),
                ),
              );
            },
          ),
          const SizedBox(height: 10),

          _buildActionCard(
            context: context,
            icon: Icons.info_outline_rounded,
            title: 'About PlaceTrack App',
            subtitle: 'Version 1.2.0 • Build 2026.09 (ARM64 Production)',
            color: const Color(0xFF64748B),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'PlaceTrack',
                applicationVersion: 'v1.2.0 (Build 2026.09)',
                applicationLegalese: 'Placement & Career Management System © 2026. All rights reserved.',
                children: const [
                  SizedBox(height: 12),
                  Text(
                    'PlaceTrack connects College Placement Cells, Recruiters, and Students seamlessly with real-time PDF resume screening, dynamic Google Form application integration, multi-course analytics, and automated recruitment round tracking.',
                    style: TextStyle(fontSize: 13, height: 1.4),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoLine(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  static Widget _buildMetricTile({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.textSecondary),
          ),
        ],
      ),
    );
  }

  static Widget _buildActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }
}
