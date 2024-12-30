// lib/utils/ip_validator.dart
class IPValidator {
  static String? validateIP(String? ip) {
    if (ip == null || ip.isEmpty) {
      return 'IP address is required';
    }

    final ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    );

    if (!ipRegex.hasMatch(ip)) {
      return 'Invalid IP address format';
    }

    return null;
  }

  static String? validatePortRange(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port range is required';
    }

    final parts = value.split('-');
    try {
      if (parts.length == 1) {
        int port = int.parse(parts[0]);
        if (port < 1 || port > 65535) {
          return 'Port must be between 1 and 65535';
        }
      } else if (parts.length == 2) {
        int start = int.parse(parts[0]);
        int end = int.parse(parts[1]);
        if (start < 1 || start > 65535 || end < 1 || end > 65535) {
          return 'Ports must be between 1 and 65535';
        }
        if (start >= end) {
          return 'Start port must be less than end port';
        }
      } else {
        return 'Invalid port range format';
      }
    } catch (e) {
      return 'Invalid port format';
    }
    return null;
  }
}