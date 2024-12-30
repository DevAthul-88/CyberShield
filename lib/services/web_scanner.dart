// lib/services/web_scanner.dart

import 'package:http/http.dart' as http;
import 'dart:async';
import '../models/vulnerability.dart';
import '../models/scan_config.dart';

class WebScanner {
  final ScanConfig config;

  WebScanner({required this.config});

  Future<List<Vulnerability>> scanUrl(String url) async {
    List<Vulnerability> vulnerabilities = [];
    
    try {
      if (config.checkHeaders) {
        var headerVulns = await _checkSecurityHeaders(url);
        vulnerabilities.addAll(headerVulns);
      }

      if (config.checkSSL) {
        var sslVulns = await _checkSSL(url);
        vulnerabilities.addAll(sslVulns);
      }

      if (config.checkXSS) {
        var xssVulns = await _checkXSS(url);
        vulnerabilities.addAll(xssVulns);
      }

      if (config.checkSQLi) {
        var sqliVulns = await _checkSQLInjection(url);
        vulnerabilities.addAll(sqliVulns);
      }

      if (config.checkCSRF) {
        var csrfVulns = await _checkCSRF(url);
        vulnerabilities.addAll(csrfVulns);
      }

    } catch (e) {
      vulnerabilities.add(Vulnerability(
        title: 'Scan Error',
        type: 'Error',
        description: 'Scan error occurred',
        severity: 'High',
        url: url,
        details: {'error': e.toString()},
        solution: 'Check URL and try again',
        recommendation: 'Verify the URL is accessible and try scanning again. If the error persists, check your network connection.',
      ));
    }

    return vulnerabilities;
  }

  Future<List<Vulnerability>> _checkSecurityHeaders(String url) async {
    List<Vulnerability> vulnerabilities = [];
    final response = await http.get(Uri.parse(url));
    
    final headers = response.headers;
    final requiredHeaders = {
      'X-Frame-Options': 'Missing X-Frame-Options header - Clickjacking possible',
      'X-Content-Type-Options': 'Missing X-Content-Type-Options header - MIME-sniffing possible',
      'Strict-Transport-Security': 'Missing HSTS header - Protocol downgrade possible',
      'Content-Security-Policy': 'Missing CSP header - Various injection attacks possible',
    };

    requiredHeaders.forEach((header, message) {
      if (!headers.containsKey(header.toLowerCase())) {
        vulnerabilities.add(Vulnerability(
          title: 'Missing $header',
          type: 'Missing Security Header',
          description: message,
          severity: 'Medium',
          url: url,
          details: {'header': header},
          solution: 'Add the ${header} header to server responses',
          recommendation: 'Configure your web server to include the ${header} header in all responses to prevent potential security vulnerabilities.',
        ));
      }
    });

    return vulnerabilities;
  }

  Future<List<Vulnerability>> _checkSSL(String url) async {
    List<Vulnerability> vulnerabilities = [];
    if (!url.startsWith('https://')) {
      vulnerabilities.add(Vulnerability(
        title: 'Insecure Protocol (HTTP)',
        type: 'Insecure Protocol',
        description: 'Site is not using HTTPS',
        severity: 'High',
        url: url,
        details: {'protocol': 'HTTP'},
        solution: 'Implement HTTPS using a valid SSL/TLS certificate',
        recommendation: 'Purchase and install an SSL certificate from a trusted provider and ensure all traffic is redirected to HTTPS.',
      ));
    }
    return vulnerabilities;
  }

  Future<List<Vulnerability>> _checkXSS(String url) async {
    List<Vulnerability> vulnerabilities = [];
    final testPayloads = [
      '<script>alert(1)</script>',
      '"><script>alert(1)</script>',
      'javascript:alert(1)',
    ];

    for (var payload in testPayloads) {
      final testUrl = '$url?test=$payload';
      final response = await http.get(Uri.parse(testUrl));
      
      if (response.body.contains(payload)) {
        vulnerabilities.add(Vulnerability(
          title: 'Cross-Site Scripting (XSS)',
          type: 'XSS',
          description: 'Possible Cross-Site Scripting vulnerability found',
          severity: 'High',
          url: testUrl,
          details: {
            'payload': payload,
            'reflection_found': true,
          },
          solution: 'Implement proper input validation and output encoding',
          recommendation: 'Sanitize all user input and encode all output. Consider using a security library or framework that handles XSS protection automatically.',
        ));
        break;
      }
    }
    return vulnerabilities;
  }

  Future<List<Vulnerability>> _checkSQLInjection(String url) async {
    List<Vulnerability> vulnerabilities = [];
    final testPayloads = [
      "' OR '1'='1",
      "1' OR '1'='1",
      "1; DROP TABLE users--",
    ];

    for (var payload in testPayloads) {
      final testUrl = '$url?id=$payload';
      final response = await http.get(Uri.parse(testUrl));
      
      if (response.body.contains('SQL') && 
          response.body.contains('error')) {
        vulnerabilities.add(Vulnerability(
          title: 'SQL Injection Vulnerability',
          type: 'SQL Injection',
          description: 'Possible SQL Injection vulnerability found',
          severity: 'Critical',
          url: testUrl,
          details: {
            'payload': payload,
            'error_detected': true,
          },
          solution: 'Use parameterized queries and implement proper input validation',
          recommendation: 'Replace dynamic SQL queries with prepared statements or an ORM. Never concatenate user input directly into SQL queries.',
        ));
        break;
      }
    }
    return vulnerabilities;
  }

  Future<List<Vulnerability>> _checkCSRF(String url) async {
    List<Vulnerability> vulnerabilities = [];
    final response = await http.get(Uri.parse(url));
    
    if (response.body.contains('<form') && 
        !response.body.toLowerCase().contains('csrf')) {
      vulnerabilities.add(Vulnerability(
        title: 'CSRF Protection Missing',
        type: 'CSRF',
        description: 'No CSRF protection detected in forms',
        severity: 'High',
        url: url,
        details: {
          'forms_found': true,
          'csrf_token_found': false,
        },
        solution: 'Implement CSRF tokens in all forms',
        recommendation: 'Add CSRF token validation to all forms. Generate unique tokens for each session and verify them on form submission.',
      ));
    }
    return vulnerabilities;
  }
}