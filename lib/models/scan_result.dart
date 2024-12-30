class ScanResult {
  final int port;
  final bool isVulnerable;
  final String description;
  final String service;
  final String risk;

  ScanResult({
    required this.port,
    required this.isVulnerable,
    required this.description,
    required this.service,
    required this.risk,
  });
}