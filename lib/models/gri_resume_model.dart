class GriEducationRow {
  String degree;
  String institution;
  String boardOrUniversity;
  String yearOfPassing;
  String percentageOrCgpa;

  GriEducationRow({
    required this.degree,
    required this.institution,
    this.boardOrUniversity = '',
    required this.yearOfPassing,
    required this.percentageOrCgpa,
  });

  Map<String, dynamic> toMap() {
    return {
      'degree': degree,
      'institution': institution,
      'boardOrUniversity': boardOrUniversity,
      'yearOfPassing': yearOfPassing,
      'percentageOrCgpa': percentageOrCgpa,
    };
  }

  factory GriEducationRow.fromMap(Map<String, dynamic> map) {
    return GriEducationRow(
      degree: map['degree'] ?? '',
      institution: map['institution'] ?? '',
      boardOrUniversity: map['boardOrUniversity'] ?? '',
      yearOfPassing: map['yearOfPassing'] ?? '',
      percentageOrCgpa: map['percentageOrCgpa'] ?? '',
    );
  }
}

class GriProjectItem {
  String title;
  String techStack;
  String duration;
  String description;

  GriProjectItem({
    required this.title,
    required this.techStack,
    this.duration = '',
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'techStack': techStack,
      'duration': duration,
      'description': description,
    };
  }

  factory GriProjectItem.fromMap(Map<String, dynamic> map) {
    return GriProjectItem(
      title: map['title'] ?? '',
      techStack: map['techStack'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class GriExperienceItem {
  String companyName;
  String role;
  String duration;
  String description;

  GriExperienceItem({
    required this.companyName,
    required this.role,
    required this.duration,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'role': role,
      'duration': duration,
      'description': description,
    };
  }

  factory GriExperienceItem.fromMap(Map<String, dynamic> map) {
    return GriExperienceItem(
      companyName: map['companyName'] ?? '',
      role: map['role'] ?? '',
      duration: map['duration'] ?? '',
      description: map['description'] ?? '',
    );
  }
}

class GriReferenceItem {
  String name;
  String designation;
  String institution;
  String mobile;
  String email;

  GriReferenceItem({
    required this.name,
    required this.designation,
    this.institution = 'The Gandhigram Rural Institute (GRI)',
    required this.mobile,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'designation': designation,
      'institution': institution,
      'mobile': mobile,
      'email': email,
    };
  }

  factory GriReferenceItem.fromMap(Map<String, dynamic> map) {
    return GriReferenceItem(
      name: map['name'] ?? '',
      designation: map['designation'] ?? '',
      institution: map['institution'] ?? 'The Gandhigram Rural Institute (GRI)',
      mobile: map['mobile'] ?? '',
      email: map['email'] ?? '',
    );
  }
}

class GriResumeData {
  String fullName;
  String email;
  String phone;
  String address;
  String careerSummary;
  List<GriEducationRow> educationList;
  String technicalSkills;
  String softSkills;
  String certifications;
  List<GriExperienceItem> experiences;
  List<GriProjectItem> projects;
  String achievements;
  String knowledgeEvents;
  String extracurricular;
  String languagesKnown;
  List<GriReferenceItem> references;
  String? photoPath;
  int themeColorValue;
  bool showCertifications;
  bool showExperience;
  bool showProjects;
  bool showAchievements;
  bool showKnowledgeEvents;
  bool showExtracurricular;

  GriResumeData({
    required this.fullName,
    required this.email,
    required this.phone,
    this.address = '',
    required this.careerSummary,
    required this.educationList,
    required this.technicalSkills,
    this.softSkills = 'Team leader, Good in communication, Problem Solving & Decision-making skills',
    this.certifications = '',
    required this.experiences,
    required this.projects,
    this.achievements = '',
    this.knowledgeEvents = '',
    this.extracurricular = '',
    this.languagesKnown = 'Tamil, English',
    required this.references,
    this.photoPath,
    this.themeColorValue = 0xFF0F766E,
    this.showCertifications = true,
    this.showExperience = true,
    this.showProjects = true,
    this.showAchievements = true,
    this.showKnowledgeEvents = true,
    this.showExtracurricular = true,
  });

  static GriResumeData createDefault({
    required String name,
    required String email,
    required String phone,
    required String department,
    required String year,
    required double cgpa,
  }) {
    return GriResumeData(
      fullName: name,
      email: email,
      phone: phone,
      address: 'Gandhigram, Dindigul District, Tamil Nadu - 624302',
      careerSummary:
          'Bachelors/Masters in $department Graduate looking to join a progressive company where I can acquire new skills, enhance my existing technical abilities, and add value to the growth of your company.',
      educationList: [
        GriEducationRow(
          degree: department,
          institution: 'The Gandhigram Rural Institute (Deemed to be University)',
          boardOrUniversity: 'GRI (Deemed University)',
          yearOfPassing: '2024 - 2027 (Pursuing)',
          percentageOrCgpa: '$cgpa CGPA',
        ),
        GriEducationRow(
          degree: 'HSC (12th Std)',
          institution: 'Government / Matric Hr. Sec. School',
          boardOrUniversity: 'State Board',
          yearOfPassing: '2023',
          percentageOrCgpa: '88.5%',
        ),
        GriEducationRow(
          degree: 'SSLC (10th Std)',
          institution: 'Government / High School',
          boardOrUniversity: 'State Board',
          yearOfPassing: '2021',
          percentageOrCgpa: '91.2%',
        ),
      ],
      technicalSkills:
          'Programming Languages: Java, Python, C, C++, HTML, Dart/Flutter\nDatabase: MySQL, PostgreSQL, SQL\nTools & Platforms: Git, VS Code, Linux',
      softSkills: 'Team Leadership, Good in communication, Problem Solving & Analytical Decision-making skills',
      certifications: '• TCS iON Career Edge - Young Professional\n• Fundamentals of Digital Marketing (Google)',
      experiences: [
        GriExperienceItem(
          companyName: 'Rohuma India Info Solutions / Industry Intern',
          role: 'Android App Developer / Front-End Tester',
          duration: 'August 2025 to November 2025',
          description: 'Tested UI components, fixed layout defects, and integrated responsive mobile views.',
        ),
      ],
      projects: [
        GriProjectItem(
          title: 'PlaceTrack - Campus Placement & Career Portal',
          techStack: 'Flutter, Dart, Firebase, Android SDK',
          duration: '3 Months',
          description:
              'A complete placement training and management mobile application enabling real-time resume upload, eligibility filters, and drive progress tracking.',
        ),
      ],
      achievements: '• Won 1st Prize in Inter-College Technical Paper Presentation 2025\n• Cleared CodeChef Star Coder Challenge',
      knowledgeEvents: '• Attended National Workshop on Full-Stack Cloud Deployment\n• Participant in AI & Machine Learning Symposium',
      extracurricular: '• Active member of Campus Red Ribbon Club & Debate Society\n• Participated in Inter-Departmental Sports & Cultural Festivals',
      languagesKnown: 'Tamil, English, Hindi',
      references: [
        GriReferenceItem(
          name: 'Dr. G. Kingsly',
          designation: 'Placement Officer',
          institution: 'The Gandhigram Rural Institute (GRI)',
          mobile: '9842004204',
          email: 'griplacement@ruraluniv.ac.in',
        ),
      ],
    );
  }
}
