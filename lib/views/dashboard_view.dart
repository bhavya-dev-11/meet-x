// lib/views/dashboard_view.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:meetzone/models/meeting_model.dart';
import 'package:meetzone/providers/dashboard_provider.dart';
import 'package:meetzone/services/storage_service.dart';
import 'package:meetzone/theme.dart';
import 'package:meetzone/views/record_meeting_view.dart';
import 'package:meetzone/views/scan_card_view.dart';
import 'package:meetzone/views/select_meeting_participant_dialog.dart';

class DashboardView extends ConsumerStatefulWidget {
  const DashboardView({super.key});

  @override
  ConsumerState<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends ConsumerState<DashboardView>
    with TickerProviderStateMixin {
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardControllerProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      floatingActionButton: _buildFAB(context),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.onboardBgStart,
              AppColors.onboardBgMiddle,
              AppColors.onboardBgEnd,
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildFloatingShapes(),
            SafeArea(
              child: dashboardState.when(
                data:
                    (state) => RefreshIndicator(
                      onRefresh: () async {
                        await ref
                            .read(dashboardControllerProvider.notifier)
                            .refresh();
                      },
                      color: AppColors.primary,
                      backgroundColor: Colors.white,
                      child: CustomScrollView(
                        slivers: [
                          _buildHeader(state.userName),
                          _buildQuickActions(),
                          _buildRecentMeetingsHeader(),
                          _buildMeetingsList(state.recentMeetings),
                          const SliverToBoxAdapter(child: SizedBox(height: 80)),
                        ],
                      ),
                    ),
                loading:
                    () => Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                        strokeWidth: 3,
                      ),
                    ),
                error:
                    (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.error.withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Something went wrong',
                            style: AppTextStyles.title.copyWith(
                              color: AppColors.textOnLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              ref
                                  .read(dashboardControllerProvider.notifier)
                                  .refresh();
                            },
                            child: Text(
                              'Retry',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingShapes() {
    return AnimatedBuilder(
      animation: _glowController,
      builder:
          (_, __) => Stack(
            children: [
              Positioned(
                top: -80,
                left: -80,
                child: Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 
                          0.18 + 0.05 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                right: -60,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(alpha: 
                          0.14 + 0.04 * _glowController.value,
                        ),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 200,
                right: 30,
                child: Transform.rotate(
                  angle: 0.8,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildHeader(String userName) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()},',
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textMutedLight.withValues(alpha: 0.9),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    userName,
                    style: AppTextStyles.headlineXL.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      foreground:
                          Paint()
                            ..shader = const LinearGradient(
                              colors: [
                                AppColors.primary,
                                AppColors.primaryDark,
                              ],
                            ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
                    ),
                  ),
                ],
              ),
            ),
            // Logout Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showLogoutDialog(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadii.lg),
            ),
            title: Text(
              'Logout',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w700,
              ),
            ),
            content: Text(
              'Are you sure you want to logout?',
              style: AppTextStyles.body.copyWith(
                color: AppColors.textMutedLight,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppColors.textMutedLight),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  await _handleLogout(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadii.sm),
                  ),
                ),
                child: const Text('Logout'),
              ),
            ],
          ),
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    try {
      // Clear all stored data
      await StorageService.clearAll();

      // Navigate to login screen
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
      debugPrint('Logout error: $e');
      // Even if there's an error, clear local data and logout
      await StorageService.clearAll();
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  Widget _buildQuickActions() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Row(
          children: [
            Expanded(
              child: _QuickActionCard(
                icon: Icons.qr_code_scanner_rounded,
                label: 'Scan Card',
                gradient: const LinearGradient(
                  colors: [Color(0xFF8156FF), Color(0xFF9D7EFF)],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ScanCardView(),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.mic_rounded,
                label: 'Record',
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF6B9D), Color(0xFFFF8FB3)],
                ),
                onTap: () async {
                  final meetingWith = await showDialog<String>(
                    context: context,
                    builder:
                        (context) => const SelectMeetingParticipantDialog(),
                  );

                  if (meetingWith != null && context.mounted) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                RecordMeetingView(meetingWith: meetingWith),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionCard(
                icon: Icons.people_rounded,
                label: 'My Leads',
                gradient: const LinearGradient(
                  colors: [Color(0xFF00D4FF), Color(0xFF5BE9FF)],
                ),
                onTap: () {
                  // TODO: Navigate to leads
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentMeetingsHeader() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Meetings',
              style: AppTextStyles.headlineMd.copyWith(
                color: AppColors.textOnLight,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: View all meetings
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
              ),
              child: Text(
                'View All',
                style: AppTextStyles.body.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingsList(List<Meeting> meetings) {
    if (meetings.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.event_busy_rounded,
                size: 64,
                color: AppColors.textMutedLight.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No meetings yet',
                style: AppTextStyles.title.copyWith(
                  color: AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap + to create your first meeting',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textMutedLight.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final meeting = meetings[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _MeetingCard(meeting: meeting),
          );
        }, childCount: meetings.length),
      ),
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showActionSheet(context),
          borderRadius: BorderRadius.circular(32),
          child: const Center(
            child: Icon(Icons.add, size: 28, color: Colors.white),
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [AppShadows.lg],
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.textMutedLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _ActionSheetItem(
                    icon: Icons.person_add_rounded,
                    title: 'New Lead',
                    subtitle: 'Add a new lead manually',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to new lead
                    },
                  ),
                  _ActionSheetItem(
                    icon: Icons.event_rounded,
                    title: 'New Meeting',
                    subtitle: 'Schedule a new meeting',
                    onTap: () {
                      Navigator.pop(context);
                      // TODO: Navigate to new meeting
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.md),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadii.md),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: Colors.white, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeetingCard extends StatelessWidget {
  final Meeting meeting;

  const _MeetingCard({required this.meeting});

  Color _getScoreColor(double score) {
    if (score >= 8.0) return const Color(0xFF10B981);
    if (score >= 6.0) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(meeting.score);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadii.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Score Badge
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: scoreColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: scoreColor.withValues(alpha: 0.4), width: 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  meeting.score.toStringAsFixed(1),
                  style: AppTextStyles.headlineMd.copyWith(
                    color: scoreColor,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Score',
                  style: AppTextStyles.caption.copyWith(
                    color: scoreColor.withValues(alpha: 0.9),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Meeting Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meeting.title,
                  style: AppTextStyles.title.copyWith(
                    color: AppColors.textOnLight,
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                if (meeting.clientName != null)
                  Row(
                    children: [
                      Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: AppColors.textMutedLight,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        meeting.clientName!,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textMutedLight,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14,
                      color: AppColors.textMutedLight.withValues(alpha: 0.8),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _formatDateTime(meeting.dateTime),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                    if (meeting.location != null) ...[
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: AppColors.textMutedLight.withValues(alpha: 0.8),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          meeting.location!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textMutedLight.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textMutedLight.withValues(alpha: 0.6),
            size: 24,
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return 'Today, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday, ${DateFormat('h:mm a').format(dateTime)}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM d, h:mm a').format(dateTime);
    }
  }
}

class _ActionSheetItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionSheetItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.title.copyWith(
                        color: AppColors.textOnLight,
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMutedLight,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMutedLight.withValues(alpha: 0.5),
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


