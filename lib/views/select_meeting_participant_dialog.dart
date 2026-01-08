// lib/views/select_meeting_participant_dialog.dart
import 'package:flutter/material.dart';
import 'package:meetzone/theme.dart';

/// Bottom sheet for selecting a meeting participant
/// Renamed from Dialog to BottomSheet for clarity
class SelectMeetingParticipantBottomSheet extends StatefulWidget {
  const SelectMeetingParticipantBottomSheet({super.key});

  @override
  State<SelectMeetingParticipantBottomSheet> createState() =>
      _SelectMeetingParticipantBottomSheetState();
}

class _SelectMeetingParticipantBottomSheetState
    extends State<SelectMeetingParticipantBottomSheet> {
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
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Who are you meeting with?',
                  style: AppTextStyles.headlineMd.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a contact or enter a name',
                  style: AppTextStyles.body.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Search field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style: TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search or enter name...',
                hintStyle: TextStyle(color: AppColors.textMuted),
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
                filled: true,
                fillColor: AppColors.surfaceLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.surfaceBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.surfaceBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Recent contacts list
          if (_filteredContacts.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Recent Contacts',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          const SizedBox(height: 8),

          Flexible(
            child:
                _filteredContacts.isEmpty
                    ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No contacts found',
                          style: AppTextStyles.body.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ),
                    )
                    : ListView.builder(
                      shrinkWrap: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.pop(context, contact),
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 10,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          AppColors.primary,
                                          AppColors.primaryDark,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(22),
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
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      contact,
                                      style: AppTextStyles.body.copyWith(
                                        color: AppColors.textPrimary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.textMuted,
                                    size: 20,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
          ),

          const SizedBox(height: 16),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: AppColors.surfaceBorder,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.textSecondary,
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
                        disabledBackgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
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
                                  ? AppColors.surfaceLight
                                  : null,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          alignment: Alignment.center,
                          child: Text(
                            'Continue',
                            style: AppTextStyles.button.copyWith(
                              color:
                                  _controller.text.isEmpty
                                      ? AppColors.textMuted
                                      : Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Keep old name for backward compatibility
typedef SelectMeetingParticipantDialog = SelectMeetingParticipantBottomSheet;
