import 'dart:io';
import '../models/scan_result.dart';

class SecurityScanner {
  Future<List<ScanResult>> scanTarget(
    String ip,
    int startPort,
    int endPort,
  ) async {
    List<ScanResult> results = [];
    
    for (int port = startPort; port <= endPort; port++) {
      try {
        final socket = await Socket.connect(ip, port,
            timeout: const Duration(seconds: 1));
        await socket.close();
        
        final serviceInfo = _getServiceInfo(port);
        results.add(ScanResult(
          port: port,
          isVulnerable: serviceInfo['vulnerable'] as bool,
          description: serviceInfo['description'] as String,
          service: serviceInfo['service'] as String,
          risk: serviceInfo['risk'] as String,
        ));
      } catch (e) {
        // Port is closed or filtered
        continue;
      }
    }
    
    return results;
  }

  Map<String, dynamic> _getServiceInfo(int port) {
    switch (port) {
      case 21:
        return {
          'service': 'FTP',
          'description': 'File Transfer Protocol - Unencrypted file transfer service',
          'vulnerable': true,
          'risk': 'High - Clear text authentication and data transfer',
        };
      case 22:
        return {
          'service': 'SSH',
          'description': 'Secure Shell - Encrypted remote access service',
          'vulnerable': false,
          'risk': 'Low - Encrypted communications',
        };
      case 23:
        return {
          'service': 'Telnet',
          'description': 'Telnet - Legacy remote access protocol',
          'vulnerable': true,
          'risk': 'Critical - Clear text authentication and commands',
        };
      case 25:
        return {
          'service': 'SMTP',
          'description': 'Simple Mail Transfer Protocol - Email routing service',
          'vulnerable': true,
          'risk': 'Medium - Potential for email spoofing',
        };
      case 80:
        return {
          'service': 'HTTP',
          'description': 'Web Server - Unencrypted web traffic',
          'vulnerable': true,
          'risk': 'Medium - Clear text data transmission',
        };
      case 443:
        return {
          'service': 'HTTPS',
          'description': 'Secure Web Server - Encrypted web traffic',
          'vulnerable': false,
          'risk': 'Low - Encrypted communications',
        };
      case 3306:
        return {
          'service': 'MySQL',
          'description': 'MySQL Database Server',
          'vulnerable': true,
          'risk': 'High - Direct database access if misconfigured',
        };
      case 3389:
        return {
          'service': 'RDP',
          'description': 'Remote Desktop Protocol - Windows remote access',
          'vulnerable': true,
          'risk': 'High - Potential for brute force attacks',
        };
      default:
        return {
          'service': 'Unknown',
          'description': 'Unknown Service',
          'vulnerable': true,
          'risk': 'Medium - Unidentified service',
        };
    }
  }
}
