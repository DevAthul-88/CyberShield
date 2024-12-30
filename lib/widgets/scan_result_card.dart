// lib/widgets/scan_result_card.dart
import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class ScanResultCard extends StatelessWidget {
  final ScanResult result;

  const ScanResultCard({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: Icon(
          result.isVulnerable ? Icons.warning_rounded : Icons.check_circle_rounded,
          color: result.isVulnerable ? Colors.red : Colors.green,
          size: 32,
        ),
        title: Text(
          '${result.service} (Port ${result.port})',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.description),
            const SizedBox(height: 4),
            Text(
              'Risk: ${result.risk}',
              style: TextStyle(
                color: result.isVulnerable ? Colors.red : Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        isThreeLine: true,
        onTap: () => _showDetailsDialog(context),
      ),
    );
  }

  void _showDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${result.service} Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Port: ${result.port}'),
            const SizedBox(height: 8),
            Text('Service: ${result.service}'),
            const SizedBox(height: 8),
            Text('Description: ${result.description}'),
            const SizedBox(height: 8),
            Text(
              'Risk Level: ${result.risk}',
              style: TextStyle(
                color: result.isVulnerable ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Close'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}