// lib/data/dashboard_repository.dart
import 'package:meetzone/models/meeting_model.dart';

class DashboardRepository {
  // Stub method - replace with actual API call later
  Future<List<Meeting>> getRecentMeetings() async {
    await Future.delayed(const Duration(milliseconds: 800));

    // Mock data for now
    return [
      Meeting(
        id: '1',
        title: 'Product Demo with TechCorp',
        score: 8.5,
        dateTime: DateTime.now().subtract(const Duration(hours: 2)),
        clientName: 'John Smith',
        location: 'Conference Room A',
      ),
      Meeting(
        id: '2',
        title: 'Sales Pitch - Enterprise Solution',
        score: 7.2,
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        clientName: 'Sarah Johnson',
        location: 'Virtual',
      ),
      Meeting(
        id: '3',
        title: 'Follow-up Meeting',
        score: 9.1,
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        clientName: 'Michael Chen',
        location: 'Office',
      ),
      Meeting(
        id: '4',
        title: 'Initial Consultation',
        score: 6.8,
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        clientName: 'Emily Davis',
        location: 'Cafe Downtown',
      ),
    ];
  }

  // Stub method - replace with actual API call later
  Future<int> getPendingUploadCount() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return 3; // Mock count
  }
}


