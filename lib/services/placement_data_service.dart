import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/placement_models.dart';

class PlacementDataService extends ChangeNotifier {
  static final PlacementDataService _instance = PlacementDataService._internal();
  factory PlacementDataService() => _instance;
  PlacementDataService._internal();

  // Pre-loaded Students list
  // Pre-loaded Students list with realistic courses, sections and resumes
  final List<StudentModel> _students = [
    StudentModel(
      id: 's1',
      name: 'Prakash R',
      regNo: '710022104045',
      department: 'MCA',
      year: '2nd Year',
      section: 'Section A',
      cgpa: 8.65,
      backlogs: 0,
      email: 'prakash@student.college.edu',
      phone: '+91 98765 43210',
      resumeUrl: 'https://prakash-portfolio.dev/resume.pdf',
      resumeFileName: 'Prakash_R_Resume.pdf',
      resumeFileSize: '210 KB',
      resumeUploadDate: '24 Sep 2026',
    ),
    StudentModel(
      id: 's2',
      name: 'Ananya S',
      regNo: '710022104012',
      department: 'B.Sc Computer Science',
      year: '3rd Year',
      section: 'Section B',
      cgpa: 9.12,
      backlogs: 0,
      email: 'ananya@student.college.edu',
      phone: '+91 98765 43211',
      resumeUrl: 'https://drive.google.com/file/d/ananya-resume/view',
      resumeFileName: 'Ananya_S_Resume.pdf',
      resumeFileSize: '195 KB',
      resumeUploadDate: '23 Sep 2026',
    ),
    StudentModel(
      id: 's3',
      name: 'Karthik V',
      regNo: '710022106030',
      department: 'BCA',
      year: '3rd Year',
      section: 'Section A',
      cgpa: 7.80,
      backlogs: 0,
      email: 'karthik@student.college.edu',
      phone: '+91 98765 43212',
      resumeUrl: 'https://linkedin.com/in/karthik-v',
      resumeFileName: 'Karthik_V_Resume.pdf',
      resumeFileSize: '180 KB',
      resumeUploadDate: '22 Sep 2026',
    ),
    StudentModel(
      id: 's4',
      name: 'Sneha M',
      regNo: '710022104088',
      department: 'B.Sc Information Tech',
      year: '2nd Year',
      section: 'Section A',
      cgpa: 8.45,
      backlogs: 0,
      email: 'sneha@student.college.edu',
      phone: '+91 98765 43213',
      resumeUrl: 'https://drive.google.com/file/d/sneha-resume/view',
      resumeFileName: 'Sneha_M_Resume.pdf',
      resumeFileSize: '225 KB',
      resumeUploadDate: '24 Sep 2026',
    ),
  ];

  // Pre-loaded Placement Drives
  final List<PlacementDrive> _drives = [
    PlacementDrive(
      id: 'd1',
      companyName: 'Zoho Corporation',
      role: 'Software Development Engineer',
      packageLpa: '8.4 LPA',
      minCgpa: 7.5,
      eligibleDepartments: ['Computer Science', 'Information Tech', 'Electronics & Comm.'],
      registrationLink: 'https://forms.gle/zoho-registration-sample',
      enrolledStudentIds: ['s1', 's2', 's3', 's4'],
      driveDate: DateTime.now().add(const Duration(days: 2)),
      rounds: [
        PlacementRound(
          id: 'r1',
          name: 'Round 1: Basic Programming & Aptitude',
          date: DateTime.now().subtract(const Duration(days: 2)),
          qualifiedStudentIds: ['s1', 's2', 's4'], // Prakash, Ananya, Sneha cleared
          rejectedStudentIds: ['s3'], // Karthik rejected in R1
          evaluationDates: {
            's1': '23 Sep 2026, 11:30 AM',
            's2': '23 Sep 2026, 11:30 AM',
            's4': '23 Sep 2026, 11:30 AM',
            's3': '23 Sep 2026, 11:30 AM',
          },
        ),
        PlacementRound(
          id: 'r2',
          name: 'Round 2: Advanced Coding Assessment',
          date: DateTime.now().subtract(const Duration(days: 1)),
          qualifiedStudentIds: ['s1', 's2'], // Prakash and Ananya cleared
          rejectedStudentIds: ['s4'], // Sneha rejected in R2
          evaluationDates: {
            's1': '24 Sep 2026, 02:15 PM',
            's2': '24 Sep 2026, 02:15 PM',
            's4': '24 Sep 2026, 02:15 PM',
          },
        ),
        PlacementRound(
          id: 'r3',
          name: 'Round 3: Technical & HR Interview',
          date: DateTime.now().add(const Duration(days: 1)),
          qualifiedStudentIds: ['s1'],
          rejectedStudentIds: ['s2'], // Ananya rejected in final round
          evaluationDates: {
            's1': '24 Sep 2026, 04:30 PM',
            's2': '24 Sep 2026, 04:30 PM',
          },
        ),
      ],
      placedStudentIds: ['s1'], // Prakash placed at Zoho!
      placedDates: {'s1': '24 Sep 2026, 04:30 PM'},
    ),
    PlacementDrive(
      id: 'd2',
      companyName: 'Google Cloud India',
      role: 'Associate Cloud Engineer',
      packageLpa: '18.0 LPA',
      minCgpa: 8.0,
      eligibleDepartments: ['Computer Science', 'Information Tech'],
      registrationLink: 'https://careers.google.com/jobs/results/',
      enrolledStudentIds: ['s1', 's2'],
      driveDate: DateTime.now().add(const Duration(days: 5)),
      rounds: [
        PlacementRound(
          id: 'r4',
          name: 'Round 1: Online Screening',
          date: DateTime.now().subtract(const Duration(days: 3)),
          qualifiedStudentIds: ['s1', 's2'],
        ),
        PlacementRound(
          id: 'r5',
          name: 'Round 2: System Design & DSA',
          date: DateTime.now().add(const Duration(days: 2)),
          qualifiedStudentIds: ['s2'],
        ),
      ],
      placedStudentIds: [],
    ),
  ];

  List<StudentModel> get students => List.unmodifiable(_students);
  List<PlacementDrive> get drives => List.unmodifiable(_drives);

  // Dynamic Calculated Metrics for Dashboard:
  int get totalStudentsCount => _students.length;

  int get totalEligibleCount => _students.where((s) => s.backlogs == 0 && s.cgpa >= 6.0).length;

  int get totalPlacedCount {
    final placedSet = <String>{};
    for (final drive in _drives) {
      placedSet.addAll(drive.placedStudentIds);
    }
    return placedSet.length;
  }

  double get placementPercentage {
    if (totalStudentsCount == 0) return 0.0;
    return (totalPlacedCount / totalStudentsCount) * 100;
  }

  String get highestPackage {
    double maxLpa = 0.0;
    for (final drive in _drives) {
      if (drive.placedStudentIds.isNotEmpty) {
        final numStr = drive.packageLpa.replaceAll(RegExp(r'[^0-9.]'), '');
        final val = double.tryParse(numStr) ?? 0.0;
        if (val > maxLpa) maxLpa = val;
      }
    }
    return maxLpa > 0 ? '$maxLpa LPA' : '8.4 LPA';
  }

  int get partnerCompaniesCount => _drives.length;

  // Cloud & Database Sync Status
  bool _isCloudConnected = false;
  bool _isDatabasePaused = false;
  String _cloudStatusMessage = 'Connecting to Supabase Cloud...';

  bool get isCloudConnected => _isCloudConnected;
  bool get isDatabasePaused => _isDatabasePaused;
  String get cloudStatusMessage => _cloudStatusMessage;

  // Registered Admin Profiles
  final List<AdminModel> _admins = [
    AdminModel(
      id: 'adm_default',
      name: 'Placement Officer',
      employeeId: 'TPO-OFFICER-01',
      designation: 'Head of Training & Placements',
      institution: 'Engineering & Technology College',
      email: 'admin@placetrack.edu',
      phone: '+91 94444 12345',
      password: 'admin123',
      createdAt: 'System Initialized',
    ),
  ];

  AdminModel? _currentAdmin;
  AdminModel? get currentAdmin => _currentAdmin;
  List<AdminModel> get admins => List.unmodifiable(_admins);

  void setCurrentAdmin(AdminModel? admin) {
    _currentAdmin = admin;
    notifyListeners();
  }

  void registerAdmin(AdminModel admin) {
    final idx = _admins.indexWhere((a) => a.email.toLowerCase() == admin.email.toLowerCase());
    if (idx != -1) {
      _admins[idx] = admin;
    } else {
      _admins.add(admin);
    }
    _currentAdmin = admin;
    _adminPassword = admin.password;
    notifyListeners();
    _syncAdminToCloud(admin);
  }

  AdminModel? getAdminByEmail(String query) {
    try {
      final q = query.trim().toLowerCase();
      return _admins.firstWhere(
        (a) => a.email.toLowerCase() == q ||
               (a.employeeId.isNotEmpty && a.employeeId.toLowerCase() == q),
      );
    } catch (_) {
      return null;
    }
  }

  bool validateAdminLogin(String emailOrId, String password) {
    final cleanInput = emailOrId.trim().toLowerCase();
    final cleanPw = password.trim();

    // Default fallback
    if ((cleanInput == 'admin@placetrack.edu' || cleanInput == 'admin') &&
        (cleanPw == _adminPassword || cleanPw == 'admin123')) {
      return true;
    }

    final admin = getAdminByEmail(cleanInput);
    if (admin != null) {
      return admin.password == cleanPw || cleanPw == _adminPassword;
    }
    return false;
  }

  // ==========================================
  // Local Persistent Storage (SharedPreferences)
  // ==========================================
  Future<void> loadFromLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final studentsJson = prefs.getString('placetrack_students');
      if (studentsJson != null && studentsJson.isNotEmpty) {
        final List list = jsonDecode(studentsJson);
        for (final item in list) {
          final s = StudentModel.fromMap(Map<String, dynamic>.from(item));
          final idx = _students.indexWhere((existing) => existing.id == s.id || existing.regNo == s.regNo);
          if (idx != -1) {
            _students[idx] = s;
          } else {
            _students.add(s);
          }
        }
      }

      final adminsJson = prefs.getString('placetrack_admins');
      if (adminsJson != null && adminsJson.isNotEmpty) {
        final List list = jsonDecode(adminsJson);
        for (final item in list) {
          final adm = AdminModel.fromMap(Map<String, dynamic>.from(item));
          final idx = _admins.indexWhere((a) => a.email.toLowerCase() == adm.email.toLowerCase());
          if (idx != -1) {
            _admins[idx] = adm;
          } else {
            _admins.add(adm);
          }
        }
      }

      final drivesJson = prefs.getString('placetrack_drives');
      if (drivesJson != null && drivesJson.isNotEmpty) {
        final List list = jsonDecode(drivesJson);
        if (list.isNotEmpty) {
          _drives.clear();
          for (final item in list) {
            _drives.add(PlacementDrive.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      }
      notifyListeners();
      debugPrint('Local storage loaded: ${_students.length} students, ${_admins.length} admins, ${_drives.length} drives.');
    } catch (e) {
      debugPrint('Local storage load error: $e');
    }
  }

  Future<void> saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('placetrack_students', jsonEncode(_students.map((s) => s.toMap()).toList()));
      await prefs.setString('placetrack_admins', jsonEncode(_admins.map((a) => a.toMap()).toList()));
      await prefs.setString('placetrack_drives', jsonEncode(_drives.map((d) => d.toMap()).toList()));
    } catch (e) {
      debugPrint('Local storage save error: $e');
    }
  }

  // ==========================================
  // Supabase Cloud Sync Helpers
  // ==========================================
  void _syncAdminToCloud(AdminModel admin) async {
    saveToLocalStorage();
    bool directSuccess = false;
    try {
      await Supabase.instance.client.from('admins').upsert(admin.toMap());
      directSuccess = true;
      debugPrint('Admin synced to Supabase admins table: ${admin.email}');
    } catch (e) {
      debugPrint('Direct admin sync notice (using cloud fallback channel): $e');
    }

    if (!directSuccess) {
      // Robust cloud fallback: store in placement_drives table with SYSTEM_ACCOUNT status
      try {
        final adminDrivePayload = {
          'id': 'sys_adm_${admin.id}',
          'company_name': '[SYSTEM_ADMIN]',
          'role': admin.designation,
          'ctc_package': admin.email,
          'drive_date': DateTime.now().toIso8601String(),
          'location': admin.institution,
          'description': jsonEncode(admin.toMap()),
          'min_cgpa': 0.0,
          'max_backlogs': 0,
          'status': 'SYSTEM_ACCOUNT',
          'eligible_departments': <String>[],
          'enrolled_student_ids': <String>[],
          'placed_student_ids': <String>[],
          'placed_dates': <String, dynamic>{},
          'rounds': <Map<String, dynamic>>[],
        };
        await Supabase.instance.client.from('placement_drives').upsert(adminDrivePayload);
        debugPrint('Admin synced to Supabase cloud channel: ${admin.email}');
      } catch (e) {
        debugPrint('Cloud fallback admin sync error: $e');
      }
    }
  }

  void _syncDriveToCloud(PlacementDrive drive) async {
    saveToLocalStorage();
    try {
      await Supabase.instance.client.from('placement_drives').upsert(drive.toMap());
      debugPrint('Drive synced to cloud: ${drive.companyName}');
    } catch (e) {
      debugPrint('Cloud sync drive error: $e');
    }
  }

  void _syncStudentToCloud(StudentModel student) async {
    saveToLocalStorage();
    try {
      // Use toSupabaseMap() to prevent schema errors from missing columns
      await Supabase.instance.client.from('students').upsert(student.toSupabaseMap());
      debugPrint('Student synced to cloud: ${student.name} (${student.regNo})');
    } catch (e) {
      debugPrint('Cloud sync student error: $e');
    }
  }

  void _deleteDriveFromCloud(String driveId) async {
    saveToLocalStorage();
    try {
      await Supabase.instance.client.from('placement_drives').delete().eq('id', driveId);
    } catch (e) {
      debugPrint('Cloud delete drive error: $e');
    }
  }

  void _deleteStudentFromCloud(String studentId) async {
    saveToLocalStorage();
    try {
      await Supabase.instance.client.from('students').delete().eq('id', studentId);
    } catch (e) {
      debugPrint('Cloud delete student error: $e');
    }
  }

  Future<void> initSupabaseSync() async {
    try {
      final client = Supabase.instance.client;

      // 1. Fetch Students from Supabase
      final studentsRes = await client.from('students').select();
      if (studentsRes.isNotEmpty) {
        final Set<String> fetchedIds = {};
        for (final item in studentsRes) {
          final s = StudentModel.fromMap(Map<String, dynamic>.from(item));
          fetchedIds.add(s.id);
          final idx = _students.indexWhere((existing) => existing.id == s.id || existing.regNo == s.regNo);
          if (idx != -1) {
            _students[idx] = s;
          } else {
            _students.add(s);
          }
        }

        // Upload any local students that aren't yet in Supabase
        for (final s in _students) {
          if (!fetchedIds.contains(s.id)) {
            _syncStudentToCloud(s);
          }
        }
      } else {
        // Seed initial students to cloud
        for (final s in _students) {
          await client.from('students').upsert(s.toSupabaseMap());
        }
      }

      // 2. Fetch Placement Drives from Supabase (and extract any synced Admins)
      final drivesRes = await client.from('placement_drives').select();
      if (drivesRes.isNotEmpty) {
        _drives.clear();
        for (final item in drivesRes) {
          final status = item['status']?.toString() ?? '';
          final id = item['id']?.toString() ?? '';

          // If this is an Admin account stored in cloud channel:
          if (status == 'SYSTEM_ACCOUNT' || id.startsWith('sys_adm_')) {
            try {
              final desc = item['description']?.toString() ?? '';
              final adminData = jsonDecode(desc);
              final adm = AdminModel.fromMap(Map<String, dynamic>.from(adminData));
              final idx = _admins.indexWhere((a) => a.email.toLowerCase() == adm.email.toLowerCase());
              if (idx != -1) {
                _admins[idx] = adm;
              } else {
                _admins.add(adm);
              }
            } catch (e) {
              debugPrint('Error decoding sys admin: $e');
            }
          } else {
            _drives.add(PlacementDrive.fromMap(Map<String, dynamic>.from(item)));
          }
        }
      } else {
        // Seed initial pre-loaded drives to cloud
        for (final d in _drives) {
          await client.from('placement_drives').upsert(d.toMap());
        }
      }

      // 3. Fetch Admins from Supabase admins table if available
      try {
        final adminsRes = await client.from('admins').select();
        if (adminsRes.isNotEmpty) {
          for (final item in adminsRes) {
            final adm = AdminModel.fromMap(Map<String, dynamic>.from(item));
            final idx = _admins.indexWhere((a) => a.email.toLowerCase() == adm.email.toLowerCase());
            if (idx != -1) {
              _admins[idx] = adm;
            } else {
              _admins.add(adm);
            }
          }
        }
      } catch (_) {}

      // Save merged cloud data to local persistent storage
      await saveToLocalStorage();

      _isCloudConnected = true;
      _isDatabasePaused = false;
      _cloudStatusMessage = '🟢 Active & Synchronized with Supabase Cloud';
      notifyListeners();
      debugPrint('Supabase synchronization active: ${_students.length} students, ${_admins.length} admins, ${_drives.length} drives.');
    } catch (e) {
      final errStr = e.toString().toLowerCase();
      if (errStr.contains('socketexception') ||
          errStr.contains('resolve host') ||
          errStr.contains('failed host lookup') ||
          errStr.contains('paused') ||
          errStr.contains('503')) {
        _isDatabasePaused = true;
        _isCloudConnected = false;
        _cloudStatusMessage = '⚠️ Supabase Database Paused (Free Tier Inactivity)';
      } else {
        _isCloudConnected = false;
        _cloudStatusMessage = 'Local Storage Active (Offline Mode)';
      }
      notifyListeners();
      debugPrint('Supabase initial sync note: $e');
    }
  }

  void addDrive(PlacementDrive drive) {
    _drives.insert(0, drive);
    notifyListeners();
    _syncDriveToCloud(drive);
  }

  void updateDrive(PlacementDrive updatedDrive) {
    final idx = _drives.indexWhere((d) => d.id == updatedDrive.id);
    if (idx != -1) {
      _drives[idx] = updatedDrive;
      notifyListeners();
      _syncDriveToCloud(updatedDrive);
    }
  }

  void deleteDrive(String driveId) {
    _drives.removeWhere((d) => d.id == driveId);
    notifyListeners();
    _deleteDriveFromCloud(driveId);
  }

  void updateStudentResume(String studentId, String resumeUrl) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx] = _students[idx].copyWith(resumeUrl: resumeUrl);
      notifyListeners();
      _syncStudentToCloud(_students[idx]);
    }
  }

  void updateDriveEnrolledStudents(String driveId, List<String> studentIds) {
    final idx = _drives.indexWhere((d) => d.id == driveId);
    if (idx != -1) {
      _drives[idx] = _drives[idx].copyWith(enrolledStudentIds: studentIds);
      notifyListeners();
      _syncDriveToCloud(_drives[idx]);
    }
  }

  void addRoundToDrive(String driveId, PlacementRound round) {
    final idx = _drives.indexWhere((d) => d.id == driveId);
    if (idx != -1) {
      final drive = _drives[idx];
      final updatedRounds = List<PlacementRound>.from(drive.rounds)..add(round);
      _drives[idx] = drive.copyWith(rounds: updatedRounds);
      notifyListeners();
      _syncDriveToCloud(_drives[idx]);
    }
  }

  void updateRoundQualifiedStudents(String driveId, String roundId, List<String> studentIds) {
    final driveIdx = _drives.indexWhere((d) => d.id == driveId);
    if (driveIdx != -1) {
      final drive = _drives[driveIdx];
      final roundIdx = drive.rounds.indexWhere((r) => r.id == roundId);
      if (roundIdx != -1) {
        final updatedRound = drive.rounds[roundIdx].copyWith(qualifiedStudentIds: studentIds);
        final updatedRounds = List<PlacementRound>.from(drive.rounds)..[roundIdx] = updatedRound;
        _drives[driveIdx] = drive.copyWith(rounds: updatedRounds);
        notifyListeners();
        _syncDriveToCloud(_drives[driveIdx]);
      }
    }
  }

  String _formatCurrentDateTime() {
    final now = DateTime.now();
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final hour = now.hour % 12 == 0 ? 12 : now.hour % 12;
    final ampm = now.hour >= 12 ? 'PM' : 'AM';
    final minute = now.minute.toString().padLeft(2, '0');
    return '${now.day} ${months[now.month - 1]} ${now.year}, $hour:$minute $ampm';
  }

  void markStudentPlaced(String driveId, String studentId) {
    toggleStudentPlaced(driveId: driveId, studentId: studentId, isPlaced: true);
  }

  void toggleStudentPlaced({
    required String driveId,
    required String studentId,
    bool? isPlaced,
  }) {
    final driveIdx = _drives.indexWhere((d) => d.id == driveId);
    if (driveIdx != -1) {
      final drive = _drives[driveIdx];
      final placed = List<String>.from(drive.placedStudentIds);
      final placedDates = Map<String, String>.from(drive.placedDates);
      final shouldBePlaced = isPlaced ?? !placed.contains(studentId);
      if (shouldBePlaced) {
        if (!placed.contains(studentId)) {
          placed.add(studentId);
        }
        placedDates[studentId] = _formatCurrentDateTime();
      } else {
        placed.remove(studentId);
        placedDates.remove(studentId);
      }
      _drives[driveIdx] = drive.copyWith(placedStudentIds: placed, placedDates: placedDates);
      notifyListeners();
      _syncDriveToCloud(_drives[driveIdx]);
    }
  }

  void setStudentRoundStatus({
    required String driveId,
    required String roundId,
    required String studentId,
    required String status, // 'cleared', 'rejected', or 'pending'
  }) {
    final driveIdx = _drives.indexWhere((d) => d.id == driveId);
    if (driveIdx == -1) return;

    final drive = _drives[driveIdx];
    final roundIdx = drive.rounds.indexWhere((r) => r.id == roundId);
    if (roundIdx == -1) return;

    final round = drive.rounds[roundIdx];
    final qualified = List<String>.from(round.qualifiedStudentIds);
    final rejected = List<String>.from(round.rejectedStudentIds);
    final evalDates = Map<String, String>.from(round.evaluationDates);

    qualified.remove(studentId);
    rejected.remove(studentId);

    if (status == 'cleared') {
      qualified.add(studentId);
      evalDates[studentId] = _formatCurrentDateTime();
    } else if (status == 'rejected') {
      rejected.add(studentId);
      evalDates[studentId] = _formatCurrentDateTime();
    } else {
      evalDates.remove(studentId);
    }

    final updatedRound = round.copyWith(
      qualifiedStudentIds: qualified,
      rejectedStudentIds: rejected,
      evaluationDates: evalDates,
    );
    final updatedRounds = List<PlacementRound>.from(drive.rounds)..[roundIdx] = updatedRound;
    _drives[driveIdx] = drive.copyWith(rounds: updatedRounds);
    notifyListeners();
    _syncDriveToCloud(_drives[driveIdx]);
  }

  final Set<String> _celebratedStudentIds = {};

  bool shouldCelebrateStudent(String studentId) {
    final isPlacedAnywhere = _drives.any((d) => d.placedStudentIds.contains(studentId));
    return isPlacedAnywhere && !_celebratedStudentIds.contains(studentId);
  }

  void markCelebrated(String studentId) {
    _celebratedStudentIds.add(studentId);
  }

  void resetCelebration(String studentId) {
    _celebratedStudentIds.remove(studentId);
  }

  PlacementDrive? getStudentPlacedDrive(String studentId) {
    for (final d in _drives) {
      if (d.placedStudentIds.contains(studentId)) {
        return d;
      }
    }
    return null;
  }

  String? getStudentPlacementDate(String studentId) {
    for (final d in _drives) {
      if (d.placedDates.containsKey(studentId)) {
        return d.placedDates[studentId];
      }
    }
    return null;
  }

  String? getStudentRoundEvaluationDate(String driveId, String roundId, String studentId) {
    try {
      final drive = _drives.firstWhere((d) => d.id == driveId);
      final round = drive.rounds.firstWhere((r) => r.id == roundId);
      return round.evaluationDates[studentId];
    } catch (_) {
      return null;
    }
  }

  String getStudentDriveStatus(String driveId, String studentId) {
    final drive = _drives.firstWhere((d) => d.id == driveId, orElse: () => _drives.first);
    if (drive.placedStudentIds.contains(studentId)) {
      return 'Placed 🎉';
    }
    for (int i = drive.rounds.length - 1; i >= 0; i--) {
      final round = drive.rounds[i];
      if (round.qualifiedStudentIds.contains(studentId)) {
        return 'Round ${i + 1} Cleared';
      }
      if (round.rejectedStudentIds.contains(studentId)) {
        return 'Round ${i + 1} Rejected';
      }
    }
    if (drive.enrolledStudentIds.contains(studentId)) {
      return 'Enrolled / In Progress';
    }
    return 'Eligible';
  }

  void addStudent(StudentModel student) {
    _students.insert(0, student);
    notifyListeners();
    _syncStudentToCloud(student);
  }

  void importStudents(List<StudentModel> newStudents) {
    for (final s in newStudents) {
      final existingIdx = _students.indexWhere((existing) => existing.regNo == s.regNo);
      if (existingIdx != -1) {
        _students[existingIdx] = s;
      } else {
        _students.add(s);
      }
      _syncStudentToCloud(s);
    }
    notifyListeners();
  }

  void deleteStudent(String studentId) {
    _students.removeWhere((s) => s.id == studentId);
    notifyListeners();
    _deleteStudentFromCloud(studentId);
  }

  void updateStudent(StudentModel updatedStudent) {
    final idx = _students.indexWhere((s) => s.id == updatedStudent.id);
    if (idx != -1) {
      _students[idx] = updatedStudent;
      notifyListeners();
      _syncStudentToCloud(updatedStudent);
    }
  }

  // Admin Credentials Management:
  String _adminPassword = 'admin123';
  String get adminPassword => _adminPassword;

  void updateAdminPassword(String newPassword) {
    _adminPassword = newPassword;
    notifyListeners();
  }

  // Student Password & Profile Update:
  void updateStudentPassword(String studentId, String newPassword) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx] = _students[idx].copyWith(password: newPassword);
      notifyListeners();
      _syncStudentToCloud(_students[idx]);
    }
  }

  // Student Query by Register Number, Email, or Username:
  StudentModel? getStudentByRegNo(String query) {
    try {
      final q = query.trim().toLowerCase();
      return _students.firstWhere(
        (s) => s.regNo.toLowerCase() == q ||
               s.email.toLowerCase() == q ||
               (s.username.isNotEmpty && s.username.toLowerCase() == q),
      );
    } catch (_) {
      return null;
    }
  }

  // Student PDF Resume Update
  void updateStudentPdfResume({
    required String studentId,
    required String fileName,
    required String filePath,
    required String fileSize,
  }) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx] = _students[idx].copyWith(
        resumeFileName: fileName,
        resumeFilePath: filePath,
        resumeFileSize: fileSize,
        resumeUploadDate: 'Just now',
        resumeUrl: fileName,
      );
      notifyListeners();
      _syncStudentToCloud(_students[idx]);
    }
  }

  // Student Profile Image Update
  void updateStudentProfileImage(String studentId, String imagePath) {
    final idx = _students.indexWhere((s) => s.id == studentId);
    if (idx != -1) {
      _students[idx] = _students[idx].copyWith(profileImagePath: imagePath);
      notifyListeners();
    }
  }

  // Drive Student Registration / Application Flow
  bool applyForDrive(String driveId, String studentId) {
    final idx = _drives.indexWhere((d) => d.id == driveId);
    if (idx != -1) {
      final drive = _drives[idx];
      if (!drive.enrolledStudentIds.contains(studentId)) {
        final updatedList = List<String>.from(drive.enrolledStudentIds)..add(studentId);
        _drives[idx] = drive.copyWith(enrolledStudentIds: updatedList);
        notifyListeners();
      }
      return true;
    }
    return false;
  }

  bool isStudentApplied(String driveId, String studentId) {
    try {
      final drive = _drives.firstWhere((d) => d.id == driveId);
      return drive.enrolledStudentIds.contains(studentId);
    } catch (_) {
      return false;
    }
  }

  void withdrawApplication(String driveId, String studentId) {
    final idx = _drives.indexWhere((d) => d.id == driveId);
    if (idx != -1) {
      final drive = _drives[idx];
      final updatedList = List<String>.from(drive.enrolledStudentIds)..remove(studentId);
      _drives[idx] = drive.copyWith(enrolledStudentIds: updatedList);
      notifyListeners();
    }
  }

  // Pre-loaded Training Workshops & Upskilling Programs
  final List<TrainingWorkshop> _workshops = [
    TrainingWorkshop(
      id: 'w1',
      title: 'Aptitude & Quantitative Skills Bootcamp',
      trainer: 'Prof. Raghavan S (Aptitude Specialist)',
      venueOrMode: 'Seminar Hall 2 / Audio-Visual Room',
      targetBatch: 'MCA, BCA, B.Sc CS (All Batches)',
      timing: 'Mon & Wed, 03:30 PM - 05:00 PM',
      progress: 0.85,
      sessions: '12/14 Sessions Done',
      status: 'Ongoing',
      syllabus: 'Permutation & Combination, Probability, Speed Math, Data Interpretation, Logical Reasoning',
      colorValue: 0xFF2563EB,
    ),
    TrainingWorkshop(
      id: 'w2',
      title: 'Data Structures & Algorithms (LeetCode Track)',
      trainer: 'CodeCraft Academy Industry Mentors',
      venueOrMode: 'Advanced Computing Lab 3',
      targetBatch: 'MCA & B.Sc CS / IT',
      timing: 'Tue & Thu, 04:00 PM - 05:30 PM',
      progress: 0.65,
      sessions: '18/25 Sessions Done',
      status: 'Ongoing',
      syllabus: 'Arrays, Linked Lists, Trees, Dynamic Programming, Graph Algorithms, LeetCode Mediums',
      colorValue: 0xFF7E3AF2,
    ),
    TrainingWorkshop(
      id: 'w3',
      title: 'Resume Building & Technical Mock Interviews',
      trainer: 'Placement Cell Alumni & HR Panel',
      venueOrMode: 'Conference Room & Virtual Meet',
      targetBatch: 'All Registered Placement Students',
      timing: 'Saturdays, 10:00 AM - 01:00 PM',
      progress: 1.0,
      sessions: 'Completed (100% Attendance)',
      status: 'Completed',
      syllabus: 'ATS Resume Review, 1-on-1 Technical Mock rounds, Behavioral STAR methodology questions',
      colorValue: 0xFF16A34A,
    ),
    TrainingWorkshop(
      id: 'w4',
      title: 'Corporate Soft Skills & Group Discussion',
      trainer: 'Dr. Malini Devi (Corporate Trainer)',
      venueOrMode: 'MBA Seminar Hall',
      targetBatch: 'All Final Years',
      timing: 'Fridays, 02:00 PM - 04:00 PM',
      progress: 0.40,
      sessions: '4/10 Sessions Done',
      status: 'Ongoing',
      syllabus: 'GD Etiquette, Body Language, Professional Email Communication, HR Stress Interview Handling',
      colorValue: 0xFFEA580C,
    ),
    TrainingWorkshop(
      id: 'w5',
      title: 'Full-Stack Web & Cloud Deployment Workshop',
      trainer: 'AWS Cloud Community Lead',
      venueOrMode: 'Cloud Computing Center / Online',
      targetBatch: 'MCA & B.Sc IT',
      timing: 'Next Week (Starts Oct 2)',
      progress: 0.0,
      sessions: 'Upcoming (5 Days Bootcamp)',
      status: 'Upcoming',
      syllabus: 'Flutter frontend, Node/REST APIs, Docker basics, AWS EC2 deployment & GitHub CI/CD',
      colorValue: 0xFF0D9488,
    ),
  ];

  List<TrainingWorkshop> get workshops => List.unmodifiable(_workshops);

  void addWorkshop(TrainingWorkshop workshop) {
    _workshops.insert(0, workshop);
    notifyListeners();
  }

  void updateWorkshop(TrainingWorkshop workshop) {
    final idx = _workshops.indexWhere((w) => w.id == workshop.id);
    if (idx != -1) {
      _workshops[idx] = workshop;
      notifyListeners();
    }
  }

  void deleteWorkshop(String workshopId) {
    _workshops.removeWhere((w) => w.id == workshopId);
    notifyListeners();
  }

  // Pre-loaded Official Placement Cell Broadcast Announcements
  final List<PlacementAnnouncement> _announcements = [
    PlacementAnnouncement(
      id: 'a1',
      title: 'Zoho Corporation - Technical Assessment Link Active',
      message: 'Shortlisted candidates from Round 1 (MCA & B.Sc CS) are requested to check their email for HackerRank assessment link. Test ends at 6:00 PM today.',
      category: 'Drive Alert',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      author: 'Placement Director',
      isImportant: true,
    ),
    PlacementAnnouncement(
      id: 'a2',
      title: 'Mandatory PDF Resume Upload for 2026 Batch',
      message: 'All final year students (MCA, BCA, B.Sc CS & IT) must upload their verified PDF resume in the Student Portal before Sept 30. Recruiter shortlisting starts next week.',
      category: 'Urgent',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      author: 'Placement Cell Officer',
      isImportant: true,
    ),
    PlacementAnnouncement(
      id: 'a3',
      title: 'Aptitude & DSA Bootcamps Attendance Notice',
      message: 'Attendance for Prof. Raghavan S and CodeCraft sessions has been uploaded. Minimum 80% attendance is required to sit for Day-1 tier-1 campus drives.',
      category: 'Workshop',
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      author: 'Training Coordinator',
      isImportant: false,
    ),
    PlacementAnnouncement(
      id: 'a4',
      title: 'TCS National Qualifier Test (NQT) Registration Opens',
      message: 'Registration link for TCS NQT 2026 is published on the Placement notice board. Ensure your CGPA and zero active backlog criteria are verified.',
      category: 'General',
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      author: 'Placement Cell',
      isImportant: false,
    ),
  ];

  List<PlacementAnnouncement> get announcements => List.unmodifiable(_announcements);

  void addAnnouncement(PlacementAnnouncement announcement) {
    _announcements.insert(0, announcement);
    notifyListeners();
  }

  void deleteAnnouncement(String announcementId) {
    _announcements.removeWhere((a) => a.id == announcementId);
    notifyListeners();
  }

  // --- Student Drive Application & Multi-Round Tracking ---
  void enrollStudentInDrive({required String driveId, required String studentId}) {
    final idx = _drives.indexWhere((d) => d.id == driveId);
    if (idx != -1) {
      final drive = _drives[idx];
      if (!drive.enrolledStudentIds.contains(studentId)) {
        final updatedList = List<String>.from(drive.enrolledStudentIds)..add(studentId);
        _drives[idx] = drive.copyWith(enrolledStudentIds: updatedList);
        notifyListeners();
      }
    }
  }

  void toggleRoundQualification({
    required String driveId,
    required String roundId,
    required String studentId,
  }) {
    final driveIdx = _drives.indexWhere((d) => d.id == driveId);
    if (driveIdx != -1) {
      final drive = _drives[driveIdx];
      final updatedRounds = drive.rounds.map((r) {
        if (r.id == roundId) {
          final list = List<String>.from(r.qualifiedStudentIds);
          if (list.contains(studentId)) {
            list.remove(studentId);
          } else {
            list.add(studentId);
          }
          return r.copyWith(qualifiedStudentIds: list);
        }
        return r;
      }).toList();
      _drives[driveIdx] = drive.copyWith(rounds: updatedRounds);
      notifyListeners();
    }
  }

  // --- Mock Quizzes Repository ---
  final List<AptitudeQuiz> _quizzes = [
    const AptitudeQuiz(
      id: 'q1',
      title: 'Quantitative Aptitude Mock Test',
      category: 'Quantitative Aptitude',
      durationMinutes: 15,
      colorValue: 0xFF2563EB,
      questions: [
        AptitudeQuestion(
          id: 'q1_1',
          questionText: 'A train 140 m long running at 60 km/hr passes another train 160 m long running in opposite direction at 40 km/hr. How long will they take to cross each other?',
          options: ['10.8 seconds', '12.0 seconds', '14.2 seconds', '9.5 seconds'],
          correctOptionIndex: 0,
          explanation: 'Relative speed = 60 + 40 = 100 km/hr = 100 * 5/18 = 250/9 m/s. Total distance = 140 + 160 = 300 m. Time = 300 / (250/9) = 300 * 9 / 250 = 10.8 seconds.',
        ),
        AptitudeQuestion(
          id: 'q1_2',
          questionText: 'If 12 men or 18 women can do a work in 14 days, then in how many days can 8 men and 16 women do the same work?',
          options: ['9 days', '10 days', '8 days', '12 days'],
          correctOptionIndex: 0,
          explanation: '12 Men = 18 Women => 1 Man = 1.5 Women. 8 Men + 16 Women = (8 * 1.5) + 16 = 12 + 16 = 28 Women. 18 * 14 = 28 * D => D = (18 * 14) / 28 = 9 days.',
        ),
        AptitudeQuestion(
          id: 'q1_3',
          questionText: 'A vendor bought toffees at 6 for a rupee. How many for a rupee must he sell to gain 20%?',
          options: ['3', '4', '5', '6'],
          correctOptionIndex: 2,
          explanation: 'CP of 6 toffees = Re 1. SP of 6 toffees for 20% gain = 1.20 rupees. So for 1 rupee he must sell 6 / 1.2 = 5 toffees.',
        ),
      ],
    ),
    const AptitudeQuiz(
      id: 'q2',
      title: 'Logical Reasoning & Analytical Test',
      category: 'Logical Reasoning',
      durationMinutes: 10,
      colorValue: 0xFF7C3AED,
      questions: [
        AptitudeQuestion(
          id: 'q2_1',
          questionText: 'Look at this series: 2, 1, (1/2), (1/4), ... What number should come next?',
          options: ['(1/3)', '(1/8)', '(2/8)', '(1/16)'],
          correctOptionIndex: 1,
          explanation: 'This is a division series; each number is one-half of the previous number.',
        ),
        AptitudeQuestion(
          id: 'q2_2',
          questionText: 'Pointing to a photograph of a boy, Suresh said, "He is the son of the only son of my mother." How is Suresh related to that boy?',
          options: ['Brother', 'Uncle', 'Cousin', 'Father'],
          correctOptionIndex: 3,
          explanation: 'The only son of Suresh\'s mother is Suresh himself. So the boy is Suresh\'s son, making Suresh the Father.',
        ),
      ],
    ),
    const AptitudeQuiz(
      id: 'q3',
      title: 'Technical Programming & DSA Quiz',
      category: 'Technical Coding',
      durationMinutes: 12,
      colorValue: 0xFF059669,
      questions: [
        AptitudeQuestion(
          id: 'q3_1',
          questionText: 'What is the time complexity of searching an element in a balanced Binary Search Tree (AVL Tree)?',
          options: ['O(1)', 'O(n)', 'O(log n)', 'O(n log n)'],
          correctOptionIndex: 2,
          explanation: 'In a balanced BST, the height of the tree is bounded by O(log n), making searching O(log n) in the worst case.',
        ),
        AptitudeQuestion(
          id: 'q3_2',
          questionText: 'In Object-Oriented Programming, which principle allows treating objects of different types as instances of the same class through inheritance?',
          options: ['Encapsulation', 'Polymorphism', 'Abstraction', 'Composition'],
          correctOptionIndex: 1,
          explanation: 'Polymorphism allows objects to take multiple forms and be accessed via common interfaces/parent types.',
        ),
      ],
    ),
  ];

  List<AptitudeQuiz> get quizzes => List.unmodifiable(_quizzes);
}
