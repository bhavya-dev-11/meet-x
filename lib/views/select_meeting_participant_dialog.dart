// lib/views/select_meeting_participant_dialog.dart
import 'package:flutter/material.dart';
import 'package:meetzone/theme.dart';

class SelectMeetingParticipantDialog extends StatefulWidget {
  const SelectMeetingParticipantDialog({super.key});

  @override
  State<SelectMeetingParticipantDialog> createState() =>
      _SelectMeetingParticipantDialogState();
}

class _SelectMeetingParticipantDialogState
    extends State<SelectMeetingParticipantDialog> {
  final TextEditingController _controller = TextEditingController();

  // TODO: Replace with actual data from repository
  final List<String> _recentContacts = [
    'Acme Corp.',
    'John Smith',
    'Tech Solutions Inc.',
    'Sarah Johnson',
    'Global Ventures',
  ];

  List<String> _filteredContacts = [];

  @override
  void initState() {
    super.initState();
    _filteredContacts = _recentContacts;
    _controller.addListener(_filterContacts);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _filterContacts() {
    setState(() {
      if (_controller.text.isEmpty) {
        _filteredContacts = _recentContacts;
      } else {
        _filteredContacts =
            _recentContacts
                .where(
                  (contact) => contact.toLowerCase().contains(
                    _controller.text.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Who are you meeting with?',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select a contact or enter a name',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),

            // Search field
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Search or enter name...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.softGray,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Recent contacts list
            if (_filteredContacts.isNotEmpty) ...[
              Text(
                'Recent Contacts',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMutedLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
            ],

            Flexible(
              child:
                  _filteredContacts.isEmpty
                      ? Center(
                        child: Text(
                          'No contacts found',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMutedLight,
                          ),
                        ),
                      )
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _filteredContacts.length,
                        itemBuilder: (context, index) {
                          final contact = _filteredContacts[index];
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Center(
                                child: Text(
                                  contact[0].toUpperCase(),
                                  style: AppTextStyles.title.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            title: Text(
                              contact,
                              style: AppTextStyles.body.copyWith(
                                color: AppColors.textOnLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            onTap: () => Navigator.pop(context, contact),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      'Cancel',
                      style: AppTextStyles.button.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        _controller.text.isEmpty
                            ? null
                            : () => Navigator.pop(context, _controller.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Ink(
                      decoration: BoxDecoration(
                        gradient:
                            _controller.text.isEmpty
                                ? null
                                : const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryDark,
                                  ],
                                ),
                        color:
                            _controller.text.isEmpty
                                ? AppColors.textMutedLight.withValues(alpha: 0.3)
                                : null,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue',
                          style: AppTextStyles.button.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


