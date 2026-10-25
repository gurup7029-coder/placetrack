import 'dart:io';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Color Palette
final primaryColor = PdfColor.fromInt(0xFF1A237E); // Deep Indigo
final primaryLight = PdfColor.fromInt(0xFF3949AB);
final secondaryColor = PdfColor.fromInt(0xFF00695C); // Teal
final accentGold = PdfColor.fromInt(0xFFF57F17); // Amber Gold
final successGreen = PdfColor.fromInt(0xFF2E7D32); // Forest Green
final errorRed = PdfColor.fromInt(0xFFC62828); // Crimson Red
final bgLight = PdfColor.fromInt(0xFFF8F9FA); // Off-White
final bgDark = PdfColor.fromInt(0xFF0F172A); // Slate 900
final cardBorder = PdfColor.fromInt(0xFFCFD8DC);
final textDark = PdfColor.fromInt(0xFF212121);
final textMuted = PdfColor.fromInt(0xFF546E7A);

pw.MemoryImage? loadImage(String path) {
  try {
    final file = File(path);
    if (file.existsSync()) {
      return pw.MemoryImage(file.readAsBytesSync());
    }
  } catch (e) {
    print('Warning: could not load image at $path: $e');
  }
  return null;
}

// Page Theme
pw.PageTheme getPageTheme({bool isCover = false}) {
  return pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: isCover 
        ? const pw.EdgeInsets.all(0) 
        : const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 36),
    buildBackground: (pw.Context context) {
      if (isCover) {
        return pw.Container(
          decoration: pw.BoxDecoration(
            color: bgDark,
          ),
        );
      }
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColor.fromInt(0xFFE2E8F0), width: 1),
          ),
        ),
      );
    },
  );
}

// Header & Footer helper
pw.Widget buildHeader(String sectionTitle) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(bottom: 8),
    margin: const pw.EdgeInsets.only(bottom: 16),
    decoration: const pw.BoxDecoration(
      border: pw.Border(bottom: pw.BorderSide(color: PdfColor.fromInt(0xFFCFD8DC), width: 1)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 8,
              height: 8,
              decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle),
            ),
            pw.SizedBox(width: 6),
            pw.Text(
              'PLACETRACK - CAMPUS PLACEMENT SYSTEM',
              style: pw.TextStyle(color: primaryColor, fontSize: 8, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.Text(
          sectionTitle.toUpperCase(),
          style: pw.TextStyle(color: textMuted, fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

pw.Widget buildFooter(pw.Context context) {
  return pw.Container(
    padding: const pw.EdgeInsets.only(top: 8),
    margin: const pw.EdgeInsets.only(top: 16),
    decoration: const pw.BoxDecoration(
      border: pw.Border(top: pw.BorderSide(color: PdfColor.fromInt(0xFFE0E0E0), width: 1)),
    ),
    child: pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          'The Gandhigram Rural Institute (Deemed to be University) - Placement Cell',
          style: pw.TextStyle(color: textMuted, fontSize: 7),
        ),
        pw.Text(
          'Page ${context.pageNumber} of ${context.pagesCount}',
          style: pw.TextStyle(color: primaryColor, fontSize: 7, fontWeight: pw.FontWeight.bold),
        ),
      ],
    ),
  );
}

// Section Title Helper
pw.Widget buildSectionHeading(String number, String title) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(bottom: 12, top: 4),
    child: pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: pw.BoxDecoration(
            color: primaryColor,
            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
          ),
          child: pw.Text(
            number,
            style: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
        ),
        pw.SizedBox(width: 8),
        pw.Expanded(
          child: pw.Text(
            title,
            style: pw.TextStyle(color: primaryColor, fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ),
      ],
    ),
  );
}

// Subheading Helper
pw.Widget buildSubHeading(String title) {
  return pw.Container(
    margin: const pw.EdgeInsets.only(top: 8, bottom: 6),
    child: pw.Text(
      title,
      style: pw.TextStyle(color: secondaryColor, fontWeight: pw.FontWeight.bold, fontSize: 11),
    ),
  );
}

// Callout Box
pw.Widget buildCalloutBox({required String text, PdfColor? color, String? title}) {
  final boxColor = color ?? primaryColor;
  return pw.Container(
    margin: const pw.EdgeInsets.symmetric(vertical: 6),
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: PdfColor.fromInt(0xFFF1F5F9),
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      border: pw.Border(left: pw.BorderSide(color: boxColor, width: 4)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          pw.Text(
            title,
            style: pw.TextStyle(color: boxColor, fontWeight: pw.FontWeight.bold, fontSize: 9),
          ),
          pw.SizedBox(height: 3),
        ],
        pw.Text(
          text,
          style: pw.TextStyle(color: textDark, fontSize: 8.5, lineSpacing: 1.3),
        ),
      ],
    ),
  );
}

// Badge
pw.Widget buildBadge(String text, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: pw.BoxDecoration(
      color: color,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(3)),
    ),
    child: pw.Text(
      text,
      style: pw.TextStyle(color: PdfColors.white, fontSize: 7, fontWeight: pw.FontWeight.bold),
    ),
  );
}

Future<void> main() async {
  print('Starting PlaceTrack Documentation PDF generation...');

  final pdf = pw.Document(
    title: 'PlaceTrack - Campus Recruitment & Placement Management System Documentation',
    author: 'Placement Cell & Development Team, Gandhigram Rural Institute',
    subject: 'Complete Project Architecture, Workflows, Models & Implementation Manual',
    keywords: 'PlaceTrack, Gandhigram Rural Institute, Placement Portal, Flutter, ATS Resume, Architecture',
  );

  // Load Screen Images
  final imgLogin = loadImage('assets/docs_images/login_screen.png');
  final imgAdminDash = loadImage('assets/docs_images/admin_dashboard.png');
  final imgStudent = loadImage('assets/docs_images/student_portal.png');
  final imgResumeTemplate = loadImage('assets/docs_images/gri_resume_template.jpg');
  final imgResumeBuilder = loadImage('assets/docs_images/resume_builder.png');
  final imgMobileLive = loadImage('assets/docs_images/mobile_app_live.png');

  // ==========================================
  // PAGE 1: COVER PAGE
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(isCover: true),
      build: (pw.Context context) {
        return pw.Container(
          padding: const pw.EdgeInsets.all(40),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              // Top University Branding
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'THE GANDHIGRAM RURAL INSTITUTE',
                    style: pw.TextStyle(
                      color: accentGold,
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '(Deemed to be University) - Ministry of Education, Govt. of India',
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 9,
                    ),
                  ),
                  pw.Text(
                    'Gandhigram - 624 302, Dindigul District, Tamil Nadu, India',
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFF94A3B8),
                      fontSize: 8,
                    ),
                  ),
                  pw.SizedBox(height: 15),
                  pw.Container(
                    height: 2,
                    width: 120,
                    color: accentGold,
                  ),
                ],
              ),

              // Title Area
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: pw.BoxDecoration(
                      color: primaryLight,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'OFFICIAL TECHNICAL DOCUMENTATION & SYSTEM MANUAL',
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'PLACETRACK',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 38,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    'Next-Gen Campus Placement & Career Enablement Platform',
                    style: pw.TextStyle(
                      color: accentGold,
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  pw.Text(
                    'A complete enterprise-grade digital solution unifying Placement Officers, Recruiters, and Students with real-time candidate evaluation, physics-based placement celebrations, official GRI ATS resume generator with voice typing, and intelligent analytics.',
                    style: pw.TextStyle(
                      color: PdfColor.fromInt(0xFFCBD5E1),
                      fontSize: 9.5,
                      lineSpacing: 1.4,
                    ),
                  ),
                  pw.SizedBox(height: 20),
                  // Pills
                  pw.Row(
                    children: [
                      buildBadge('v1.0.0 Production', primaryLight),
                      pw.SizedBox(width: 8),
                      buildBadge('Flutter 3.x & Dart', secondaryColor),
                      pw.SizedBox(width: 8),
                      buildBadge('GRI ATS Standard', accentGold),
                      pw.SizedBox(width: 8),
                      buildBadge('Multi-Platform', successGreen),
                    ],
                  ),
                ],
              ),

              // Bottom Metadata Block
              pw.Container(
                padding: const pw.EdgeInsets.all(16),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF1E293B),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                  border: pw.Border.all(color: PdfColor.fromInt(0xFF334155), width: 1),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('INSTITUTIONAL DOMAIN', style: pw.TextStyle(color: accentGold, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('Training & Placement Cell', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Gandhigram Rural Institute', style: pw.TextStyle(color: PdfColor.fromInt(0xFF94A3B8), fontSize: 8)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('ACADEMIC YEAR', style: pw.TextStyle(color: accentGold, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('2026 - 2027', style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Production Verified', style: pw.TextStyle(color: PdfColor.fromInt(0xFF94A3B8), fontSize: 8)),
                      ],
                    ),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('SYSTEM STATUS', style: pw.TextStyle(color: accentGold, fontSize: 7.5, fontWeight: pw.FontWeight.bold)),
                        pw.SizedBox(height: 2),
                        pw.Text('Deployed & Operational', style: pw.TextStyle(color: successGreen, fontSize: 9, fontWeight: pw.FontWeight.bold)),
                        pw.Text('Android Mobile & Web Ready', style: pw.TextStyle(color: PdfColor.fromInt(0xFF94A3B8), fontSize: 8)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );

  // ==========================================
  // PAGE 2: TABLE OF CONTENTS & EXECUTIVE SUMMARY
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Table of Contents & Executive Summary'),
            buildSectionHeading('01', 'Executive Summary & Project Scope'),
            pw.Text(
              'PlaceTrack was conceived and engineered for The Gandhigram Rural Institute (Deemed to be University) to revolutionize how campus recruitment, career development, and candidate assessment are coordinated across departments. Traditional placement workflows rely on fragmented spreadsheets, delayed circulars, disparate resume formats that fail corporate ATS filters, and manual candidate status reconciliation.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5, lineSpacing: 1.3),
            ),
            pw.SizedBox(height: 8),
            buildCalloutBox(
              title: 'Primary Objectives of PlaceTrack',
              text: '1. Real-time Candidate Pipeline: Instant visibility into multi-round progression (Aptitude, Technical, HR).\n'
                  '2. Voice-Assisted GRI ATS Resume Builder: Standardized docx/pdf generation matching university guidelines.\n'
                  '3. Celebration & Motivation Engine: Real-time particle fireworks honoring placed candidates.\n'
                  '4. Granular Filtering & Export: Custom column export to Excel & PDF with live placement metrics.',
            ),
            pw.SizedBox(height: 12),
            buildSectionHeading('02', 'Document Structure & Navigation Index'),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(5),
                  2: const pw.FlexColumnWidth(4),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Sec', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Section Topic & Description', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Core Deliverables / Modules', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  _tableRow3('1', 'Executive Summary & Architecture', 'Problem Statement, Objectives, Tech Stack', false),
                  _tableRow3('2', 'Technical Architecture & Layering', 'Clean Architecture, State Management, Supabase', true),
                  _tableRow3('3', 'Complete Data Models & Schemas', 'StudentModel, PlacementDrive, PlacementRound', false),
                  _tableRow3('4', 'End-to-End Recruitment Workflow', 'Drive creation, candidate round progression, pass/fail', true),
                  _tableRow3('5', 'Fireworks & Celebration Engine', 'Particle physics, dynamic dialog, golden badge', false),
                  _tableRow3('6', 'GRI ATS Resume Builder (Voice)', 'Speech-to-text dictation, Word/PDF export', true),
                  _tableRow3('7', 'Student Directory & Column Export', 'Company/Round filter, custom columns, live stats', false),
                  _tableRow3('8', 'Visual Screen Gallery & Interface', 'Real UI screenshots, admin/student portals', true),
                  _tableRow3('9', 'Deployment, Security & Manual', 'Production build, installation, offline resilience', false),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 3: TECHNICAL ARCHITECTURE & TECH STACK
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Technical Architecture & Tech Stack'),
            buildSectionHeading('03', 'Multi-Tier System Architecture'),
            pw.Text(
              'PlaceTrack follows an enterprise Clean Architecture pattern with separation of concerns between UI Presentation, Domain Business Logic, and Data Persistence.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 8),

            // Layered Diagram Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: bgLight,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: cardBorder),
              ),
              child: pw.Column(
                children: [
                  _archLayerBox('PRESENTATION LAYER (Flutter 3.x / Material 3)', [
                    'Student Dashboard UI', 'Placement Officer Management Hub',
                    'Interactive Particle Fireworks Canvas', 'GRI Resume Builder & Voice Dictation',
                  ], primaryColor),
                  pw.SizedBox(height: 4),
                  pw.Center(child: pw.Text(' |   Dependency Injection & Event Dispatch   |', style: pw.TextStyle(fontSize: 7, color: textMuted))),
                  pw.SizedBox(height: 4),
                  _archLayerBox('BUSINESS LOGIC & STATE LAYER (ChangeNotifier Singleton)', [
                    'PlacementDataService (Drives, Rounds, Realtime Evaluation)',
                    'StudentExportService (Excel, PDF, Dynamic Column Filtering)',
                    'GRIResumeService (Docx XML Generation, PDF Formatting)',
                  ], secondaryColor),
                  pw.SizedBox(height: 4),
                  pw.Center(child: pw.Text(' |   Data Transport & Service Layer   |', style: pw.TextStyle(fontSize: 7, color: textMuted))),
                  pw.SizedBox(height: 4),
                  _archLayerBox('DATA PERSISTENCE & HARDWARE INTERFACES', [
                    'Supabase Cloud PostgreSQL (Realtime Pub/Sub, RPC, Storage)',
                    'Offline Resilient In-Memory State Cache with Fallback Mock Data',
                    'Native Microphone Bridge (speech_to_text) & Local Storage I/O',
                  ], bgDark),
                ],
              ),
            ),

            pw.SizedBox(height: 10),
            buildSectionHeading('04', 'Production Technology Stack Breakdown'),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(2.5),
                  1: const pw.FlexColumnWidth(2),
                  2: const pw.FlexColumnWidth(5.5),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Technology / Package', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Version', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Functional Role in PlaceTrack', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  _tableRow3('Flutter Framework', 'v3.13.4+', 'Cross-platform reactive UI engine (Android, Web, Desktop)', false),
                  _tableRow3('Dart SDK', 'v3.13.4+', 'Strongly-typed object-oriented language for high performance', true),
                  _tableRow3('supabase_flutter', '^2.17.2', 'Cloud database, authentication, real-time table sync', false),
                  _tableRow3('pdf & printing', '^3.13.1 / ^5.15.1', 'Vector document layout, preview, and print rendering', true),
                  _tableRow3('speech_to_text', '^7.5.0', 'Voice-to-text dictation for hands-free resume drafting', false),
                  _tableRow3('archive', '^4.3.0', 'Word (.docx) ZIP packaging with XML document templates', true),
                  _tableRow3('open_filex', '^4.7.0', 'Native OS file launcher for generated Excel, Word & PDF docs', false),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 4: DATA MODELS & SCHEMA ARCHITECTURE
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Data Models & Schema Architecture'),
            buildSectionHeading('05', 'Core Entities & Domain Models'),
            pw.Text(
              'The system domain encapsulates student profiles, company placement drives, multi-round selection pipelines, training workshops, and announcements.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),

            // Model 1: StudentModel
            _modelCard(
              title: 'StudentModel (lib/models/student_model.dart)',
              color: primaryColor,
              fields: [
                'id (String): Unique identifier / UUID',
                'name (String): Full student name',
                'rollNumber (String): Official GRI Roll No (e.g. 23101234)',
                'department (String): Academic department (e.g. Computer Science, MCA)',
                'email, phone (String): Official contact information',
                'cgpa (double): Cumulative Grade Point Average',
                'historyOfArrears, standingArrears (int): Backlog counters for eligibility filters',
                'isPlaced (bool): True if candidate accepted an offer',
                'placedCompany (String?): Recruiter name upon clearance',
                'packageLpa (double?): CTC compensation package in Lakhs Per Annum',
                'clearedRounds (List<String>): IDs of rounds successfully cleared',
              ],
            ),
            pw.SizedBox(height: 6),

            // Model 2: PlacementDrive
            _modelCard(
              title: 'PlacementDrive (lib/models/placement_drive.dart)',
              color: secondaryColor,
              fields: [
                'id (String): Unique Drive ID',
                'companyName (String): Name of recruiting organization (e.g. Cognizant, Zoho)',
                'jobRole (String): Designation offered (e.g. Software Engineer)',
                'packageLpa (double): Annual compensation in LPA',
                'minCgpa (double): Minimum CGPA threshold for eligibility',
                'maxStandingArrears (int): Arrears tolerance threshold (typically 0)',
                'driveDate (DateTime): Scheduled commencement date',
                'status (String): Status ("upcoming", "active", "completed")',
                'rounds (List<PlacementRound>): Sequential selection stages',
              ],
            ),
            pw.SizedBox(height: 6),

            // Model 3: PlacementRound
            _modelCard(
              title: 'PlacementRound (lib/models/placement_round.dart)',
              color: accentGold,
              fields: [
                'id (String): Unique round identifier',
                'roundNumber (int): Chronological stage sequence (1, 2, 3...)',
                'name (String): Round title (e.g. "Online Assessment", "Technical Interview", "HR")',
                'status (String): Round progress ("Pending", "Active", "Completed")',
                'roundDate (DateTime?): Evaluation date/time',
                'candidateStatus (Map<String, String>): Real-time mapping of [StudentId -> Status]',
                '  Status Values: "PENDING" | "CLEARED" | "REJECTED"',
              ],
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 5: END-TO-END RECRUITMENT WORKFLOW
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('End-to-End Recruitment Workflow'),
            buildSectionHeading('06', 'Recruitment Pipeline & Candidate Round Transitions'),
            pw.Text(
              'The placement process consists of a gated multi-round pipeline where candidates advance through successive elimination filters until final selection.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 8),

            // Flowchart Box
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: bgLight,
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                children: [
                  _flowStepCard('STEP 1: DRIVE CREATION & ELIGIBILITY LOCK',
                    'Placement Officer configures Company, Role, CTC, Min CGPA, Arrears tolerance, and adds selection rounds.',
                    primaryColor),
                  pw.SizedBox(height: 4),
                  pw.Text('v Candidate Application & Auto-Eligibility Filter v', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                  pw.SizedBox(height: 4),
                  _flowStepCard('STEP 2: ROUND 1 - APTITUDE & CODING ASSESSMENT',
                    'Candidates take test. Officer marks status: CLEARED (green check) or REJECTED (red cross). Pending remain in evaluation queue.',
                    primaryLight),
                  pw.SizedBox(height: 4),
                  pw.Text('v Cleared Candidates Advance to Round 2 v', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                  pw.SizedBox(height: 4),
                  _flowStepCard('STEP 3: ROUND 2 - TECHNICAL INTERVIEW',
                    'Coding problem solving & system evaluation. Officer updates candidateStatus real-time with instant stats recalculation.',
                    secondaryColor),
                  pw.SizedBox(height: 4),
                  pw.Text('v Cleared Candidates Advance to Final HR Round v', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                  pw.SizedBox(height: 4),
                  _flowStepCard('STEP 4: ROUND 3 - HR & FINAL SELECTION',
                    'HR discussions. Upon clearing final round: student marked as isPlaced=true, placedCompany assigned, CTC package locked.',
                    accentGold),
                  pw.SizedBox(height: 4),
                  pw.Text('v Automated Offer Release & System Celebration v', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                  _flowStepCard('STEP 5: CELEBRATION & OFFER LOCK',
                    'Triggers multi-burst particle fireworks on student portal, awards Golden Placed Badge, and generates official offer letter.',
                    successGreen),
                ],
              ),
            ),

            pw.SizedBox(height: 10),
            buildSubHeading('Real-Time Officer Controls & Statistics'),
            pw.Text(
              'The Placement Officer interface provides toggle actions for every candidate: "Clear Round" and "Reject Candidate". As updates occur, the Live Summary Banner updates dynamically:',
              style: pw.TextStyle(color: textDark, fontSize: 8),
            ),
            pw.SizedBox(height: 4),
            pw.Row(
              children: [
                _metricBox('TOTAL APPLIED', '248', primaryColor),
                pw.SizedBox(width: 6),
                _metricBox('CLEARED ROUND', '142', successGreen),
                pw.SizedBox(width: 6),
                _metricBox('REJECTED', '38', errorRed),
                pw.SizedBox(width: 6),
                _metricBox('PENDING', '68', accentGold),
                pw.SizedBox(width: 6),
                _metricBox('CLEARANCE RATE', '57.2%', secondaryColor),
              ],
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 6: CELEBRATION ENGINE & GRI ATS RESUME
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Placement Celebration & GRI ATS Resume System'),
            buildSectionHeading('07', 'Real-Time Fireworks & Crackers Celebration Engine'),
            pw.Text(
              'A critical psychological feature of PlaceTrack is the celebration engine, designed to celebrate rural student achievements when they clear their final placement round.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),
            buildCalloutBox(
              title: 'Physics-Based Particle Animation Architecture',
              text: '• Physics Simulation: 120+ active particle vectors running on Flutter CustomPainter.\n'
                  '• Radial Explosions: Velocity calculated using trigonometric offsets (cos(angle) * speed, sin(angle) * speed).\n'
                  '• Multi-Burst Sequences: Firecracker rockets launch vertically and burst into golden, crimson, emerald & amber sparks.\n'
                  '• Gravity & Drag Decay: Realistic deceleration with alpha opacity fading (1.0 -> 0.0) over a 2.5 second burst lifecycle.\n'
                  '• Golden Placed Badge: Placed candidates receive a permanent animated gradient badge on their dashboard.',
              color: accentGold,
            ),
            pw.SizedBox(height: 10),

            buildSectionHeading('08', 'Official GRI ATS-Compliant Resume Builder'),
            pw.Text(
              'To ensure students from Gandhigram Rural Institute pass Applicant Tracking System (ATS) screening algorithms used by Fortune 500 recruiters, PlaceTrack includes an intelligent resume builder strictly conforming to official GRI guidelines.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(7),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('GRI Resume Section', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Standard Formatting & Content Rules', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  _tableRow2('Header Block', 'Student Name, Permanent & Present Address, Email, Phone, LinkedIn, GitHub.', false),
                  _tableRow2('Career Objective', 'Concise 2-sentence aspirational statement tailored to the target engineering role.', true),
                  _tableRow2('Academic Credentials', 'Tabular matrix: Course, Institution, Board/University, Year of Passing, % / CGPA.', false),
                  _tableRow2('Technical Skillsets', 'Languages, Frameworks, Cloud Platforms, Developer Tools with categorized bulleting.', true),
                  _tableRow2('Academic Projects', 'Title, Tech Stack, Key Responsibilities, Problem Solved, Metrics & Git repo link.', false),
                  _tableRow2('Voice Dictation', 'Speech-to-Text integration enabling hands-free input of career objective and projects.', true),
                  _tableRow2('Multi-Format Export', 'Native Microsoft Word (.docx) with official styles + Vector PDF for instant submission.', false),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 7: STUDENT DIRECTORY & CUSTOM COLUMN EXPORT
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Student Directory & Export System'),
            buildSectionHeading('09', 'Intelligent Student Filtering & Candidate Search'),
            pw.Text(
              'The Student Directory module empowers Placement Officers with real-time multi-dimensional querying across the entire student population.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _featureCard(
                    'Company-Wise Filtering',
                    'Instantly narrow down candidates to specific recruitment drives (e.g. Cognizant, Zoho, TCS, Infosys, Wipro). Only students registered or shortlisted for the selected company are displayed.',
                    primaryColor,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _featureCard(
                    'Round-Specific Status Filter',
                    'Filter candidates by their evaluation status in any specific round: "Cleared Only", "Rejected", or "Pending Evaluation". Enables immediate generation of round interview call sheets.',
                    secondaryColor,
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            buildSectionHeading('10', 'Custom Column Selection & Dual Export Pipeline'),
            pw.Text(
              'Recognizing that recruiters have different data requirements and to protect student privacy, PlaceTrack provides a dynamic Column Selection Engine before exporting.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),

            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: bgLight,
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Available Columns for Custom Export Selection:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 8.5, color: primaryColor)),
                  pw.SizedBox(height: 4),
                  pw.Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      buildBadge('[x] Roll Number', primaryColor),
                      buildBadge('[x] Full Name', primaryColor),
                      buildBadge('[x] Department', primaryColor),
                      buildBadge('[x] CGPA', primaryColor),
                      buildBadge('[x] Arrears Count', primaryColor),
                      buildBadge('[x] Email ID', secondaryColor),
                      buildBadge('[x] Phone Number', secondaryColor),
                      buildBadge('[x] Placement Status', accentGold),
                      buildBadge('[x] Placed Company', accentGold),
                      buildBadge('[x] Package (LPA)', accentGold),
                      buildBadge('[x] Cleared Rounds', primaryLight),
                    ],
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 8),
            buildSubHeading('Dual Export Format Architecture'),
            pw.Row(
              children: [
                pw.Expanded(
                  child: buildCalloutBox(
                    title: 'Excel / CSV Spreadsheet Engine',
                    text: 'Generates clean, RFC 4180 compliant CSV files with formatted header records and proper cell escaping. Directly opens in Microsoft Excel, Google Sheets, or corporate HRMS.',
                    color: successGreen,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: buildCalloutBox(
                    title: 'Vector PDF Roster Engine',
                    text: 'Renders crisp, print-ready PDF tables with Gandhigram Rural Institute letterhead, filter summary metadata, timestamp, and page numbers.',
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 8: VISUAL SCREEN GALLERY - PORTALS
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Visual Screen Gallery - Authentication & Dashboards'),
            buildSectionHeading('11', 'Application Screenshots & User Interfaces'),
            pw.Text(
              'PlaceTrack features a clean Material 3 design with responsive layouts optimized for Android mobile devices and desktop displays.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 8),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Login Screen
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      if (imgLogin != null)
                        pw.Container(
                          height: 250,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: cardBorder, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(imgLogin, fit: pw.BoxFit.contain),
                          ),
                        )
                      else
                        pw.Container(height: 250, color: bgLight, child: pw.Center(child: pw.Text('Login Screenshot'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Figure 1: PlaceTrack Dual Role Authentication', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Seamless toggle between Student & Placement Officer roles.', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 12),
                // Admin Dashboard
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      if (imgAdminDash != null)
                        pw.Container(
                          height: 250,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: cardBorder, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(imgAdminDash, fit: pw.BoxFit.contain),
                          ),
                        )
                      else
                        pw.Container(height: 250, color: bgLight, child: pw.Center(child: pw.Text('Admin Dashboard Screenshot'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Figure 2: Placement Officer Command Center', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Live stats, drive monitoring, quick actions & announcements.', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 9: VISUAL SCREEN GALLERY - RESUME & MOBILE
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Visual Screen Gallery - Resume Builder & Mobile App'),
            buildSectionHeading('12', 'GRI Resume Template & Mobile Deployment'),
            pw.Text(
              'Comparison of the official Gandhigram Rural Institute template standard with the PlaceTrack interactive Resume Builder and live mobile application.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 8),

            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Resume Template
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      if (imgResumeTemplate != null)
                        pw.Container(
                          height: 240,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: cardBorder, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(imgResumeTemplate, fit: pw.BoxFit.contain),
                          ),
                        )
                      else
                        pw.Container(height: 240, color: bgLight, child: pw.Center(child: pw.Text('GRI Resume Format'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Figure 3: Official GRI Resume Standard', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Prescribed institutional academic format & tabular layout.', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                // Resume Builder
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      if (imgResumeBuilder != null)
                        pw.Container(
                          height: 240,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: cardBorder, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(imgResumeBuilder, fit: pw.BoxFit.contain),
                          ),
                        )
                      else
                        pw.Container(height: 240, color: bgLight, child: pw.Center(child: pw.Text('Resume Builder'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Figure 4: Interactive Resume Builder', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Voice typing enabled sections with live preview & export.', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
                pw.SizedBox(width: 8),
                // Mobile App Live
                pw.Expanded(
                  child: pw.Column(
                    children: [
                      if (imgMobileLive != null)
                        pw.Container(
                          height: 240,
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: cardBorder, width: 1.5),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                          ),
                          child: pw.ClipRRect(
                            horizontalRadius: 6,
                            verticalRadius: 6,
                            child: pw.Image(imgMobileLive, fit: pw.BoxFit.contain),
                          ),
                        )
                      else
                        pw.Container(height: 240, color: bgLight, child: pw.Center(child: pw.Text('Mobile App Live'))),
                      pw.SizedBox(height: 4),
                      pw.Text('Figure 5: Live Android Device Deployment', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('Running natively on connected physical smartphone.', style: pw.TextStyle(fontSize: 7, color: textMuted)),
                    ],
                  ),
                ),
              ],
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 10: SECURITY, OFFLINE RESILIENCE & MANUAL
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: getPageTheme(),
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Security, Offline Resilience & Operations Manual'),
            buildSectionHeading('13', 'Security Architecture & Data Protection'),
            pw.Text(
              'PlaceTrack implements defense-in-depth security to safeguard student academic records and prevent unauthorized evaluation tampering.',
              style: pw.TextStyle(color: textDark, fontSize: 8.5),
            ),
            pw.SizedBox(height: 6),

            pw.Row(
              children: [
                pw.Expanded(
                  child: _featureCard(
                    'Role-Based Authorization',
                    'Strict boundary separating Officer privileges (drive creation, round evaluation, bulk export) from Student privileges (application view, test taking, resume building).',
                    primaryColor,
                  ),
                ),
                pw.SizedBox(width: 8),
                pw.Expanded(
                  child: _featureCard(
                    'Offline State Resilience',
                    'When internet connectivity fluctuates in rural campus areas, the app seamlessly switches to local state caching, allowing continuous evaluation without data loss.',
                    secondaryColor,
                  ),
                ),
              ],
            ),

            pw.SizedBox(height: 10),
            buildSectionHeading('14', 'Build, Deployment & Verification Guide'),
            pw.Container(
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(7),
                },
                children: [
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Operation / Target', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text('Terminal Command / Execution Procedure', style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold))),
                    ],
                  ),
                  _tableRow2('Static Code Analysis', 'dart analyze lib  (0 errors / clean quality score)', false),
                  _tableRow2('Android APK (Default)', 'flutter build apk --no-tree-shake-icons', true),
                  _tableRow2('Android Direct Install', 'flutter install -d <device_id>  or  adb install <apk_path>', false),
                  _tableRow2('Web Production Build', 'flutter build web --release --web-renderer canvaskit', true),
                  _tableRow2('PDF Documentation', 'dart run scripts/generate_documentation_pdf.dart', false),
                ],
              ),
            ),

            pw.SizedBox(height: 10),
            buildSectionHeading('15', 'Sign-Off & Project Verification'),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: bgLight,
                border: pw.Border.all(color: cardBorder),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DOCUMENT VERSION: 1.0.0 (Release)', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('INSTITUTION: The Gandhigram Rural Institute', style: pw.TextStyle(fontSize: 7.5, color: textDark)),
                      pw.Text('VERIFICATION: All Modules Tested & Verified', style: pw.TextStyle(fontSize: 7.5, color: successGreen)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('TRAINING & PLACEMENT CELL', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      pw.Text('CAMPUS PLACEMENT CONVENOR', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                      pw.Text('Gandhigram, Tamil Nadu - 624 302', style: pw.TextStyle(fontSize: 7.5, color: textMuted)),
                    ],
                  ),
                ],
              ),
            ),
            pw.Spacer(),
            buildFooter(context),
          ],
        );
      },
    ),
  );

  // Write PDF to Disk
  final outputPath = 'docs/PlaceTrack_Project_Documentation.pdf';
  final outputFile = File(outputPath);
  print('Saving PDF bytes to $outputPath...');
  final pdfBytes = await pdf.save();
  await outputFile.writeAsBytes(pdfBytes);
  print('Successfully created PlaceTrack Project Documentation PDF at: ${outputFile.absolute.path}');
  print('Total PDF size: ${(pdfBytes.length / 1024).toStringAsFixed(2)} KB');
}

// -------------------------------------------------------------
// Helper Widget Builders
// -------------------------------------------------------------

pw.TableRow _tableRow3(String c1, String c2, String c3, bool isAlternate) {
  final bg = isAlternate ? PdfColor.fromInt(0xFFF8FAFC) : PdfColors.white;
  return pw.TableRow(
    decoration: pw.BoxDecoration(color: bg),
    children: [
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c1, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor))),
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c2, style: pw.TextStyle(fontSize: 7.5, color: textDark))),
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c3, style: pw.TextStyle(fontSize: 7.5, color: textMuted))),
    ],
  );
}

pw.TableRow _tableRow2(String c1, String c2, bool isAlternate) {
  final bg = isAlternate ? PdfColor.fromInt(0xFFF8FAFC) : PdfColors.white;
  return pw.TableRow(
    decoration: pw.BoxDecoration(color: bg),
    children: [
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c1, style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor))),
      pw.Padding(padding: const pw.EdgeInsets.all(5), child: pw.Text(c2, style: pw.TextStyle(fontSize: 7.5, color: textDark))),
    ],
  );
}

pw.Widget _archLayerBox(String title, List<String> items, PdfColor color) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(7),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border.all(color: color, width: 1.2),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(color: color, fontSize: 8.5, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 3),
        pw.Wrap(
          spacing: 6,
          runSpacing: 2,
          children: items.map((item) => pw.Text('• $item', style: pw.TextStyle(fontSize: 7.5, color: textDark))).toList(),
        ),
      ],
    ),
  );
}

pw.Widget _modelCard({required String title, required PdfColor color, required List<String> fields}) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(7),
    decoration: pw.BoxDecoration(
      color: bgLight,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      border: pw.Border(left: pw.BorderSide(color: color, width: 3.5)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
        pw.SizedBox(height: 3),
        ...fields.map((f) => pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 1.5),
          child: pw.Text('  • $f', style: pw.TextStyle(fontSize: 7.5, color: textDark)),
        )),
      ],
    ),
  );
}

pw.Widget _flowStepCard(String stepTitle, String description, PdfColor color) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: pw.BoxDecoration(
      color: PdfColors.white,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(stepTitle, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 8)),
        pw.SizedBox(height: 1),
        pw.Text(description, style: pw.TextStyle(color: textDark, fontSize: 7.5)),
      ],
    ),
  );
}

pw.Widget _metricBox(String label, String value, PdfColor color) {
  return pw.Expanded(
    child: pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 5, horizontal: 4),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
        border: pw.Border.all(color: cardBorder),
      ),
      child: pw.Column(
        children: [
          pw.Text(value, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 10)),
          pw.SizedBox(height: 1),
          pw.Text(label, style: pw.TextStyle(color: textMuted, fontSize: 5.5, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.center),
        ],
      ),
    ),
  );
}

pw.Widget _featureCard(String title, String desc, PdfColor color) {
  return pw.Container(
    padding: const pw.EdgeInsets.all(8),
    decoration: pw.BoxDecoration(
      color: bgLight,
      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(5)),
      border: pw.Border(top: pw.BorderSide(color: color, width: 3)),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title, style: pw.TextStyle(color: color, fontWeight: pw.FontWeight.bold, fontSize: 8.5)),
        pw.SizedBox(height: 3),
        pw.Text(desc, style: pw.TextStyle(color: textDark, fontSize: 7.5, lineSpacing: 1.2)),
      ],
    ),
  );
}
