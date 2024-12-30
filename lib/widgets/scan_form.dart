// lib/widgets/scan_form.dart
import 'package:flutter/material.dart';
import '../utils/ip_validator.dart';

class ScanForm extends StatelessWidget {
  final TextEditingController ipController;
  final TextEditingController portRangeController;
  final GlobalKey<FormState> formKey;

  const ScanForm({
    Key? key,
    required this.ipController,
    required this.portRangeController,
    required this.formKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: ipController,
                decoration: const InputDecoration(
                  labelText: 'Target IP Address',
                  prefixIcon: Icon(Icons.computer),
                  border: OutlineInputBorder(),
                ),
                validator: IPValidator.validateIP,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: portRangeController,
                decoration: const InputDecoration(
                  labelText: 'Port Range',
                  prefixIcon: Icon(Icons.numbers),  // Changed from port_rounded to numbers
                  border: OutlineInputBorder(),
                  hintText: 'Single port (80) or range (80-443)',
                ),
                validator: IPValidator.validatePortRange,
              ),
            ],
          ),
        ),
      ),
    );
  }
}