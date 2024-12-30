import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../models/vulnerability.dart';
import '../models/scan_config.dart';
import '../services/web_scanner.dart';
import '../services/report_generator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isScanning = false;
  List<Vulnerability> _vulnerabilities = [];
  ScanConfig _scanConfig = ScanConfig();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isScanning = true;
      _vulnerabilities = [];
    });

    try {
      final scanner = WebScanner(config: _scanConfig);
      final results = await scanner.scanUrl(_urlController.text);

      setState(() {
        _vulnerabilities = results;
      });

      if (results.isEmpty) {

          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("No vulnerabilities found")),
        );
      }
    } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Scan failed: ${e.toString()}")),
        );
    } finally {
      setState(() {
        _isScanning = false;
      });
    }
  }

  void _showToast(String message,
      {bool isSuccess = false, bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: isSuccess
          ? Colors.green
          : isError
              ? Colors.red
              : Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0,
      toastLength: Toast.LENGTH_LONG,
    );
  }

  void _showConfigDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Scan Configuration'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                const Text('Security Checks',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                CheckboxListTile(
                  title: const Text('Cross-Site Scripting (XSS)'),
                  value: _scanConfig.checkXSS,
                  onChanged: (value) => setState(() {
                    _scanConfig = _scanConfig.copyWith(checkXSS: value);
                  }),
                ),
                CheckboxListTile(
                  title: const Text('SQL Injection'),
                  value: _scanConfig.checkSQLi,
                  onChanged: (value) => setState(() {
                    _scanConfig = _scanConfig.copyWith(checkSQLi: value);
                  }),
                ),
                CheckboxListTile(
                  title: const Text('CSRF Vulnerabilities'),
                  value: _scanConfig.checkCSRF,
                  onChanged: (value) => setState(() {
                    _scanConfig = _scanConfig.copyWith(checkCSRF: value);
                  }),
                ),
                CheckboxListTile(
                  title: const Text('Security Headers'),
                  value: _scanConfig.checkHeaders,
                  onChanged: (value) => setState(() {
                    _scanConfig = _scanConfig.copyWith(checkHeaders: value);
                  }),
                ),
                CheckboxListTile(
                  title: const Text('SSL/TLS'),
                  value: _scanConfig.checkSSL,
                  onChanged: (value) => setState(() {
                    _scanConfig = _scanConfig.copyWith(checkSSL: value);
                  }),
                ),
                const Divider(),
                const Text('Advanced Settings',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                ListTile(
                  title: const Text('Max Depth'),
                  subtitle: Slider(
                    value: _scanConfig.maxDepth.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: _scanConfig.maxDepth.toString(),
                    onChanged: (value) => setState(() {
                      _scanConfig =
                          _scanConfig.copyWith(maxDepth: value.toInt());
                    }),
                  ),
                ),
                ListTile(
                  title: const Text('Request Delay (ms)'),
                  subtitle: Slider(
                    value: _scanConfig.requestDelay.toDouble(),
                    min: 100,
                    max: 2000,
                    divisions: 19,
                    label: _scanConfig.requestDelay.toString(),
                    onChanged: (value) => setState(() {
                      _scanConfig =
                          _scanConfig.copyWith(requestDelay: value.toInt());
                    }),
                  ),
                ),
                ListTile(
                  title: const Text('Timeout (ms)'),
                  subtitle: Slider(
                    value: _scanConfig.timeout.toDouble(),
                    min: 5000,
                    max: 30000,
                    divisions: 25,
                    label: _scanConfig.timeout.toString(),
                    onChanged: (value) => setState(() {
                      _scanConfig =
                          _scanConfig.copyWith(timeout: value.toInt());
                    }),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        ...children,
      ],
    );
  }

  void _showReport() {
    if (_vulnerabilities.isEmpty) {
      _showToast("No vulnerabilities to report");
      return;
    }

    final report = ReportGenerator.generateReport(_vulnerabilities);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Scan Report'),
        content: SingleChildScrollView(
          child: Text(report),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigTile(String title, String configKey) {
    return SwitchListTile(
      title: Text(title),
      value: _getConfigValue(configKey),
      onChanged: (value) => _updateConfigValue(configKey, value),
      dense: true,
    );
  }

  bool _getConfigValue(String configKey) {
    switch (configKey) {
      case 'checkXSS':
        return _scanConfig.checkXSS;
      case 'checkSQLi':
        return _scanConfig.checkSQLi;
      case 'checkCSRF':
        return _scanConfig.checkCSRF;
      case 'checkHeaders':
        return _scanConfig.checkHeaders;
      case 'checkSSL':
        return _scanConfig.checkSSL;
      case 'checkDirTraversal':
        return _scanConfig.checkDirTraversal;
      case 'checkFileInclusion':
        return _scanConfig.checkFileInclusion;
      case 'checkCookieSecurity':
        return _scanConfig.checkCookieSecurity;
      case 'checkVersionDisclosure':
        return _scanConfig.checkVersionDisclosure;
      case 'deepScan':
        return _scanConfig.deepScan;
      default:
        return false;
    }
  }

  void _updateConfigValue(String configKey, dynamic value) {
    setState(() {
      _scanConfig = _scanConfig.copyWith(
        checkXSS: configKey == 'checkXSS' ? value : null,
        checkSQLi: configKey == 'checkSQLi' ? value : null,
        checkCSRF: configKey == 'checkCSRF' ? value : null,
        checkHeaders: configKey == 'checkHeaders' ? value : null,
        checkSSL: configKey == 'checkSSL' ? value : null,
        checkDirTraversal: configKey == 'checkDirTraversal' ? value : null,
        checkFileInclusion: configKey == 'checkFileInclusion' ? value : null,
        checkCookieSecurity: configKey == 'checkCookieSecurity' ? value : null,
        checkVersionDisclosure:
            configKey == 'checkVersionDisclosure' ? value : null,
        deepScan: configKey == 'deepScan' ? value : null,
      );
    });
  }

  Widget _buildSliderTile(
      String title, String configKey, double min, double max) {
    return ListTile(
      title: Text(title),
      subtitle: Slider(
        value: _scanConfig.toJson()[configKey].toDouble(),
        min: min,
        max: max,
        divisions: 20,
        label: _scanConfig.toJson()[configKey].toString(),
        onChanged: (value) {
          setState(() {
            final updates = {configKey: value.toInt()};
            _scanConfig = _scanConfig.copyWith(
              requestDelay: updates['requestDelay'],
              timeout: updates['timeout'],
              maxDepth: updates['maxDepth'],
            );
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.security),
            SizedBox(width: 8),
            Text('Cybershield'),
          ],
        ),
        actions: _buildAppBarActions(),
      ),
      body: Container(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildUrlInput(),
              const SizedBox(height: 16),
              _buildScanButton(),
              const SizedBox(height: 24),
              _buildVulnerabilitiesList(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildAppBarActions() {
    return [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: _showConfigDialog,
        tooltip: 'Scan Configuration',
      ),
      IconButton(
        icon: const Icon(Icons.description),
        onPressed: _vulnerabilities.isEmpty ? null : _showReport,
        tooltip: 'View Report',
      ),
      if (_vulnerabilities.isNotEmpty)
        PopupMenuButton<ReportFormat>(
          icon: const Icon(Icons.file_download),
          tooltip: 'Export Report',
          onSelected: _generateReport,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: ReportFormat.txt,
              child: Text('Export as TXT'),
            ),
            const PopupMenuItem(
              value: ReportFormat.pdf,
              child: Text('Export as PDF'),
            ),
            const PopupMenuItem(
              value: ReportFormat.csv,
              child: Text('Export as CSV'),
            ),
            const PopupMenuItem(
              value: ReportFormat.json,
              child: Text('Export as JSON'),
            ),
            const PopupMenuItem(
              value: ReportFormat.html,
              child: Text('Export as HTML'),
            ),
          ],
        ),
    ];
  }

  Future<void> _generateReport(ReportFormat format) async {
    try {
      // Validate if vulnerabilities are available
      if (_vulnerabilities.isEmpty) {
        _showToast('No vulnerabilities to generate the report.', isError: true);
        return;
      }

      // Attempt to generate the report
      final path = await ReportGenerator.exportReport(_vulnerabilities, format);

      if (path != null && path.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report saved: $path')),
        );
      } else {
        throw Exception('Invalid report path returned.');
      }
    } catch (e) {
      // Log and show error toast
      debugPrint('Error generating report: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate report: ${e.toString()}')),
      );
    }
  }

  Widget _buildUrlInput() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: _urlController,
            decoration: InputDecoration(
              labelText: 'Target URL',
              hintText: 'https://example.com',
              prefixIcon: const Icon(Icons.link),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () => _urlController.clear(),
              ),
            ),
            validator: _validateUrl,
          ),
        ),
      ),
    );
  }

  String? _validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a URL';
    }
    try {
      final uri = Uri.parse(value);
      if (!uri.isScheme('http') && !uri.isScheme('https')) {
        return 'Please enter a valid HTTP/HTTPS URL';
      }
    } catch (e) {
      return 'Please enter a valid URL';
    }
    return null;
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _isScanning ? null : _startScan,
      icon: _isScanning
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Icon(Icons.security_sharp),
      label: Text(
        _isScanning ? 'Scanning...' : 'Start Security Scan',
        style: const TextStyle(fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildVulnerabilitiesList() {
    return Expanded(
      child: _vulnerabilities.isEmpty
          ? _buildEmptyState()
          : _buildVulnerabilitiesListView(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.security,
            size: 72,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No vulnerabilities found yet',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter a URL and start a scan',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVulnerabilitiesListView() {
    return ListView.separated(
      itemCount: _vulnerabilities.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final vulnerability = _vulnerabilities[index];
        return _buildVulnerabilityTile(vulnerability);
      },
    );
  }

  Widget _buildVulnerabilityTile(Vulnerability vulnerability) {
    final color = _getVulnerabilityColor(vulnerability.severity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Icon(
            _getVulnerabilityIcon(vulnerability.severity),
            color: color,
          ),
        ),
        title: Text(
          vulnerability.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          vulnerability.description,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Chip(
          label: Text(
            vulnerability.severity.toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: color,
        ),
        onTap: () => _showVulnerabilityDetails(vulnerability),
      ),
    );
  }

  Color _getVulnerabilityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red[700]!;
      case 'high':
        return Colors.orange[700]!;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
        return Colors.blue[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  IconData _getVulnerabilityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Icons.error;
      case 'high':
        return Icons.warning;
      case 'medium':
        return Icons.info;
      case 'low':
        return Icons.info_outline;
      default:
        return Icons.help_outline;
    }
  }

  void _showVulnerabilityDetails(Vulnerability vulnerability) {
    final color = _getVulnerabilityColor(vulnerability.severity);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(_getVulnerabilityIcon(vulnerability.severity), color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(vulnerability.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  vulnerability.severity.toUpperCase(),
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Description:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(vulnerability.description),
              const SizedBox(height: 16),
              const Text(
                'Recommendation:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(vulnerability.recommendation ??
                  'No specific recommendation available.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

extension ScanConfigJson on ScanConfig {
  Map<String, dynamic> toJson() {
    return {
      'checkXSS': checkXSS,
      'checkSQLi': checkSQLi,
      'checkCSRF': checkCSRF,
      'checkHeaders': checkHeaders,
      'checkSSL': checkSSL,
      'checkDirTraversal': checkDirTraversal,
      'checkFileInclusion': checkFileInclusion,
      'checkCookieSecurity': checkCookieSecurity,
      'checkVersionDisclosure': checkVersionDisclosure,
      'deepScan': deepScan,
      'requestDelay': requestDelay,
      'timeout': timeout,
      'maxDepth': maxDepth,
    };
  }
}
