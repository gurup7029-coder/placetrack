import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../../services/supabase_config.dart';
import '../../services/theme_service.dart';
import '../auth/login_screen.dart';
import '../placements/drive_management_screen.dart';
import '../students/student_list_screen.dart';
import '../training/training_screen.dart';
import '../reports/reports_screen.dart';
import '../notifications/announcements_screen.dart';
import '../settings/settings_screen.dart';
import '../analytics/placement_analytics_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String adminEmail;

  const DashboardScreen({
    super.key,
    this.adminEmail = 'admin@placetrack.edu',
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
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
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: PlaceTrackTheme.danger,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _showEligibleStudentsModal() {
    final students = _service.students;
    final eligibleStudents = students.where((s) => s.cgpa >= 7.0 && s.backlogs == 0).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const Row(
                  children: [
                    Icon(Icons.school_rounded, color: Color(0xFF2563EB)),
                    SizedBox(width: 8),
                    Text('Eligible Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${eligibleStudents.length} / ${students.length} Eligible',
                    style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: students.length,
                itemBuilder: (ctx, idx) {
                  final s = students[idx];
                  final isEligible = s.cgpa >= 7.0 && s.backlogs == 0;
                  final hasPhoto = s.profileImagePath.isNotEmpty && File(s.profileImagePath).existsSync();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withAlpha(50)),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: const Color(0xFF2563EB).withAlpha(25),
                          backgroundImage: hasPhoto ? FileImage(File(s.profileImagePath)) : null,
                          child: !hasPhoto
                              ? Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2563EB)))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text('${s.regNo} • ${s.department}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('CGPA ${s.cgpa}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: isEligible ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isEligible ? 'Eligible ✓' : '${s.backlogs} Backlogs',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isEligible ? const Color(0xFF059669) : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPlacedStudentsModal() {
    final students = _service.students;
    final drives = _service.drives;

    final placedItems = <Map<String, dynamic>>[];
    for (final d in drives) {
      for (final sid in d.placedStudentIds) {
        final s = students.where((st) => st.id == sid).firstOrNull;
        if (s != null) {
          placedItems.add({
            'student': s,
            'company': d.companyName,
            'role': d.role,
            'package': d.packageLpa,
          });
        }
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_rounded, color: Color(0xFF16A34A)),
                    SizedBox(width: 8),
                    Text('Placed Students', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${placedItems.length} Placed Candidates',
                    style: const TextStyle(color: Color(0xFF16A34A), fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (placedItems.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No students marked as placed yet. Use Drives & Rounds to select placed candidates.'),
                ),
              )
            else
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: placedItems.length,
                  itemBuilder: (ctx, idx) {
                    final item = placedItems[idx];
                    final s = item['student'] as StudentModel;
                    final company = item['company'] as String;
                    final role = item['role'] as String;
                    final pkg = item['package'] as String;
                    final hasPhoto = s.profileImagePath.isNotEmpty && File(s.profileImagePath).existsSync();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: const Color(0xFF16A34A).withAlpha(25),
                            backgroundImage: hasPhoto ? FileImage(File(s.profileImagePath)) : null,
                            child: !hasPhoto
                                ? Text(s.name.isNotEmpty ? s.name[0] : 'S', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF16A34A)))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(s.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    const SizedBox(width: 6),
                                    const Icon(Icons.verified_rounded, size: 14, color: Color(0xFF16A34A)),
                                  ],
                                ),
                                Text('$company • $role', style: const TextStyle(fontSize: 12, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w600)),
                                Text('Reg: ${s.regNo} (${s.department})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECFDF5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              pkg,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showActiveDrivesModal() {
    final drives = _service.drives;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
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
                const Row(
                  children: [
                    Icon(Icons.business_center_rounded, color: Color(0xFF9333EA)),
                    SizedBox(width: 8),
                    Text('Active Campus Drives', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
                TextButton.icon(
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: const Text('Manage'),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const DriveManagementScreen()));
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.55),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: drives.length,
                itemBuilder: (ctx, idx) {
                  final d = drives[idx];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const DriveManagementScreen()));
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(ctx).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF9333EA).withAlpha(20),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.apartment_rounded, color: Color(0xFF9333EA), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(d.companyName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(d.role, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                Text('${d.rounds.length} Selection Rounds • ${d.placedStudentIds.length} Placed', style: const TextStyle(fontSize: 10, color: Color(0xFF9333EA), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                          Text(d.packageLpa, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669), fontSize: 13)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showHighestPackageModal() {
    final highestPkg = _service.highestPackage;
    final drives = _service.drives;
    final topDrive = drives.isNotEmpty
        ? drives.reduce((curr, next) {
            double c = double.tryParse(curr.packageLpa.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            double n = double.tryParse(next.packageLpa.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
            return c >= n ? curr : next;
          })
        : null;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
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
            const Row(
              children: [
                Icon(Icons.military_tech_rounded, color: Color(0xFFEA580C), size: 28),
                SizedBox(width: 8),
                Text('Highest Package CTC', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Top Placement Offer', style: TextStyle(color: Colors.white70, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(highestPkg, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(topDrive != null ? '${topDrive.companyName} • ${topDrive.role}' : 'Campus Highest', style: const TextStyle(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                  const Icon(Icons.stars_rounded, color: Colors.amberAccent, size: 48),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('CTC Salary Breakdown:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            const SizedBox(height: 8),
            _buildCtcLine('Fixed Base Component', '₹ 9,50,000 / annum'),
            _buildCtcLine('Joining & Relocation Bonus', '₹ 1,50,000 one-time'),
            _buildCtcLine('Performance Incentive Pool', '₹ 1,00,000 / annum'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildCtcLine(String title, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeService = ThemeService();
    final isDark = themeService.isDarkMode;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'PlaceTrack',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              widget.adminEmail,
              style: const TextStyle(
                fontSize: 12,
                color: PlaceTrackTheme.textSecondary,
                fontWeight: FontWeight.normal,
              ),
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
                MaterialPageRoute(builder: (_) => const AnnouncementsScreen(isAdmin: true)),
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
            tooltip: 'Settings & Cell Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
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
            // Banner Welcome
            _buildWelcomeCard(),
            const SizedBox(height: 16),

            // Supabase Cloud Database Sync Status (Admin Exclusive)
            _buildCloudDatabaseCard(),
            const SizedBox(height: 8),

            // Placement Statistics Grid
            Text(
              'Placement Overview (2025-26)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActions(),
            const SizedBox(height: 24),

            // Recent Placement Drives
            Text(
              'Upcoming & Active Drives',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildActiveDrivesList(),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (idx) {
          setState(() => _selectedIndex = idx);
          if (idx == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StudentListScreen()),
            );
          } else if (idx == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriveManagementScreen()),
            );
          } else if (idx == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TrainingScreen()),
            );
          } else if (idx == 4) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReportsScreen()),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people_rounded),
            label: 'Students',
          ),
          NavigationDestination(
            icon: Icon(Icons.business_outlined),
            selectedIcon: Icon(Icons.business_rounded),
            label: 'Companies',
          ),
          NavigationDestination(
            icon: Icon(Icons.model_training_outlined),
            selectedIcon: Icon(Icons.model_training_rounded),
            label: 'Training',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'Reports',
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withAlpha(50),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Placement Officer Console',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              const Text(
                'Batch 2026',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Placement Cell Operations',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Manage student records, organize recruitment drives, track selection rounds, and monitor placements.',
            style: TextStyle(
              color: Colors.white.withAlpha(210),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCloudDatabaseCard() {
    final isPaused = _service.isDatabasePaused;
    final isConnected = _service.isCloudConnected;

    if (isConnected) {
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF064E3B).withAlpha(40),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF059669).withAlpha(120)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF059669).withAlpha(40),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_done_rounded, color: Color(0xFF10B981), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Supabase Cloud: Active & Connected',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF10B981)),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Web Portal & Mobile App are synchronized in real-time.',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.sync_rounded, size: 20, color: Color(0xFF10B981)),
              tooltip: 'Sync Now',
              onPressed: () {
                _service.initSupabaseSync();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Syncing data with Supabase Cloud...'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    // When Database is Paused or Offline
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF451A03).withAlpha(70),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.amber.shade700.withAlpha(180)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade900.withAlpha(80),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_off_rounded, color: Colors.amber, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isPaused ? '⚠️ Supabase Database Paused (Free Tier)' : 'Cloud Sync Offline (Local Mode)',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5, color: Colors.amber),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isPaused
                          ? 'Project was auto-paused due to inactivity. Restore it in 1 click on your Supabase dashboard to enable live Web & Mobile sync.'
                          : 'Currently using local storage. All changes are saved safely on this device.',
                      style: const TextStyle(fontSize: 11.5, color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (isPaused)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade600,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () async {
                      final uri = Uri.parse(SupabaseConfig.restoreUrl);
                      try {
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      } catch (_) {}
                    },
                    icon: const Icon(Icons.open_in_new_rounded, size: 16),
                    label: const Text('Restore on Supabase (1-Click)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),
              if (isPaused) const SizedBox(width: 8),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.amber.shade600),
                  foregroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  _service.initSupabaseSync();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Checking Supabase connection & syncing...'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Sync Check', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalEligible = _service.totalEligibleCount;
    final totalStudents = _service.totalStudentsCount;
    final placedCount = _service.totalPlacedCount;
    final placementPct = _service.placementPercentage.toStringAsFixed(1);
    final partnerCompanies = _service.partnerCompaniesCount;
    final highestPkg = _service.highestPackage;

    final stats = [
      {
        'title': 'Total Eligible',
        'value': '$totalEligible / $totalStudents',
        'sub': '$totalStudents Registered Students',
        'icon': Icons.school_rounded,
        'color': const Color(0xFF2563EB),
      },
      {
        'title': 'Students Placed',
        'value': '$placedCount',
        'sub': '$placementPct% Placement Rate',
        'icon': Icons.check_circle_rounded,
        'color': const Color(0xFF16A34A),
      },
      {
        'title': 'Active Drives',
        'value': '$partnerCompanies Companies',
        'sub': '${_service.drives.fold<int>(0, (sum, d) => sum + d.rounds.length)} Total Rounds Active',
        'icon': Icons.apartment_rounded,
        'color': const Color(0xFF9333EA),
      },
      {
        'title': 'Highest Package',
        'value': highestPkg,
        'sub': 'Verified Placements',
        'icon': Icons.currency_rupee_rounded,
        'color': const Color(0xFFEA580C),
      },
    ];

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: stats.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.35,
      ),
      itemBuilder: (context, index) {
        final item = stats[index];
        final color = item['color'] as Color;
        final isDark = ThemeService().isDarkMode;

        VoidCallback? cardTap;
        if (index == 0) cardTap = _showEligibleStudentsModal;
        if (index == 1) cardTap = _showPlacedStudentsModal;
        if (index == 2) cardTap = _showActiveDrivesModal;
        if (index == 3) cardTap = _showHighestPackageModal;

        return InkWell(
          onTap: cardTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : const Color(0xFFE2E8F0)),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item['title'] as String,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: PlaceTrackTheme.textSecondary,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(item['icon'] as IconData, color: color, size: 18),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['value'] as String,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item['sub'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: color,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    final isDark = ThemeService().isDarkMode;
    final actions = [
      {'label': 'Add Student', 'icon': Icons.person_add_alt_1_rounded},
      {'label': 'Import CSV', 'icon': Icons.upload_file_rounded},
      {'label': 'New Drive', 'icon': Icons.add_business_rounded},
      {'label': 'Drives & Rounds', 'icon': Icons.assignment_turned_in_rounded},
    ];

    return Row(
      children: actions.map((act) {
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              onTap: () {
                if (act['label'] == 'New Drive' || act['label'] == 'Drives & Rounds') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const DriveManagementScreen()),
                  );
                } else if (act['label'] == 'Add Student' || act['label'] == 'Import CSV') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const StudentListScreen()),
                  );
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: [
                    Icon(act['icon'] as IconData, color: PlaceTrackTheme.primary, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      act['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildActiveDrivesList() {
    final drives = _service.drives;
    final isDark = ThemeService().isDarkMode;

    if (drives.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Center(
          child: Text('No placement drives added yet. Click "New Drive" to create one.', style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : Colors.black54)),
        ),
      );
    }

    return Column(
      children: drives.map((d) {
        final currentRound = d.rounds.isNotEmpty ? d.rounds.last.name : 'No rounds yet';
        final shortlistedCount = d.rounds.isNotEmpty ? d.rounds.last.qualifiedStudentIds.length : 0;

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DriveManagementScreen()),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: isDark ? PlaceTrackTheme.darkBorder : const Color(0xFFE2E8F0)),
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      d.companyName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : PlaceTrackTheme.textPrimary,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      d.packageLpa,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                d.role,
                style: const TextStyle(
                  fontSize: 13,
                  color: PlaceTrackTheme.textSecondary,
                ),
              ),
              if (d.registrationLink.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  'Form: ${d.registrationLink}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: PlaceTrackTheme.primary, fontWeight: FontWeight.w500),
                ),
              ],
              const Divider(height: 18),
              Row(
                children: [
                  const Icon(
                    Icons.timeline_rounded,
                    size: 16,
                    color: PlaceTrackTheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '$currentRound ($shortlistedCount shortlisted)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: PlaceTrackTheme.primary,
                      ),
                    ),
                  ),
                  Text(
                    '${d.placedStudentIds.length} Placed',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF16A34A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        );
      }).toList(),
    );
  }
}
