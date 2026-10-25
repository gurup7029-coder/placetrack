enum UserRole { admin, student }

class AdminModel {
  final String id;
  final String name;
  final String employeeId;
  final String designation;
  final String institution;
  final String email;
  final String phone;
  final String password;
  final String createdAt;

  AdminModel({
    required this.id,
    required this.name,
    this.employeeId = '',
    this.designation = 'Placement Officer',
    this.institution = 'Engineering & Technology College',
    required this.email,
    this.phone = '',
    required this.password,
    this.createdAt = '',
  });

  AdminModel copyWith({
    String? id,
    String? name,
    String? employeeId,
    String? designation,
    String? institution,
    String? email,
    String? phone,
    String? password,
    String? createdAt,
  }) {
    return AdminModel(
      id: id ?? this.id,
      name: name ?? this.name,
      employeeId: employeeId ?? this.employeeId,
      designation: designation ?? this.designation,
      institution: institution ?? this.institution,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      password: password ?? this.password,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'employee_id': employeeId,
      'designation': designation,
      'institution': institution,
      'email': email,
      'phone': phone,
      'password': password,
      'created_at': createdAt,
    };
  }

  factory AdminModel.fromMap(Map<String, dynamic> map) {
    return AdminModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      employeeId: map['employee_id']?.toString() ?? '',
      designation: map['designation']?.toString() ?? 'Placement Officer',
      institution: map['institution']?.toString() ?? 'Engineering & Technology College',
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      password: map['password']?.toString() ?? 'admin123',
      createdAt: map['created_at']?.toString() ?? '',
    );
  }
}

class StudentModel {
  final String id;
  final String name;
  final String regNo;
  final String department; // e.g. "MCA", "B.Sc Computer Science", "BCA"
  final String year;       // e.g. "1st Year", "2nd Year", "3rd Year"
  final String section;    // e.g. "Section A", "Section B"
  final double cgpa;
  final int backlogs;
  final String email;
  final String phone;
  final String dob;              // Date of Birth, e.g. "15/05/2003"
  final String username;         // Custom User ID chosen by student
  final String password;         // Password set by student
  final String resumeUrl;        // Link / URL (optional)
  final String resumeFileName;   // e.g. "Prakash_R_Resume.pdf"
  final String resumeFilePath;   // Local PDF file path
  final String resumeFileSize;   // e.g. "245 KB"
  final String resumeUploadDate; // e.g. "24 Sep 2026"
  final String profileImagePath; // Local photo image path

  StudentModel({
    required this.id,
    required this.name,
    required this.regNo,
    required this.department,
    this.year = '2nd Year',
    this.section = 'Section A',
    required this.cgpa,
    this.backlogs = 0,
    required this.email,
    required this.phone,
    this.dob = '',
    this.username = '',
    this.password = 'student123',
    this.resumeUrl = '',
    this.resumeFileName = '',
    this.resumeFilePath = '',
    this.resumeFileSize = '',
    this.resumeUploadDate = '',
    this.profileImagePath = '',
  });

  StudentModel copyWith({
    String? id,
    String? name,
    String? regNo,
    String? department,
    String? year,
    String? section,
    double? cgpa,
    int? backlogs,
    String? email,
    String? phone,
    String? dob,
    String? username,
    String? password,
    String? resumeUrl,
    String? resumeFileName,
    String? resumeFilePath,
    String? resumeFileSize,
    String? resumeUploadDate,
    String? profileImagePath,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      regNo: regNo ?? this.regNo,
      department: department ?? this.department,
      year: year ?? this.year,
      section: section ?? this.section,
      cgpa: cgpa ?? this.cgpa,
      backlogs: backlogs ?? this.backlogs,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dob: dob ?? this.dob,
      username: username ?? this.username,
      password: password ?? this.password,
      resumeUrl: resumeUrl ?? this.resumeUrl,
      resumeFileName: resumeFileName ?? this.resumeFileName,
      resumeFilePath: resumeFilePath ?? this.resumeFilePath,
      resumeFileSize: resumeFileSize ?? this.resumeFileSize,
      resumeUploadDate: resumeUploadDate ?? this.resumeUploadDate,
      profileImagePath: profileImagePath ?? this.profileImagePath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'reg_no': regNo,
      'department': department,
      'year': year,
      'section': section,
      'cgpa': cgpa,
      'backlogs': backlogs,
      'email': email,
      'phone': phone,
      'dob': dob,
      'username': username,
      'password': password,
      'resume_url': resumeUrl,
      'resume_file_name': resumeFileName,
      'resume_file_size': resumeFileSize,
      'resume_upload_date': resumeUploadDate,
    };
  }

  factory StudentModel.fromMap(Map<String, dynamic> map) {
    return StudentModel(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      regNo: map['reg_no']?.toString() ?? '',
      department: map['department']?.toString() ?? '',
      year: map['year']?.toString() ?? '2nd Year',
      section: map['section']?.toString() ?? 'Section A',
      cgpa: (map['cgpa'] is num) ? (map['cgpa'] as num).toDouble() : (double.tryParse(map['cgpa']?.toString() ?? '0') ?? 0.0),
      backlogs: (map['backlogs'] is num) ? (map['backlogs'] as num).toInt() : (int.tryParse(map['backlogs']?.toString() ?? '0') ?? 0),
      email: map['email']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      dob: map['dob']?.toString() ?? '',
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? 'student123',
      resumeUrl: map['resume_url']?.toString() ?? '',
      resumeFileName: map['resume_file_name']?.toString() ?? '',
      resumeFilePath: '',
      resumeFileSize: map['resume_file_size']?.toString() ?? '',
      resumeUploadDate: map['resume_upload_date']?.toString() ?? '',
      profileImagePath: '',
    );
  }
}

class PlacementRound {
  final String id;
  final String name; // e.g. "Online Aptitude Test", "Technical Interview Round 1", "HR Interview"
  final DateTime date;
  final List<String> qualifiedStudentIds; // Student IDs who passed this round
  final List<String> rejectedStudentIds;  // Student IDs who were rejected/eliminated in this round
  final Map<String, String> evaluationDates; // studentId -> formatted evaluation timestamp

  PlacementRound({
    required this.id,
    required this.name,
    required this.date,
    required this.qualifiedStudentIds,
    this.rejectedStudentIds = const [],
    this.evaluationDates = const {},
  });

  PlacementRound copyWith({
    String? id,
    String? name,
    DateTime? date,
    List<String>? qualifiedStudentIds,
    List<String>? rejectedStudentIds,
    Map<String, String>? evaluationDates,
  }) {
    return PlacementRound(
      id: id ?? this.id,
      name: name ?? this.name,
      date: date ?? this.date,
      qualifiedStudentIds: qualifiedStudentIds ?? this.qualifiedStudentIds,
      rejectedStudentIds: rejectedStudentIds ?? this.rejectedStudentIds,
      evaluationDates: evaluationDates ?? this.evaluationDates,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date.toIso8601String(),
      'qualifiedStudentIds': qualifiedStudentIds,
      'rejectedStudentIds': rejectedStudentIds,
      'evaluationDates': evaluationDates,
    };
  }

  factory PlacementRound.fromMap(Map<String, dynamic> map) {
    return PlacementRound(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      date: map['date'] != null ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now() : DateTime.now(),
      qualifiedStudentIds: List<String>.from(map['qualifiedStudentIds'] ?? []),
      rejectedStudentIds: List<String>.from(map['rejectedStudentIds'] ?? []),
      evaluationDates: Map<String, String>.from(map['evaluationDates'] ?? {}),
    );
  }
}

class PlacementDrive {
  final String id;
  final String companyName;
  final String role;
  final String packageLpa;
  final double minCgpa;
  final List<String> eligibleDepartments;
  final String registrationLink; // Google Form / Company Career link
  final List<String> enrolledStudentIds; // Students manually added/assigned by Admin
  final List<PlacementRound> rounds;
  final List<String> placedStudentIds;
  final Map<String, String> placedDates; // studentId -> formatted placement date timestamp
  final DateTime driveDate;

  PlacementDrive({
    required this.id,
    required this.companyName,
    required this.role,
    required this.packageLpa,
    required this.minCgpa,
    required this.eligibleDepartments,
    this.registrationLink = '',
    this.enrolledStudentIds = const [],
    required this.rounds,
    this.placedStudentIds = const [],
    this.placedDates = const {},
    required this.driveDate,
  });

  PlacementDrive copyWith({
    String? id,
    String? companyName,
    String? role,
    String? packageLpa,
    double? minCgpa,
    List<String>? eligibleDepartments,
    String? registrationLink,
    List<String>? enrolledStudentIds,
    List<PlacementRound>? rounds,
    List<String>? placedStudentIds,
    Map<String, String>? placedDates,
    DateTime? driveDate,
  }) {
    return PlacementDrive(
      id: id ?? this.id,
      companyName: companyName ?? this.companyName,
      role: role ?? this.role,
      packageLpa: packageLpa ?? this.packageLpa,
      minCgpa: minCgpa ?? this.minCgpa,
      eligibleDepartments: eligibleDepartments ?? this.eligibleDepartments,
      registrationLink: registrationLink ?? this.registrationLink,
      enrolledStudentIds: enrolledStudentIds ?? this.enrolledStudentIds,
      rounds: rounds ?? this.rounds,
      placedStudentIds: placedStudentIds ?? this.placedStudentIds,
      placedDates: placedDates ?? this.placedDates,
      driveDate: driveDate ?? this.driveDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_name': companyName,
      'role': role,
      'ctc_package': packageLpa,
      'drive_date': driveDate.toIso8601String(),
      'location': 'On-Campus',
      'description': registrationLink,
      'min_cgpa': minCgpa,
      'max_backlogs': 0,
      'status': 'Active',
      'eligible_departments': eligibleDepartments,
      'enrolled_student_ids': enrolledStudentIds,
      'placed_student_ids': placedStudentIds,
      'placed_dates': placedDates,
      'rounds': rounds.map((r) => r.toMap()).toList(),
    };
  }

  factory PlacementDrive.fromMap(Map<String, dynamic> map) {
    var rawRounds = map['rounds'];
    List<PlacementRound> roundsList = [];
    if (rawRounds is List) {
      roundsList = rawRounds.map((r) => PlacementRound.fromMap(Map<String, dynamic>.from(r))).toList();
    }

    return PlacementDrive(
      id: map['id']?.toString() ?? '',
      companyName: map['company_name']?.toString() ?? '',
      role: map['role']?.toString() ?? '',
      packageLpa: map['ctc_package']?.toString() ?? '',
      minCgpa: (map['min_cgpa'] is num) ? (map['min_cgpa'] as num).toDouble() : (double.tryParse(map['min_cgpa']?.toString() ?? '0') ?? 0.0),
      eligibleDepartments: List<String>.from(map['eligible_departments'] ?? []),
      registrationLink: map['description']?.toString() ?? '',
      enrolledStudentIds: List<String>.from(map['enrolled_student_ids'] ?? []),
      rounds: roundsList,
      placedStudentIds: List<String>.from(map['placed_student_ids'] ?? []),
      placedDates: Map<String, String>.from(map['placed_dates'] ?? {}),
      driveDate: map['drive_date'] != null ? DateTime.tryParse(map['drive_date'].toString()) ?? DateTime.now() : DateTime.now(),
    );
  }
}

class TrainingWorkshop {
  final String id;
  final String title;
  final String trainer;
  final String venueOrMode;
  final String targetBatch;
  final String timing;
  final double progress;
  final String sessions;
  final String status; // 'Ongoing', 'Upcoming', 'Completed'
  final String syllabus;
  final int colorValue;

  TrainingWorkshop({
    required this.id,
    required this.title,
    required this.trainer,
    this.venueOrMode = 'Seminar Hall 2 / Audio-Visual Room',
    this.targetBatch = 'All Final Year Batches',
    this.timing = '03:30 PM - 05:00 PM',
    this.progress = 0.5,
    this.sessions = 'Ongoing',
    this.status = 'Ongoing',
    this.syllabus = 'Comprehensive Industry Readiness',
    this.colorValue = 0xFF2563EB,
  });

  TrainingWorkshop copyWith({
    String? id,
    String? title,
    String? trainer,
    String? venueOrMode,
    String? targetBatch,
    String? timing,
    double? progress,
    String? sessions,
    String? status,
    String? syllabus,
    int? colorValue,
  }) {
    return TrainingWorkshop(
      id: id ?? this.id,
      title: title ?? this.title,
      trainer: trainer ?? this.trainer,
      venueOrMode: venueOrMode ?? this.venueOrMode,
      targetBatch: targetBatch ?? this.targetBatch,
      timing: timing ?? this.timing,
      progress: progress ?? this.progress,
      sessions: sessions ?? this.sessions,
      status: status ?? this.status,
      syllabus: syllabus ?? this.syllabus,
      colorValue: colorValue ?? this.colorValue,
    );
  }
}

class PlacementAnnouncement {
  final String id;
  final String title;
  final String message;
  final String category; // 'Drive Alert', 'Urgent', 'Workshop', 'General'
  final DateTime timestamp;
  final String author;
  final bool isImportant;

  PlacementAnnouncement({
    required this.id,
    required this.title,
    required this.message,
    this.category = 'General',
    required this.timestamp,
    this.author = 'Placement Cell',
    this.isImportant = false,
  });

  PlacementAnnouncement copyWith({
    String? id,
    String? title,
    String? message,
    String? category,
    DateTime? timestamp,
    String? author,
    bool? isImportant,
  }) {
    return PlacementAnnouncement(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      author: author ?? this.author,
      isImportant: isImportant ?? this.isImportant,
    );
  }
}

class AptitudeQuestion {
  final String id;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;

  const AptitudeQuestion({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

class AptitudeQuiz {
  final String id;
  final String title;
  final String category; // 'Quantitative', 'Logical Reasoning', 'Verbal Ability', 'Technical Coding'
  final int durationMinutes;
  final List<AptitudeQuestion> questions;
  final int colorValue;

  const AptitudeQuiz({
    required this.id,
    required this.title,
    required this.category,
    required this.durationMinutes,
    required this.questions,
    this.colorValue = 0xFF2563EB,
  });
}
