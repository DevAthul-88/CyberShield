// lib/services/report_generator.dart

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/vulnerability.dart';

enum ReportFormat { txt, json, csv, pdf, html }

class ReportGenerator {
  static String generateReport(List<Vulnerability> vulnerabilities) {
    if (vulnerabilities.isEmpty) {
      return 'No vulnerabilities found.';
    }

    final buffer = StringBuffer();
    buffer.writeln('Security Scan Report');
    buffer.writeln('===================\n');

    // Group vulnerabilities by severity
    final critical =
        vulnerabilities.where((v) => v.severity == 'Critical').toList();
    final high = vulnerabilities.where((v) => v.severity == 'High').toList();
    final medium =
        vulnerabilities.where((v) => v.severity == 'Medium').toList();
    final low = vulnerabilities.where((v) => v.severity == 'Low').toList();

    // Write summary statistics
    buffer.writeln('Summary Statistics');
    buffer.writeln('-----------------');
    buffer.writeln('Total Vulnerabilities: ${vulnerabilities.length}');
    buffer.writeln('Critical: ${critical.length}');
    buffer.writeln('High: ${high.length}');
    buffer.writeln('Medium: ${medium.length}');
    buffer.writeln('Low: ${low.length}\n');

    // Risk score calculation
    final riskScore = _calculateRiskScore(vulnerabilities);
    buffer.writeln('Overall Risk Score: $riskScore/10\n');

    // Write detailed findings
    void writeVulnerabilities(String severity, List<Vulnerability> vulns) {
      if (vulns.isNotEmpty) {
        buffer.writeln('$severity Vulnerabilities:');
        buffer.writeln('------------------------');
        for (var vuln in vulns) {
          buffer.writeln('Title: ${vuln.title}');
          buffer.writeln('Type: ${vuln.type}');
          buffer.writeln('URL: ${vuln.url}');
          buffer.writeln('Description: ${vuln.description}');
          buffer.writeln('Solution: ${vuln.solution}');
          buffer.writeln('Recommendation: ${vuln.recommendation}\n');
        }
      }
    }

    writeVulnerabilities('Critical', critical);
    writeVulnerabilities('High', high);
    writeVulnerabilities('Medium', medium);
    writeVulnerabilities('Low', low);

    return buffer.toString();
  }

  static double _calculateRiskScore(List<Vulnerability> vulnerabilities) {
    if (vulnerabilities.isEmpty) return 0;

    final weights = {
      'Critical': 10.0,
      'High': 7.0,
      'Medium': 4.0,
      'Low': 1.0,
    };

    double totalScore = 0;
    for (var vuln in vulnerabilities) {
      totalScore += weights[vuln.severity] ?? 0;
    }

    // Normalize to 0-10 scale
    return (totalScore / vulnerabilities.length).clamp(0, 10);
  }

  static Future<String> exportReport(
    List<Vulnerability> vulnerabilities,
    ReportFormat format, {
    String? outputPath,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String().replaceAll(
          RegExp(r'[:\.]'), '-'); // Ensure all invalid characters are replaced
      final fileName = 'security_scan_$timestamp';

      // Use provided output path or default to application documents directory
      if (outputPath == null) {
        final directory = await getApplicationDocumentsDirectory();
        outputPath = directory.path;
      }

      // Ensure the directory exists
      final directory = Directory(outputPath);
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Call the appropriate export method based on the format
      switch (format) {
        case ReportFormat.txt:
          return await _exportTxt(vulnerabilities, outputPath, fileName);
        case ReportFormat.json:
          return await _exportJson(vulnerabilities, outputPath, fileName);
        case ReportFormat.csv:
          return await _exportCsv(vulnerabilities, outputPath, fileName);
        case ReportFormat.pdf:
          return await _exportPdf(vulnerabilities, outputPath, fileName);
        case ReportFormat.html:
          return await _exportHtml(vulnerabilities, outputPath, fileName);
      }
    } catch (e) {
      throw Exception('Failed to export report: ${e.toString()}');
    }
  }

  static Future<String> _exportTxt(
    List<Vulnerability> vulnerabilities,
    String outputPath,
    String fileName,
  ) async {
    final report = generateReport(vulnerabilities);
    final file = File('$outputPath/${fileName}.txt');
    await file.writeAsString(report);
    return file.path;
  }

  static Future<String> _exportJson(
    List<Vulnerability> vulnerabilities,
    String outputPath,
    String fileName,
  ) async {
    final jsonData = vulnerabilities
        .map((v) => {
              'title': v.title,
              'type': v.type,
              'description': v.description,
              'severity': v.severity,
              'url': v.url,
              'details': v.details,
              'solution': v.solution,
              'recommendation': v.recommendation,
            })
        .toList();

    final file = File('$outputPath/${fileName}.json');
    await file.writeAsString(jsonEncode(jsonData));
    return file.path;
  }

  static Future<String> _exportCsv(
    List<Vulnerability> vulnerabilities,
    String outputPath,
    String fileName,
  ) async {
    final csvData = [
      [
        'Title',
        'Type',
        'Severity',
        'URL',
        'Description',
        'Solution',
        'Recommendation'
      ],
      ...vulnerabilities.map((v) => [
            v.title,
            v.type,
            v.severity,
            v.url,
            v.description,
            v.solution,
            v.recommendation,
          ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final file = File('$outputPath/${fileName}.csv');
    await file.writeAsString(csvString);
    return file.path;
  }

  static Future<String> _exportPdf(
    List<Vulnerability> vulnerabilities,
    String outputPath,
    String fileName,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text('Security Scan Report',
                style: pw.TextStyle(fontSize: 24)),
          ),
          pw.Paragraph(text: 'Generated on: ${DateTime.now()}'),
          pw.Header(level: 1, child: pw.Text('Vulnerabilities')),
          ...vulnerabilities.map((v) => pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(v.title,
                      style: pw.TextStyle(
                          fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.Text('Severity: ${v.severity}'),
                  pw.Text('Type: ${v.type}'),
                  pw.Text('URL: ${v.url}'),
                  pw.Text('Description: ${v.description}'),
                  pw.Text('Solution: ${v.solution}'),
                  pw.Text('Recommendation: ${v.recommendation}'),
                  pw.SizedBox(height: 10),
                ],
              )),
        ],
      ),
    );

    final file = File('$outputPath/${fileName}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  static Future<String> _exportHtml(
    List<Vulnerability> vulnerabilities,
    String outputPath,
    String fileName,
  ) async {
    final buffer = StringBuffer();
    buffer.writeln('''
      <!DOCTYPE html>
      <html>
      <head>
        <title>Security Scan Report</title>
        <style>
          body { font-family: Arial, sans-serif; margin: 20px; }
          .vulnerability { margin: 20px 0; padding: 10px; border: 1px solid #ccc; }
          .critical { border-left: 5px solid #ff0000; }
          .high { border-left: 5px solid #ff9900; }
          .medium { border-left: 5px solid #ffff00; }
          .low { border-left: 5px solid #00ff00; }
        </style>
      </head>
      <body>
        <h1>Security Scan Report</h1>
        <p>Generated on: ${DateTime.now()}</p>
    ''');

    for (var vuln in vulnerabilities) {
      buffer.writeln('''
        <div class="vulnerability ${vuln.severity.toLowerCase()}">
          <h2>${vuln.title}</h2>
          <p><strong>Severity:</strong> ${vuln.severity}</p>
          <p><strong>Type:</strong> ${vuln.type}</p>
          <p><strong>URL:</strong> ${vuln.url}</p>
          <p><strong>Description:</strong> ${vuln.description}</p>
          <p><strong>Solution:</strong> ${vuln.solution}</p>
          <p><strong>Recommendation:</strong> ${vuln.recommendation}</p>
        </div>
      ''');
    }

    buffer.writeln('</body></html>');

    final file = File('$outputPath/${fileName}.html');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
}
