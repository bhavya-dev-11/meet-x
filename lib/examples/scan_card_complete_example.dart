// lib/examples/scan_card_complete_example.dart
// Complete example showing both camera and gallery usage

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/models/visiting_card_model.dart';
import 'package:meetzone/views/scan_card_view.dart';
import 'package:meetzone/theme.dart';

class ScanCardCompleteExample extends ConsumerWidget {
  const ScanCardCompleteExample({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Card Scanner'),
        backgroundColor: AppColors.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.credit_card,
                  size: 80,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Title
              Text(
                'Scan Business Cards',
                style: AppTextStyles.headlineMd.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description
              Text(
                'Capture or select a business card image to extract contact information automatically',
                style: AppTextStyles.body.copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 48),

              // Scan Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: () => _scanCard(context),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Scan Business Card'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                    elevation: 4,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Info Cards
              _buildInfoCard(
                icon: Icons.camera_alt,
                title: 'Camera',
                description: 'Take a photo of the business card',
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.photo_library,
                title: 'Gallery',
                description: 'Select an existing image from your library',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyBold),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanCard(BuildContext context) async {
    // Navigate to scan card view
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanCardView()),
    );

    // Handle the result
    if (result != null && result is VisitingCard) {
      if (!context.mounted) return;

      // Show success dialog with extracted information
      _showResultDialog(context, result);
    }
  }

  void _showResultDialog(BuildContext context, VisitingCard card) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  color: AppColors.success,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Card Scanned Successfully'),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildResultItem('Name', card.contactPerson),
                  _buildResultItem('Email', card.email),
                  _buildResultItem('Phone', card.phoneNumber),
                  _buildResultItem('Company', card.companyName),
                  _buildResultItem('Designation', card.designation),
                  _buildResultItem('Website', card.website),
                  _buildResultItem('Address', card.address),
                  _buildResultItem('LinkedIn', card.linkedinProfile),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.analytics,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Confidence: ${(card.extractionConfidence * 100).toStringAsFixed(0)}%',
                          style: AppTextStyles.bodyBold.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
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
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Here you can add logic to save the card or navigate to details
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Card saved successfully!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                ),
                child: const Text('Save Contact'),
              ),
            ],
          ),
    );
  }

  Widget _buildResultItem(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(value, style: AppTextStyles.body),
        ],
      ),
    );
  }
}


