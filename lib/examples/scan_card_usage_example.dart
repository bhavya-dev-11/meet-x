// lib/examples/scan_card_usage_example.dart
// This is an example of how to use the ScanCardView with the visiting card API

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/models/visiting_card_model.dart';
import 'package:meetzone/views/scan_card_view.dart';

class ScanCardUsageExample extends ConsumerWidget {
  const ScanCardUsageExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Card Example'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            // Navigate to scan card view
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScanCardView(),
              ),
            );

            // Handle the result
            if (result != null && result is VisitingCard) {
              // Successfully scanned a card
              if (!context.mounted) return;
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Card scanned successfully!\n'
                    'Name: ${result.contactPerson ?? "N/A"}\n'
                    'Email: ${result.email ?? "N/A"}',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );

              // You can now use the visiting card data
              // For example, navigate to a detail view or save it locally
              print('Scanned Card ID: ${result.id}');
              print('Contact Person: ${result.contactPerson}');
              print('Email: ${result.email}');
              print('Phone: ${result.phoneNumber}');
              print('Company: ${result.companyName}');
              print('Designation: ${result.designation}');
              print('Address: ${result.address}');
              print('Website: ${result.website}');
              print('LinkedIn: ${result.linkedinProfile}');
              print('Confidence: ${result.extractionConfidence}');
            }
          },
          child: const Text('Scan Business Card'),
        ),
      ),
    );
  }
}


