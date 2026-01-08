// lib/models/meeting_summary_model.dart
class MeetingSummary {
  final String id;
  final String meetingId;
  final String userId;
  final String? businessId;
  final String audioPath;
  final int audioDuration;
  final String audioFormat;
  final String? transcript;
  final String? transcriptLanguage;
  final String? meetingSummary;
  final List<String> keyPoints;
  final List<String> actionItems;
  final int? clientPotentialScore;
  final String? potentialScoreReasoning;
  final String? overallSentiment;
  final List<String> clientInterests;
  final List<String> painPoints;
  final String? budgetIndicators;
  final String? decisionTimeline;
  final String processingStatus;
  final bool summaryEmailsSent;
  final DateTime createdAt;
  final DateTime recordedAt;

  MeetingSummary({
    required this.id,
    required this.meetingId,
    required this.userId,
    this.businessId,
    required this.audioPath,
    required this.audioDuration,
    required this.audioFormat,
    this.transcript,
    this.transcriptLanguage,
    this.meetingSummary,
    this.keyPoints = const [],
    this.actionItems = const [],
    this.clientPotentialScore,
    this.potentialScoreReasoning,
    this.overallSentiment,
    this.clientInterests = const [],
    this.painPoints = const [],
    this.budgetIndicators,
    this.decisionTimeline,
    required this.processingStatus,
    required this.summaryEmailsSent,
    required this.createdAt,
    required this.recordedAt,
  });

  factory MeetingSummary.fromJson(Map<String, dynamic> json) {
    return MeetingSummary(
      id: json['id'] ?? '',
      meetingId: json['meeting_id'] ?? '',
      userId: json['user_id'] ?? '',
      businessId: json['business_id'],
      audioPath: json['audio_path'] ?? '',
      audioDuration: json['audio_duration'] ?? 0,
      audioFormat: json['audio_format'] ?? '',
      transcript: json['transcript'],
      transcriptLanguage: json['transcript_language'],
      meetingSummary: json['meeting_summary'],
      keyPoints:
          (json['key_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      actionItems:
          (json['action_items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      clientPotentialScore: json['client_potential_score'],
      potentialScoreReasoning: json['potential_score_reasoning'],
      overallSentiment: json['overall_sentiment'],
      clientInterests:
          (json['client_interests'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      painPoints:
          (json['pain_points'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      budgetIndicators: json['budget_indicators'],
      decisionTimeline: json['decision_timeline'],
      processingStatus: json['processing_status'] ?? 'pending',
      summaryEmailsSent: json['summary_emails_sent'] ?? false,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      recordedAt: DateTime.parse(
        json['recorded_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'user_id': userId,
      'business_id': businessId,
      'audio_path': audioPath,
      'audio_duration': audioDuration,
      'audio_format': audioFormat,
      'transcript': transcript,
      'transcript_language': transcriptLanguage,
      'meeting_summary': meetingSummary,
      'key_points': keyPoints,
      'action_items': actionItems,
      'client_potential_score': clientPotentialScore,
      'potential_score_reasoning': potentialScoreReasoning,
      'overall_sentiment': overallSentiment,
      'client_interests': clientInterests,
      'pain_points': painPoints,
      'budget_indicators': budgetIndicators,
      'decision_timeline': decisionTimeline,
      'processing_status': processingStatus,
      'summary_emails_sent': summaryEmailsSent,
      'created_at': createdAt.toIso8601String(),
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}
