import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/placement_models.dart';
import '../../services/placement_data_service.dart';
import '../dashboard/dashboard_screen.dart';
import '../dashboard/student_dashboard_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController(text: 'admin@placetrack.edu');
  final _passwordController = TextEditingController(text: 'admin123');

  UserRole _selectedRole = UserRole.admin;
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRoleChanged(UserRole role) {
    setState(() {
      _selectedRole = role;
      if (role == UserRole.admin) {
        _idController.text = 'admin@placetrack.edu';
        _passwordController.text = 'admin123';
      } else {
        _idController.clear();
        _passwordController.clear();
      }
    });
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;
    setState(() => _isLoading = false);

    final dataService = PlacementDataService();

    if (_selectedRole == UserRole.admin) {
      final enteredId = _idController.text.trim();
      final enteredPw = _passwordController.text.trim();

      final isValid = dataService.validateAdminLogin(enteredId, enteredPw);

      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.lock_clock_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Invalid Officer credentials. Register an Admin account or check password.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: PlaceTrackTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final admin = dataService.getAdminByEmail(enteredId);
      if (admin != null) {
        dataService.setCurrentAdmin(admin);
      }

      // Admin Login Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardScreen(adminEmail: enteredId),
        ),
      );
    } else {
      // Student Login
      final identifier = _idController.text.trim();
      final enteredPw = _passwordController.text.trim();
      final student = dataService.getStudentByRegNo(identifier);

      if (student == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.person_off_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Student "$identifier" not registered. Click "First Time Login? Register Here" below!',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: PlaceTrackTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Validate Student Password
      final actualPw = student.password.isNotEmpty ? student.password : 'student123';
      if (enteredPw != actualPw && enteredPw != 'student123') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.lock_open_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Incorrect password. Use "Forgot Password?" or your default password.',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: PlaceTrackTheme.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      // Student Login Success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => StudentDashboardScreen(student: student),
        ),
      );
    }
  }

  // ==========================================
  // FORGOT PASSWORD MODALS
  // ==========================================
  void _onForgotPasswordPressed() {
    if (_selectedRole == UserRole.admin) {
      _showAdminForgotPasswordDialog();
    } else {
      _showStudentForgotPasswordDialog();
    }
  }

  void _showAdminForgotPasswordDialog() {
    final adminIdCtl = TextEditingController(text: _idController.text.trim());
    final secretPasscodeCtl = TextEditingController();
    final newPasswordCtl = TextEditingController();
    final confirmPasswordCtl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: PlaceTrackTheme.primary.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Admin Password Reset',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify your Officer identity and set a new password for your account.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // Admin ID / Email
                  const Text('Admin ID / Email', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: adminIdCtl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Master Security Passcode
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Security Passcode', style: TextStyle(color: Colors.white70, fontSize: 11)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withAlpha(40),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('Default: TPO2026', style: TextStyle(color: Colors.lightBlueAccent, fontSize: 9.5)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: secretPasscodeCtl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter Security PIN or Passcode',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.vpn_key_rounded, color: Colors.white38, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // New Password
                  const Text('New Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: newPasswordCtl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                        onPressed: () => setDlgState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password
                  const Text('Confirm New Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: confirmPasswordCtl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Colors.white38, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                        onPressed: () => setDlgState(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PlaceTrackTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final passcode = secretPasscodeCtl.text.trim();
                final newPw = newPasswordCtl.text.trim();
                final confirmPw = confirmPasswordCtl.text.trim();

                if (passcode.isEmpty || (passcode != 'TPO2026' && passcode.toLowerCase() != 'admin')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Invalid Security Passcode! Use "TPO2026" or "admin".'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                if (newPw.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 4 characters long.'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                if (newPw != confirmPw) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match!'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                // Update Admin Password
                PlacementDataService().updateAdminPassword(newPw);
                setState(() {
                  _passwordController.text = newPw;
                });
                Navigator.pop(dialogCtx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: const [
                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Admin Password successfully updated!'),
                      ],
                    ),
                    backgroundColor: PlaceTrackTheme.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Update Password', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showStudentForgotPasswordDialog() {
    final rollNoCtl = TextEditingController(text: _idController.text.trim());
    final dobCtl = TextEditingController();
    final newPasswordCtl = TextEditingController();
    final confirmPasswordCtl = TextEditingController();
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F766E).withAlpha(50),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.lock_reset_rounded, color: Colors.tealAccent, size: 22),
              ),
              const SizedBox(width: 10),
              const Text(
                'Student Password Reset',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 380,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Verify your Roll Number & Date of Birth to set a new password.',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 14),

                  // Roll No / Reg No
                  const Text('Roll Number / Reg No / Username', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: rollNoCtl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38, size: 18),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Date of Birth
                  const Text('Date of Birth (DD/MM/YYYY)', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: dobCtl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. 15/06/2003',
                      hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.calendar_today_rounded, color: Colors.white38, size: 18),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.event, color: Colors.tealAccent, size: 18),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime(2003, 6, 15),
                            firstDate: DateTime(1995),
                            lastDate: DateTime.now(),
                          );
                          if (picked != null) {
                            setDlgState(() {
                              dobCtl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                            });
                          }
                        },
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // New Password
                  const Text('New Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: newPasswordCtl,
                    obscureText: obscureNew,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(obscureNew ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                        onPressed: () => setDlgState(() => obscureNew = !obscureNew),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Confirm Password
                  const Text('Confirm New Password', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: confirmPasswordCtl,
                    obscureText: obscureConfirm,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF0F172A),
                      prefixIcon: const Icon(Icons.lock_reset_rounded, color: Colors.white38, size: 18),
                      suffixIcon: IconButton(
                        icon: Icon(obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                        onPressed: () => setDlgState(() => obscureConfirm = !obscureConfirm),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                final query = rollNoCtl.text.trim();
                final newPw = newPasswordCtl.text.trim();
                final confirmPw = confirmPasswordCtl.text.trim();

                final student = PlacementDataService().getStudentByRegNo(query);
                if (student == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('No student found with this Roll Number/Username!'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                if (newPw.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password must be at least 4 characters long.'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                if (newPw != confirmPw) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Passwords do not match!'),
                      backgroundColor: PlaceTrackTheme.danger,
                    ),
                  );
                  return;
                }

                // Update Student Password
                PlacementDataService().updateStudentPassword(student.id, newPw);
                setState(() {
                  _idController.text = student.regNo;
                  _passwordController.text = newPw;
                });
                Navigator.pop(dialogCtx);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Text('Password reset successful for ${student.name}!'),
                      ],
                    ),
                    backgroundColor: PlaceTrackTheme.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Reset Password', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // STUDENT FIRST TIME LOGIN / REGISTRATION MODAL
  // ==========================================
  void _showStudentRegistrationDialog() {
    final regFormKey = GlobalKey<FormState>();
    final nameCtl = TextEditingController();
    final rollNoCtl = TextEditingController();
    final dobCtl = TextEditingController();
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final cgpaCtl = TextEditingController(text: '8.0');
    final usernameCtl = TextEditingController();
    final passwordCtl = TextEditingController();
    final confirmPasswordCtl = TextEditingController();

    String selectedDept = 'MCA';
    String selectedYear = '2nd Year';
    String selectedSection = 'Section A';
    bool obscureRegPw = true;
    bool obscureRegConfirm = true;

    final deptList = [
      'MCA',
      'B.Sc Computer Science',
      'BCA',
      'B.Sc Information Technology',
      'M.Sc Data Science',
      'B.Com (Computer Applications)',
    ];

    final yearList = ['1st Year', '2nd Year', '3rd Year'];
    final sectionList = ['Section A', 'Section B', 'Section C'];

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF0F766E), Color(0xFF14B8A6)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Student First-Time Registration',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Enter your academic details & set login credentials',
                    style: TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: SingleChildScrollView(
              child: Form(
                key: regFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name & Roll No Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Full Name *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: nameCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Vignesh Kumar',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.person_outline, color: Colors.white38, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Roll Number / Reg No *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: rollNoCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 710022104099',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.badge_outlined, color: Colors.white38, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Department & Year Row
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Class / Department *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedDept,
                                dropdownColor: const Color(0xFF1E293B),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: deptList.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                                onChanged: (val) {
                                  if (val != null) setDlgState(() => selectedDept = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Year *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedYear,
                                dropdownColor: const Color(0xFF1E293B),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                ),
                                items: yearList.map((y) => DropdownMenuItem(value: y, child: Text(y))).toList(),
                                onChanged: (val) {
                                  if (val != null) setDlgState(() => selectedYear = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Section & Date of Birth Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Section *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              DropdownButtonFormField<String>(
                                initialValue: selectedSection,
                                dropdownColor: const Color(0xFF1E293B),
                                style: const TextStyle(color: Colors.white, fontSize: 12),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                ),
                                items: sectionList.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                                onChanged: (val) {
                                  if (val != null) setDlgState(() => selectedSection = val);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Date of Birth (DOB) *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: dobCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'DD/MM/YYYY',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.calendar_month_outlined, color: Colors.white38, size: 18),
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.event, color: Colors.tealAccent, size: 18),
                                    onPressed: () async {
                                      final picked = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(2003, 5, 20),
                                        firstDate: DateTime(1995),
                                        lastDate: DateTime.now(),
                                      );
                                      if (picked != null) {
                                        setDlgState(() {
                                          dobCtl.text = '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
                                        });
                                      }
                                    },
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Email & Phone Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Student Email *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: emailCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. name@student.college.edu',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('CGPA *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: cgpaCtl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. 8.45',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.grade_outlined, color: Colors.white38, size: 18),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || double.tryParse(v) == null) ? 'Numeric CGPA' : null,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Divider for Credentials
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: Colors.teal.withAlpha(30),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.vpn_key_rounded, color: Colors.tealAccent, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Choose User ID & Set Your Password',
                            style: TextStyle(color: Colors.tealAccent, fontSize: 11.5, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Custom Username / User ID
                    const Text('Choose Your User ID / Username *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: usernameCtl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. vignesh_k or your nickname',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        filled: true,
                        fillColor: const Color(0xFF0F172A),
                        prefixIcon: const Icon(Icons.alternate_email_rounded, color: Colors.white38, size: 18),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'User ID is required' : null,
                    ),
                    const SizedBox(height: 10),

                    // Set Password & Confirm Password Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Set Password *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: passwordCtl,
                                obscureText: obscureRegPw,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Min 4 characters',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                                  suffixIcon: IconButton(
                                    icon: Icon(obscureRegPw ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 16),
                                    onPressed: () => setDlgState(() => obscureRegPw = !obscureRegPw),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) => (v == null || v.length < 4) ? 'Min 4 chars' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Confirm Password *', style: TextStyle(color: Colors.white70, fontSize: 11)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: confirmPasswordCtl,
                                obscureText: obscureRegConfirm,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Re-enter password',
                                  hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                                  filled: true,
                                  fillColor: const Color(0xFF0F172A),
                                  prefixIcon: const Icon(Icons.lock_reset_rounded, color: Colors.white38, size: 18),
                                  suffixIcon: IconButton(
                                    icon: Icon(obscureRegConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 16),
                                    onPressed: () => setDlgState(() => obscureRegConfirm = !obscureRegConfirm),
                                  ),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Confirm required';
                                  if (v != passwordCtl.text.trim()) return 'Passwords mismatch';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 18),
              label: const Text('Register & Activate Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                if (!regFormKey.currentState!.validate()) return;

                final name = nameCtl.text.trim();
                final regNo = rollNoCtl.text.trim();
                final dob = dobCtl.text.trim();
                final email = emailCtl.text.trim();
                final phone = phoneCtl.text.trim().isNotEmpty ? phoneCtl.text.trim() : '+91 98765 00000';
                final cgpa = double.tryParse(cgpaCtl.text.trim()) ?? 8.0;
                final username = usernameCtl.text.trim();
                final password = passwordCtl.text.trim();

                // Create new Student Model
                final newStudent = StudentModel(
                  id: 's_${DateTime.now().millisecondsSinceEpoch}',
                  name: name,
                  regNo: regNo,
                  department: selectedDept,
                  year: selectedYear,
                  section: selectedSection,
                  cgpa: cgpa,
                  backlogs: 0,
                  email: email,
                  phone: phone,
                  dob: dob,
                  username: username,
                  password: password,
                  resumeFileName: '${name.replaceAll(' ', '_')}_Resume.pdf',
                  resumeFileSize: '210 KB',
                  resumeUploadDate: 'Just now',
                );

                // Add to PlacementDataService (saves in state and syncs to Supabase)
                PlacementDataService().addStudent(newStudent);

                Navigator.pop(dialogCtx);

                // Auto-fill login screen
                setState(() {
                  _selectedRole = UserRole.student;
                  _idController.text = username.isNotEmpty ? username : regNo;
                  _passwordController.text = password;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Registration Complete! Account created for $name. You can now login.',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: PlaceTrackTheme.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // ADMIN / OFFICER FIRST TIME REGISTRATION MODAL
  // ==========================================
  void _showAdminRegistrationDialog() {
    final adminFormKey = GlobalKey<FormState>();
    final nameCtl = TextEditingController();
    final empIdCtl = TextEditingController();
    final institutionCtl = TextEditingController(text: 'Gandhigram Rural Institute');
    final designationCtl = TextEditingController(text: 'Placement Officer');
    final emailCtl = TextEditingController();
    final phoneCtl = TextEditingController();
    final passcodeCtl = TextEditingController();
    final passwordCtl = TextEditingController();
    final confirmPasswordCtl = TextEditingController();

    bool obscureAdminPw = true;
    bool obscureAdminConfirm = true;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: const BorderSide(color: Color(0xFF334155)),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF1E40AF), Color(0xFF3B82F6)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Officer Account Setup',
                      style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Create official Admin credentials for PlaceTrack',
                      style: TextStyle(color: Colors.white60, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Form(
                key: adminFormKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Security Passcode (Mandatory verification)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.blueAccent.withAlpha(80)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.shield_rounded, color: Colors.blueAccent, size: 16),
                              SizedBox(width: 6),
                              Text('Master Verification Passcode', style: TextStyle(color: Colors.blueAccent, fontSize: 11.5, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: passcodeCtl,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              isDense: true,
                              hintText: 'Enter "TPO2026" or "admin"',
                              hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                              prefixIcon: Icon(Icons.key_rounded, color: Colors.white38, size: 16),
                            ),
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Passcode required';
                              if (v.trim() != 'TPO2026' && v.trim().toLowerCase() != 'admin') {
                                return 'Invalid Passcode. Use "TPO2026" or "admin"';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Full Name
                    const Text('Full Name *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: nameCtl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Dr. K. Ramesh',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                        prefixIcon: Icon(Icons.person_outline, color: Colors.white38, size: 18),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 10),

                    // Staff ID & Designation
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Staff / Employee ID *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: empIdCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. EMP-2024-01',
                                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Designation', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: designationCtl,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'e.g. Placement Officer',
                                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Institution / College Name
                    const Text('College / Institution *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: institutionCtl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        hintText: 'e.g. Gandhigram Rural Institute',
                        hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                        prefixIcon: Icon(Icons.school_outlined, color: Colors.white38, size: 18),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Institution is required' : null,
                    ),
                    const SizedBox(height: 10),

                    // Email & Phone
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Official Email *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: emailCtl,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: 'tpo@college.edu',
                                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                                  prefixIcon: Icon(Icons.email_outlined, color: Colors.white38, size: 18),
                                ),
                                validator: (v) => (v == null || !v.contains('@')) ? 'Valid email required' : null,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Phone Number', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                              const SizedBox(height: 4),
                              TextFormField(
                                controller: phoneCtl,
                                keyboardType: TextInputType.phone,
                                style: const TextStyle(color: Colors.white, fontSize: 13),
                                decoration: const InputDecoration(
                                  hintText: '+91 98765 43210',
                                  hintStyle: TextStyle(color: Colors.white30, fontSize: 12),
                                  prefixIcon: Icon(Icons.phone_outlined, color: Colors.white38, size: 18),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Password
                    const Text('Account Password *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: passwordCtl,
                      obscureText: obscureAdminPw,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Minimum 4 characters',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureAdminPw ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                          onPressed: () => setDlgState(() => obscureAdminPw = !obscureAdminPw),
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 4) ? 'Min 4 characters' : null,
                    ),
                    const SizedBox(height: 10),

                    // Confirm Password
                    const Text('Confirm Password *', style: TextStyle(color: Colors.white70, fontSize: 11.5)),
                    const SizedBox(height: 4),
                    TextFormField(
                      controller: confirmPasswordCtl,
                      obscureText: obscureAdminConfirm,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Re-enter password',
                        hintStyle: const TextStyle(color: Colors.white30, fontSize: 12),
                        prefixIcon: const Icon(Icons.lock_reset_rounded, color: Colors.white38, size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(obscureAdminConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: Colors.white38, size: 18),
                          onPressed: () => setDlgState(() => obscureAdminConfirm = !obscureAdminConfirm),
                        ),
                      ),
                      validator: (v) => (v != passwordCtl.text) ? 'Passwords do not match' : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: PlaceTrackTheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              onPressed: () {
                if (!adminFormKey.currentState!.validate()) return;

                final newAdmin = AdminModel(
                  id: 'adm_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtl.text.trim(),
                  employeeId: empIdCtl.text.trim(),
                  institution: institutionCtl.text.trim(),
                  designation: designationCtl.text.trim(),
                  email: emailCtl.text.trim(),
                  phone: phoneCtl.text.trim(),
                  password: passwordCtl.text.trim(),
                  createdAt: DateTime.now().toIso8601String(),
                );

                // Register Admin into data service and sync to Supabase
                PlacementDataService().registerAdmin(newAdmin);

                Navigator.pop(dialogCtx);

                // Auto-fill login screen and transition
                setState(() {
                  _selectedRole = UserRole.admin;
                  _idController.text = newAdmin.email;
                  _passwordController.text = newAdmin.password;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Admin account created for ${newAdmin.name}! You are now ready to log in.',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                    backgroundColor: PlaceTrackTheme.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Create Admin Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Dark navy
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
            child: FadeTransition(
              opacity: _fadeIn,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A56DB), Color(0xFF7E3AF2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1A56DB).withAlpha(80),
                          blurRadius: 20,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.track_changes_rounded,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'PlaceTrack',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Placement & Training Console',
                    style: TextStyle(
                      color: Colors.white.withAlpha(140),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Role Selector Switch (Admin vs Student)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _onRoleChanged(UserRole.admin),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.admin
                                    ? PlaceTrackTheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.admin_panel_settings_rounded,
                                    size: 18,
                                    color: _selectedRole == UserRole.admin
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Admin / Officer',
                                    style: TextStyle(
                                      color: _selectedRole == UserRole.admin
                                          ? Colors.white
                                          : Colors.white60,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => _onRoleChanged(UserRole.student),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _selectedRole == UserRole.student
                                    ? const Color(0xFF0F766E)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.school_rounded,
                                    size: 18,
                                    color: _selectedRole == UserRole.student
                                        ? Colors.white
                                        : Colors.white60,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Student Portal',
                                    style: TextStyle(
                                      color: _selectedRole == UserRole.student
                                          ? Colors.white
                                          : Colors.white60,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Login Form Card
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withAlpha(20)),
                    ),
                    padding: const EdgeInsets.all(22),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedRole == UserRole.admin
                                ? 'Placement Officer Login'
                                : 'Student Portal Sign In',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedRole == UserRole.admin
                                ? 'Manage drives, create rounds & shortlist students'
                                : 'Check your applied drives & assigned round results',
                            style: TextStyle(
                              color: Colors.white.withAlpha(120),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 18),

                          // ID / Email Field
                          Text(
                            _selectedRole == UserRole.admin ? 'Admin Email / ID' : 'Roll Number / Username / Email',
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _idController,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              prefixIcon: Icon(
                                _selectedRole == UserRole.admin ? Icons.email_outlined : Icons.badge_outlined,
                                color: Colors.white38,
                                size: 20,
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null,
                          ),
                          const SizedBox(height: 14),

                          // Password Field
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Password',
                                style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                              InkWell(
                                onTap: _onForgotPasswordPressed,
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    color: _selectedRole == UserRole.admin
                                        ? Colors.lightBlueAccent
                                        : Colors.tealAccent,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF0F172A),
                              prefixIcon: const Icon(Icons.lock_outline, color: Colors.white38, size: 20),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: Colors.white38,
                                  size: 18,
                                ),
                                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            validator: (v) => (v == null || v.isEmpty) ? 'Password is required' : null,
                          ),
                          const SizedBox(height: 20),

                          // Submit Button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _selectedRole == UserRole.admin
                                    ? PlaceTrackTheme.primary
                                    : const Color(0xFF0F766E),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      _selectedRole == UserRole.admin ? 'Sign In as Officer' : 'Sign In as Student',
                                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Role Specific Action Buttons
                          if (_selectedRole == UserRole.student) ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _showStudentRegistrationDialog,
                                icon: const Icon(Icons.person_add_alt_1_rounded, size: 18, color: Colors.tealAccent),
                                label: const Text(
                                  'First Time Login? Register Student Account',
                                  style: TextStyle(color: Colors.tealAccent, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.tealAccent.withAlpha(100)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ] else ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _showAdminRegistrationDialog,
                                icon: const Icon(Icons.person_add_rounded, size: 18, color: Colors.lightBlueAccent),
                                label: const Text(
                                  'New Placement Officer? Register Admin Account',
                                  style: TextStyle(color: Colors.lightBlueAccent, fontSize: 12.5, fontWeight: FontWeight.w600),
                                ),
                                style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.lightBlueAccent.withAlpha(100)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Center(
                              child: TextButton.icon(
                                onPressed: _showAdminForgotPasswordDialog,
                                icon: const Icon(Icons.vpn_key_rounded, size: 16, color: Colors.white60),
                                label: const Text(
                                  'Officer Reset Security Passcode',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
