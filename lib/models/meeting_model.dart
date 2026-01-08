// lib/models/meeting_model.dart
class Meeting {
  final String id;
  final String title;
  final double score;
  final DateTime dateTime;
  final String? clientName;
  final String? location;

  Meeting({
    required this.id,
    required this.title,
    required this.score,
    required this.dateTime,
    this.clientName,
    this.location,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    return Meeting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      score: (json['score'] ?? 0).toDouble(),
      dateTime: DateTime.parse(
        json['date_time'] ?? DateTime.now().toIso8601String(),
      ),
      clientName: json['client_name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'score': score,
      'date_time': dateTime.toIso8601String(),
      'client_name': clientName,
      'location': location,
    };
  }
}


