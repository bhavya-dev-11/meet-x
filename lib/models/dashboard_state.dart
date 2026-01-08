// lib/models/dashboard_state.dart
import 'package:meetzone/models/meeting_model.dart';

class DashboardState {
  final List<Meeting> recentMeetings;
  final int pendingUploadCount;
  final String userName;

  DashboardState({
    required this.recentMeetings,
    required this.pendingUploadCount,
    required this.userName,
  });

  DashboardState copyWith({
    List<Meeting>? recentMeetings,
    int? pendingUploadCount,
    String? userName,
  }) {
    return DashboardState(
      recentMeetings: recentMeetings ?? this.recentMeetings,
      pendingUploadCount: pendingUploadCount ?? this.pendingUploadCount,
      userName: userName ?? this.userName,
    );
  }
}


