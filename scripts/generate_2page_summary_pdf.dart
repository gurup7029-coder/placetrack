import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  print('Starting PlaceTrack 2-Page Summary PDF generation...');
  final pdf = pw.Document();

  final primaryColor = PdfColor.fromInt(0xFF1E3A8A); // Deep Slate Navy
  final accentBlue = PdfColor.fromInt(0xFF2563EB); // Royal Blue
  final successGreen = PdfColor.fromInt(0xFF059669); // Forest Emerald
  final darkText = PdfColor.fromInt(0xFF0F172A); // Slate 900
  final bodyText = PdfColor.fromInt(0xFF334155); // Slate 700
  final lightBg = PdfColor.fromInt(0xFFF8FAFC); // Slate 50
  final borderSubtle = PdfColor.fromInt(0xFFE2E8F0); // Slate 200
  final cardHeaderBg = PdfColor.fromInt(0xFFEFF6FF); // Blue 50

  final pageTheme = pw.PageTheme(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 32, vertical: 28),
    buildBackground: (pw.Context context) {
      return pw.FullPage(
        ignoreMargins: true,
        child: pw.Container(
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: borderSubtle, width: 1),
          ),
        ),
      );
    },
  );

  pw.Widget buildHeader(String sectionTitle) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 6),
      margin: const pw.EdgeInsets.only(bottom: 10),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: borderSubtle, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Container(
                width: 7,
                height: 7,
                decoration: pw.BoxDecoration(color: primaryColor, shape: pw.BoxShape.circle),
              ),
              pw.SizedBox(width: 5),
              pw.Text(
                'PLACETRACK - CAMPUS RECRUITMENT & CAREER AUTOMATION SYSTEM',
                style: pw.TextStyle(color: primaryColor, fontSize: 7.5, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
          pw.Text(
            sectionTitle.toUpperCase(),
            style: pw.TextStyle(color: bodyText, fontSize: 7.5, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  pw.Widget buildFooter(int pageNum) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 6),
      margin: const pw.EdgeInsets.only(top: 8),
      decoration: pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: borderSubtle, width: 1)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Confidential - College Placement Cell & Academic Project Evaluation',
            style: pw.TextStyle(color: bodyText, fontSize: 7),
          ),
          pw.Text(
            'Page $pageNum of 2',
            style: pw.TextStyle(color: primaryColor, fontSize: 7, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // PAGE 1: TITLE, ABSTRACT, SUMMARY & ARCHITECTURE
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Executive Summary & Abstract'),

            // Hero Title Box
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                border: pw.Border.all(color: borderSubtle, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'PLACETRACK: CAMPUS PLACEMENT SYSTEM',
                        style: pw.TextStyle(
                          color: primaryColor,
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 3),
                      pw.Text(
                        'Project Completion Report, Executive Summary, Abstract & Architecture',
                        style: pw.TextStyle(color: bodyText, fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: pw.BoxDecoration(
                      color: successGreen,
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Text(
                      'STATUS: 100% COMPLETE',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 8, fontWeight: pw.FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Metadata Grid
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderSubtle),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Target Domain:', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                      pw.Text('Higher Education / Recruitment', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkText)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Platform Architecture:', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                      pw.Text('Flutter (Dart 3.x) Cross-Platform', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkText)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Target & Tested Device:', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                      pw.Text('Vivo I2221 (Android 16 / API 36)', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: darkText)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Code Quality Audit:', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                      pw.Text('0 Errors / 0 Warnings (Passed)', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: successGreen)),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Section 1: Abstract
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightBg,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                border: pw.Border.all(color: borderSubtle),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 3, height: 10, color: accentBlue),
                      pw.SizedBox(width: 5),
                      pw.Text('1. PROJECT ABSTRACT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    'Campus placement operations in higher education institutions typically struggle with fragmented communication, manual candidate eligibility verification, delayed stage feedback, and opaque recruitment metrics. PlaceTrack is an enterprise-grade campus placement and career management system built with Flutter and Dart. The platform creates a unified digital bridge connecting students, training coordinators, and Training & Placement Officers (TPOs). Core capabilities include automated eligibility filtering (CGPA, active backlogs, department matching), multi-stage drive tracking with exact round timestamps, real-time dynamic placement analytics, and an interactive celebration physics engine. Tested and deployed directly on physical Android 16 hardware, PlaceTrack accelerates recruitment turnaround, eliminates manual spreadsheet tracking, and delivers complete institutional transparency.',
                    style: pw.TextStyle(fontSize: 8, height: 1.35, color: bodyText),
                    textAlign: pw.TextAlign.justify,
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Section 2: Executive Summary & Objectives
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderSubtle),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 3, height: 10, color: primaryColor),
                      pw.SizedBox(width: 5),
                      pw.Text('2. EXECUTIVE SUMMARY & ACHIEVED OBJECTIVES', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• Automated Eligibility Engine:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('Instant verification of CGPA and backlog thresholds prevents unauthorized registrations.', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                            pw.SizedBox(height: 4),
                            pw.Text('• End-to-End Recruitment Pipeline:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('Orchestrates applicant enrollment, multi-round technical assessments, and final offer letters.', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• Dynamic Real-Time Analytics:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('Live computation of placement ratios, average/highest CTC, and department conversion funnels.', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                            pw.SizedBox(height: 4),
                            pw.Text('• Interactive Morale Boosting:', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('Foreground rocket and particle burst simulation celebrating student offer letter unlocks.', style: pw.TextStyle(fontSize: 7.5, color: bodyText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 10),

            // Section 3: High-Level Platform Architecture & Workflow
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                color: lightBg,
                border: pw.Border.all(color: borderSubtle),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 3, height: 10, color: accentBlue),
                      pw.SizedBox(width: 5),
                      pw.Text('3. ARCHITECTURE & SYSTEM WORKFLOW', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    children: [
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(color: borderSubtle),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('[STUDENT PORTAL]', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.Text('1. View Eligible Drives', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('2. One-Click Enrollment', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('3. Resume PDF Upload', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('4. Mock Tests & Preparation', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('5. Offer Letter & Badge', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(color: cardHeaderBg, shape: pw.BoxShape.circle),
                        child: pw.Text('SYNC', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: accentBlue)),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(color: borderSubtle),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('[CENTRAL DATA SERVICE]', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: successGreen)),
                              pw.Text('• PlacementDataService Singleton', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('• ChangeNotifier Reactive State', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('• Real-Time Metrics Engine', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('• Exact Timestamps Audit Log', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('• Offline-Ready Architecture', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                            ],
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Container(
                        padding: const pw.EdgeInsets.all(4),
                        decoration: pw.BoxDecoration(color: cardHeaderBg, shape: pw.BoxShape.circle),
                        child: pw.Text('SYNC', style: pw.TextStyle(fontSize: 6.5, fontWeight: pw.FontWeight.bold, color: accentBlue)),
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Container(
                          padding: const pw.EdgeInsets.all(6),
                          decoration: pw.BoxDecoration(
                            color: PdfColors.white,
                            border: pw.Border.all(color: borderSubtle),
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('[TPO / ADMIN PORTAL]', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                              pw.Text('1. Create & Schedule Drives', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('2. Configure Multi-Rounds', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('3. Round-by-Round Evaluation', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('4. Confirm Placed Candidates', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                              pw.Text('5. Executive Analytics Funnel', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            pw.Spacer(),
            buildFooter(1),
          ],
        );
      },
    ),
  );

  // ==========================================
  // PAGE 2: TOOLS USED, WORK COMPLETION & STATUS
  // ==========================================
  pdf.addPage(
    pw.Page(
      pageTheme: pageTheme,
      build: (pw.Context context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            buildHeader('Tools, Work Completion & Deployment Status'),

            // Section 4: Tools & Technologies Used
            pw.Row(
              children: [
                pw.Container(width: 3, height: 10, color: primaryColor),
                pw.SizedBox(width: 5),
                pw.Text('4. TOOLS & TECHNOLOGIES USED', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: borderSubtle, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: cardHeaderBg),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Category', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Tool / Library', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor))),
                    pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text('Implementation & Architectural Purpose', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: primaryColor))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Framework & Core', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Flutter SDK (3.x) & Dart 3.13+', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Single codebase rendering high-performance native UI on Android, Windows, and Web.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('UI & Theming', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Material 3 & PlaceTrackTheme', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Unified design tokens supporting dynamic, high-contrast Light and Dark mode styling.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('State Management', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('ChangeNotifier Singleton Service', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Centralized reactive state synchronizing real-time analytics, drives, and student records.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Graphics Engine', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('CustomPainter & Physics Engine', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Simulates realistic rocket trails, multi-color explosive stars, and radial shockwaves.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Document Engine', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('pdf (3.13.1) & printing (5.15.1)', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Generates authentic corporate offer letters and comprehensive PDF completion reports.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Build & Deployment', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Gradle 9.3.1 & Android SDK API 36', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Compiles native ARM64 binaries; direct streamed installation via ADB to hardware devices.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Section 5: Work Completion Audit
            pw.Row(
              children: [
                pw.Container(width: 3, height: 10, color: successGreen),
                pw.SizedBox(width: 5),
                pw.Text('5. WORK COMPLETION AUDIT & MODULE BREAKDOWN', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
              ],
            ),
            pw.SizedBox(height: 5),
            pw.Table(
              border: pw.TableBorder.all(color: borderSubtle, width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: lightBg),
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Module Name', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Implemented Capabilities', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3.5), child: pw.Text('Status', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Student Portal', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Live drive cards, enrollment, resume manager, round status tracking, offer downloads.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('TPO Drive Manager', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Drive builder, date scheduler, multi-rounds creator, CGPA filters, enrollment lists.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Multi-Round Evaluation', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Student qualification/rejection dialogs, batch actions, exact timestamp logging.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Real Dynamic Analytics', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Replaced all demo values with computed CTC, department statistics, and hiring funnel.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Explosive Celebration', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Foreground fireworks particle simulation with Placed On timestamp badge.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Aptitude & DSA Quizzes', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Timed mock tests with category selection, immediate score evaluation & explanations.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
                pw.TableRow(
                  children: [
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('High-Contrast Dark Mode', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: darkText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('Theme-aware semantic colors guaranteeing zero contrast loss on all OLED/LCD screens.', style: pw.TextStyle(fontSize: 7, color: bodyText))),
                    pw.Padding(padding: const pw.EdgeInsets.all(3), child: pw.Text('100% Complete', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: successGreen))),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Section 6: Current Project Status & Physical Device Deployment
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: lightBg,
                border: pw.Border.all(color: borderSubtle),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Container(width: 3, height: 10, color: successGreen),
                      pw.SizedBox(width: 5),
                      pw.Text('6. PROJECT STATUS & PHYSICAL DEVICE DEPLOYMENT', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                    ],
                  ),
                  pw.SizedBox(height: 4),
                  pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• Static Code Quality Audit: PASSED', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: successGreen)),
                            pw.Text('Validated with `dart analyze lib` yielding 0 issues across all 25+ source files.', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                            pw.SizedBox(height: 3),
                            pw.Text('• Android Target Device: Vivo I2221 (ARM64)', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('Running latest Android 16 (API Level 36) with full hardware acceleration enabled.', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                          ],
                        ),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('• Installation Status: SUCCESSFUL', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: successGreen)),
                            pw.Text('Streamed install verified via ADB (`adb install -r build/.../app-debug.apk`).', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                            pw.SizedBox(height: 3),
                            pw.Text('• Production Readiness: 100% READY', style: pw.TextStyle(fontSize: 7.5, fontWeight: pw.FontWeight.bold, color: darkText)),
                            pw.Text('All modules tested end-to-end; documentation artifacts compiled in /docs directory.', style: pw.TextStyle(fontSize: 7, color: bodyText)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Section 7: Conclusion & Sign-Off
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: borderSubtle),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('7. CONCLUSION & VERIFICATION SIGN-OFF', style: pw.TextStyle(fontSize: 8.5, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                        pw.SizedBox(height: 2),
                        pw.Text(
                          'PlaceTrack has met all designated system specifications, functional criteria, and quality standards. The system is certified complete, fully functional, and ready for institutional deployment.',
                          style: pw.TextStyle(fontSize: 7, color: bodyText),
                        ),
                      ],
                    ),
                  ),
                  pw.SizedBox(width: 15),
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: pw.BoxDecoration(
                      color: cardHeaderBg,
                      border: pw.Border.all(color: borderSubtle),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('COMPLETION STATUS', style: pw.TextStyle(fontSize: 6.5, color: bodyText)),
                        pw.Text('APPROVED / VERIFIED', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: primaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            pw.Spacer(),
            buildFooter(2),
          ],
        );
      },
    ),
  );

  final outputDir = Directory('docs');
  if (!outputDir.existsSync()) {
    outputDir.createSync(recursive: true);
  }

  final outputFile = File('docs/PlaceTrack_Project_Summary_Report.pdf');
  final pdfBytes = await pdf.save();
  outputFile.writeAsBytesSync(pdfBytes);
  print('Successfully generated 2-Page Summary Report at: ${outputFile.path}');
  print('Total PDF File Size: ${(outputFile.lengthSync() / 1024).toStringAsFixed(2)} KB');
}
