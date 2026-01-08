// lib/providers/dashboard_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/data/dashboard_repository.dart';
import 'package:meetzone/models/dashboard_state.dart';
import 'package:meetzone/services/storage_service.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardControllerProvider =
    AsyncNotifierProvider<DashboardController, DashboardState>(() {
      return DashboardController();
    });

class DashboardController extends AsyncNotifier<DashboardState> {
  @override
  Future<DashboardState> build() async {
    final repository = ref.read(dashboardRepositoryProvider);
    final user = StorageService.getUser();

    final meetings = await repository.getRecentMeetings();
    final pendingCount = await repository.getPendingUploadCount();

    // Get user's full name for greeting
    final fullName = user?.fullName ?? 'User';

    return DashboardState(
      recentMeetings: meetings,
      pendingUploadCount: pendingCount,
      userName: fullName,
    );
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => build());
  }
}


