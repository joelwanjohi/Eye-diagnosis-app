import 'dart:html' as html;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/diagnosis_model.dart';
import '../models/user_model.dart';
import 'date_formatter.dart';

class ExportUtils {
  // Export users to CSV
  static void exportUsersToCSV(List<UserModel> users) {
    final data = [
      // Header row
      ['ID', 'Email', 'Admin', 'Created At', 'Name', 'Phone', 'Diagnosis Count']
    ];

    // Add user data
    for (var user in users) {
      data.add([
        user.id,
        user.email,
        user.isAdmin.toString(),
        user.createdAt,
        user.name ?? 'N/A',
        user.phone ?? 'N/A',
        user.diagnosisCount.toString(),
      ]);
    }

    // Convert to CSV
    final csvContent = _convertToCSV(data);
    _downloadFile(csvContent, 'users_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  // Export diagnoses to CSV
  static void exportDiagnosesToCSV(List<DiagnosisModel> diagnoses) {
    final data = [
      // Header row
      ['ID', 'User ID', 'Date', 'Patient Name', 'Patient Email', 'Diagnoses', 'Confidence']
    ];

    // Add diagnosis data
    for (var diagnosis in diagnoses) {
      for (var item in diagnosis.diagnosisList) {
        data.add([
          diagnosis.id,
          diagnosis.userId,
          DateFormatter.formatISOToLocal(diagnosis.date),
          diagnosis.patientName ?? 'N/A',
          diagnosis.patientEmail ?? 'N/A',
          item.name,
          (item.confidence * 100).toStringAsFixed(2) + '%',
        ]);
      }
    }

    // Convert to CSV
    final csvContent = _convertToCSV(data);
    _downloadFile(csvContent, 'diagnoses_export_${DateTime.now().millisecondsSinceEpoch}.csv');
  }

  // Convert data to CSV
  static String _convertToCSV(List<List<dynamic>> data) {
    return data.map((row) => row.map((cell) => 
      '"${cell.toString().replaceAll('"', '""')}"'
    ).join(',')).join('\n');
  }

  // Download file
  static void _downloadFile(String content, String filename) {
    final bytes = content.codeUnits;
    final blob = html.Blob([bytes], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  // Generate enhanced PDF report for diagnoses
  static Future<void> generateDiagnosisReport(
    List<DiagnosisModel> diagnoses, 
    {DateTime? startDate, DateTime? endDate}
  ) async {
    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: await PdfGoogleFonts.openSansRegular(),
        bold: await PdfGoogleFonts.openSansBold(),
        italic: await PdfGoogleFonts.openSansItalic(),
      ),
    );

    // Custom colors
    final brandColor = PdfColor.fromHex('#4285F4');
    final accentColor = PdfColor.fromHex('#34A853');
    final lightBg = PdfColor.fromHex('#F8F9FA');
    
    // Load fonts
    final fontRegular = await PdfGoogleFonts.openSansRegular();
    final fontBold = await PdfGoogleFonts.openSansBold();
    final fontMedium = await PdfGoogleFonts.openSansSemiBold();
    final fontLight = await PdfGoogleFonts.openSansLight();
    
    // Calculate analytics
    final totalDiagnoses = diagnoses.length;
    final totalPatients = diagnoses.map((d) => d.patientEmail).toSet().length;
    
    // Group diagnoses by condition
    final Map<String, int> conditionsCount = {};
    for (final diagnosis in diagnoses) {
      for (final item in diagnosis.diagnosisList) {
        if (conditionsCount.containsKey(item.name)) {
          conditionsCount[item.name] = conditionsCount[item.name]! + 1;
        } else {
          conditionsCount[item.name] = 1;
        }
      }
    }
    
    // Sort conditions by frequency
    final sortedConditions = conditionsCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Group diagnoses by date
    final Map<String, List<DiagnosisModel>> byDate = {};
    for (final diagnosis in diagnoses) {
      final dateStr = diagnosis.date.split('T')[0];
      if (!byDate.containsKey(dateStr)) {
        byDate[dateStr] = [];
      }
      byDate[dateStr]?.add(diagnosis);
    }
    
    // Generate cover page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // Background design
              pw.Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: pw.Container(
                  height: 180,
                  color: brandColor,
                ),
              ),
              
              // Content
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.SizedBox(height: 100),
                  pw.Container(
                    margin: const pw.EdgeInsets.symmetric(horizontal: 40),
                    padding: const pw.EdgeInsets.all(30),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.white,
                      borderRadius: pw.BorderRadius.circular(8),
                      boxShadow: [
                        pw.BoxShadow(
                          color: PdfColor(0, 0, 0, 0.2), // 20% opacity (0.2 * 255 = 51)
                          blurRadius: 5,
                          offset: const PdfPoint(0, 3),
                        ),
                      ],
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'EyeCheckAI',
                          style: pw.TextStyle(
                            font: fontBold,
                            fontSize: 40,
                            color: brandColor,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          'DIAGNOSIS REPORT',
                          style: pw.TextStyle(
                            font: fontMedium,
                            fontSize: 18,
                            letterSpacing: 3,
                            color: PdfColors.black,
                          ),
                        ),
                        pw.SizedBox(height: 25),
                        pw.Container(
                          width: 100,
                          decoration: const pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey300, width: 2),
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 25),
                        _buildInfoRow('Generated on:', DateFormatter.formatDate(DateTime.now()), fontRegular, fontMedium),
                        pw.SizedBox(height: 8),
                        if (startDate != null && endDate != null)
                          _buildInfoRow(
                            'Date Range:',
                            '${DateFormatter.formatDate(startDate)} - ${DateFormatter.formatDate(endDate)}',
                            fontRegular,
                            fontMedium
                          ),
                        pw.SizedBox(height: 30),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildStatBox('Total Diagnoses', totalDiagnoses.toString(), accentColor, fontLight, fontBold),
                            _buildStatBox('Unique Patients', totalPatients.toString(), brandColor, fontLight, fontBold),
                          ],
                        ),
                      ],
                    ),
                  ),
                  pw.Spacer(),
                  pw.Container(
                    alignment: pw.Alignment.centerRight,
                    padding: const pw.EdgeInsets.only(right: 30, bottom: 20),
                    child: pw.Text(
                      'CONFIDENTIAL MEDICAL INFORMATION',
                      style: pw.TextStyle(font: fontLight, fontSize: 9, color: PdfColors.grey700),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
    
    // Summary page with analytics
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader('Summary & Analytics', fontBold, brandColor),
              pw.SizedBox(height: 20),
              
              // Most common conditions
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Most Common Conditions',
                      style: pw.TextStyle(font: fontMedium, fontSize: 14, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(height: 1, color: PdfColors.grey300),
                    pw.SizedBox(height: 10),
                    ...sortedConditions.take(5).map((entry) {
                      final percentage = (entry.value / totalDiagnoses * 100).toStringAsFixed(1);
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 8),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                              children: [
                                pw.Text(
                                  entry.key,
                                  style: pw.TextStyle(font: fontRegular, fontSize: 12),
                                ),
                                pw.Text(
                                  '$percentage% (${entry.value})',
                                  style: pw.TextStyle(font: fontBold, fontSize: 12),
                                ),
                              ],
                            ),
                            pw.SizedBox(height: 4),
                            pw.ClipRect(
                              child: pw.Container(
                                height: 8,
                                decoration: pw.BoxDecoration(
                                  color: PdfColors.grey200,
                                  borderRadius: pw.BorderRadius.circular(4),
                                ),
                                child: pw.Align(
                                  alignment: pw.Alignment.centerLeft,
                                  child: pw.Container(
                                    width: double.parse(percentage) * 5, // Scale the width
                                    decoration: pw.BoxDecoration(
                                      color: accentColor,
                                      borderRadius: pw.BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
              
              pw.SizedBox(height: 20),
              
              // Time distribution
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: lightBg,
                  borderRadius: pw.BorderRadius.circular(5),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Diagnoses by Date',
                      style: pw.TextStyle(font: fontMedium, fontSize: 14, color: PdfColors.black),
                    ),
                    pw.SizedBox(height: 10),
                    pw.Container(height: 1, color: PdfColors.grey300),
                    pw.SizedBox(height: 10),
                    pw.Table(
                      border: null,
                      tableWidth: pw.TableWidth.max,
                      children: [
                        pw.TableRow(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(color: PdfColors.grey300, width: 1),
                            ),
                          ),
                          children: [
                            _buildTableCell('Date', fontMedium, isHeader: true),
                            _buildTableCell('Count', fontMedium, isHeader: true, alignment: pw.Alignment.centerRight),
                          ],
                        ),
                        ...byDate.entries.take(10).map((entry) {
                          return pw.TableRow(
                            children: [
                              _buildTableCell(entry.key, fontRegular),
                              _buildTableCell('${entry.value.length}', fontRegular, alignment: pw.Alignment.centerRight),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ],
                ),
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  'Page ${context.pageNumber} of ${context.pagesCount}',
                  style: pw.TextStyle(font: fontLight, fontSize: 10, color: PdfColors.grey),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Add detailed diagnoses pages
    for (final date in byDate.keys.toList()..sort()) {
      final dayDiagnoses = byDate[date]!;
      
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                _buildHeader('Diagnoses for $date', fontBold, brandColor),
                pw.SizedBox(height: 5),
                pw.Text(
                  '${dayDiagnoses.length} diagnoses recorded',
                  style: pw.TextStyle(font: fontLight, fontSize: 10, color: PdfColors.grey700),
                ),
                pw.SizedBox(height: 15),
                pw.Expanded(
                  child: pw.ListView.builder(
                    itemCount: dayDiagnoses.length,
                    itemBuilder: (context, index) {
                      final diagnosis = dayDiagnoses[index];
                      
                      // Calculate highest confidence diagnosis
                      var highestConfidence = diagnosis.diagnosisList.isEmpty 
                          ? null 
                          : diagnosis.diagnosisList.reduce((a, b) => 
                              a.confidence > b.confidence ? a : b);
                      
                      return pw.Container(
                        margin: const pw.EdgeInsets.only(bottom: 15),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey300),
                          borderRadius: pw.BorderRadius.circular(5),
                        ),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            // Header
                            pw.Container(
                              padding: const pw.EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: pw.BoxDecoration(
                                color: lightBg,
                                borderRadius: pw.BorderRadius.vertical(
                                  top: pw.Radius.circular(4),
                                ),
                              ),
                              child: pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                                children: [
                                  pw.Expanded(
                                    child: pw.Column(
                                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                                      children: [
                                        pw.Text(
                                          diagnosis.patientName ?? 'Unnamed Patient',
                                          style: pw.TextStyle(font: fontMedium, fontSize: 14),
                                        ),
                                        if (diagnosis.patientEmail != null)
                                          pw.Text(
                                            diagnosis.patientEmail!,
                                            style: pw.TextStyle(font: fontLight, fontSize: 10),
                                          ),
                                      ],
                                    ),
                                  ),
                                  pw.Text(
                                    DateFormatter.formatISOToLocal(diagnosis.date).split(' ')[1],
                                    style: pw.TextStyle(font: fontRegular, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Main content
                            pw.Container(
                              padding: const pw.EdgeInsets.all(15),
                              child: pw.Column(
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  // Primary diagnosis highlighted
                                  if (highestConfidence != null)
                                    pw.Container(
                                      width: double.infinity,
                                      padding: const pw.EdgeInsets.all(10),
                                      margin: const pw.EdgeInsets.only(bottom: 10),
                                      decoration: pw.BoxDecoration(
                                        color: PdfColor.fromHex('#34A853').shade(0.9), // Very light shade (10% opacity)
                                        borderRadius: pw.BorderRadius.circular(4),
                                        border: pw.Border.all(
                                          color: PdfColor.fromHex('#34A853').shade(0.7), // Slightly darker shade (30% opacity)
                                          width: 1,
                                        ),
                                      ),
                                      child: pw.Column(
                                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Text(
                                            'Primary Diagnosis',
                                            style: pw.TextStyle(
                                              font: fontLight,
                                              fontSize: 10,
                                              color: PdfColors.grey700,
                                            ),
                                          ),
                                          pw.SizedBox(height: 3),
                                          pw.Text(
                                            highestConfidence.name,
                                            style: pw.TextStyle(
                                              font: fontBold,
                                              fontSize: 14,
                                              color: accentColor,
                                            ),
                                          ),
                                          pw.SizedBox(height: 5),
                                          pw.Row(
                                            children: [
                                              pw.Text(
                                                'Confidence: ',
                                                style: pw.TextStyle(font: fontRegular, fontSize: 11),
                                              ),
                                              pw.Text(
                                                '${(highestConfidence.confidence * 100).toStringAsFixed(1)}%',
                                                style: pw.TextStyle(font: fontBold, fontSize: 11),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  
                                  // All diagnoses
                                  pw.Text(
                                    'All Detected Conditions',
                                    style: pw.TextStyle(font: fontMedium, fontSize: 12),
                                  ),
                                  pw.SizedBox(height: 5),
                                  
                                  // Diagnoses table
                                  pw.Table(
                                    border: null,
                                    columnWidths: {
                                      0: const pw.FlexColumnWidth(3),
                                      1: const pw.FlexColumnWidth(1),
                                    },
                                    children: [
                                      // Header row
                                      pw.TableRow(
                                        decoration: pw.BoxDecoration(
                                          border: pw.Border(
                                            bottom: pw.BorderSide(color: PdfColors.grey300),
                                          ),
                                        ),
                                        children: [
                                          _buildTableCell('Condition', fontLight, isHeader: true, fontSize: 10),
                                          _buildTableCell('Confidence', fontLight, isHeader: true, alignment: pw.Alignment.centerRight, fontSize: 10),
                                        ],
                                      ),
                                      
                                      // Data rows
                                      ...diagnosis.diagnosisList
                                        .asMap()
                                        .entries
                                        .map((entry) {
                                          final item = entry.value;
                                          final isEven = entry.key % 2 == 0;
                                          
                                          return pw.TableRow(
                                            decoration: pw.BoxDecoration(
                                              color: isEven ? PdfColors.white : lightBg.shade(0.5),
                                            ),
                                            children: [
                                              _buildTableCell(
                                                item.name, 
                                                fontRegular, 
                                                fontSize: 11,
                                                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                              ),
                                              _buildTableCell(
                                                '${(item.confidence * 100).toStringAsFixed(1)}%',
                                                item == highestConfidence ? fontBold : fontRegular,
                                                fontSize: 11,
                                                alignment: pw.Alignment.centerRight,
                                                padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                                              ),
                                            ],
                                          );
                                        }).toList(),
                                    ],
                                  ),
                                  
                                  // ID information at bottom
                                  pw.SizedBox(height: 10),
                                  pw.Container(
                                    alignment: pw.Alignment.centerRight,
                                    child: pw.Text(
                                      'Diagnosis ID: ${diagnosis.id}',
                                      style: pw.TextStyle(font: fontLight, fontSize: 8, color: PdfColors.grey),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // Footer with page number
                pw.Container(
                  margin: const pw.EdgeInsets.only(top: 10),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Page ${context.pageNumber} of ${context.pagesCount}',
                    style: pw.TextStyle(font: fontLight, fontSize: 10, color: PdfColors.grey),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    await Printing.sharePdf(bytes: await pdf.save(), filename: 'eyecheck_diagnosis_report.pdf');
  }
  
  // Helper methods for PDF generation
  static pw.Widget _buildHeader(String title, pw.Font font, PdfColor color) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 5),
      decoration: pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: color, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(font: font, fontSize: 18, color: color),
          ),
          pw.Text(
            'EyeCheckAI',
            style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildInfoRow(String label, String value, pw.Font regularFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.center,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(font: regularFont, fontSize: 12, color: PdfColors.grey700),
        ),
        pw.SizedBox(width: 5),
        pw.Text(
          value,
          style: pw.TextStyle(font: boldFont, fontSize: 12),
        ),
      ],
    );
  }
  
  static pw.Widget _buildStatBox(String label, String value, PdfColor color, pw.Font lightFont, pw.Font boldFont) {
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      decoration: pw.BoxDecoration(
        color: color.shade(0.9), // Light shade of the color (10% opacity)
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: color.shade(0.7)), // Slightly darker shade (30% opacity)
      ),
      child: pw.Column(
        children: [
          pw.Text(
            value,
            style: pw.TextStyle(font: boldFont, fontSize: 24, color: color),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            label,
            style: pw.TextStyle(font: lightFont, fontSize: 10, color: PdfColors.grey800),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  static pw.Widget _buildTableCell(
    String text, 
    pw.Font font, {
    bool isHeader = false, 
    pw.Alignment alignment = pw.Alignment.centerLeft,
    double fontSize = 12,
    pw.EdgeInsets padding = const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
  }) {
    return pw.Padding(
      padding: padding,
      child: pw.Align(
        alignment: alignment,
        child: pw.Text(
          text,
          style: pw.TextStyle(
            font: font,
            fontSize: fontSize,
            color: isHeader ? PdfColors.grey700 : PdfColors.black,
          ),
        ),
      ),
    );
  }
}