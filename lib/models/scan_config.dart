// lib/models/scan_config.dart

class ScanConfig {
  final bool checkXSS;
  final bool checkSQLi;
  final bool checkCSRF;
  final bool checkHeaders;
  final bool checkSSL;
  final bool checkOpenPorts;
  final bool checkDirTraversal;
  final bool checkFileInclusion;
  final bool checkCookieSecurity;
  final bool checkVersionDisclosure;
  final bool deepScan;
  final int requestDelay;
  final int timeout;
  final int maxDepth;
  final List<String> excludePaths;
  final Map<String, String> customHeaders;

  const ScanConfig({
    this.checkXSS = true,
    this.checkSQLi = true,
    this.checkCSRF = true,
    this.checkHeaders = true,
    this.checkSSL = true,
    this.checkOpenPorts = false,
    this.checkDirTraversal = false,
    this.checkFileInclusion = false,
    this.checkCookieSecurity = true,
    this.checkVersionDisclosure = true,
    this.deepScan = false,
    this.requestDelay = 500,
    this.timeout = 10000,
    this.maxDepth = 3,
    this.excludePaths = const [],
    this.customHeaders = const {},
  });

  // Copy with method for state updates
  ScanConfig copyWith({
    bool? checkXSS,
    bool? checkSQLi,
    bool? checkCSRF,
    bool? checkHeaders,
    bool? checkSSL,
    bool? checkOpenPorts,
    bool? checkDirTraversal,
    bool? checkFileInclusion,
    bool? checkCookieSecurity,
    bool? checkVersionDisclosure,
    bool? deepScan,
    int? requestDelay,
    int? timeout,
    int? maxDepth,
    List<String>? excludePaths,
    Map<String, String>? customHeaders,
  }) {
    return ScanConfig(
      checkXSS: checkXSS ?? this.checkXSS,
      checkSQLi: checkSQLi ?? this.checkSQLi,
      checkCSRF: checkCSRF ?? this.checkCSRF,
      checkHeaders: checkHeaders ?? this.checkHeaders,
      checkSSL: checkSSL ?? this.checkSSL,
      checkOpenPorts: checkOpenPorts ?? this.checkOpenPorts,
      checkDirTraversal: checkDirTraversal ?? this.checkDirTraversal,
      checkFileInclusion: checkFileInclusion ?? this.checkFileInclusion,
      checkCookieSecurity: checkCookieSecurity ?? this.checkCookieSecurity,
      checkVersionDisclosure: checkVersionDisclosure ?? this.checkVersionDisclosure,
      deepScan: deepScan ?? this.deepScan,
      requestDelay: requestDelay ?? this.requestDelay,
      timeout: timeout ?? this.timeout,
      maxDepth: maxDepth ?? this.maxDepth,
      excludePaths: excludePaths ?? this.excludePaths,
      customHeaders: customHeaders ?? this.customHeaders,
    );
  }
}