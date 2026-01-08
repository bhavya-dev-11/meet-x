// lib/models/visiting_card_state.dart
import 'package:meetzone/models/visiting_card_model.dart';

enum VisitingCardStatus { initial, uploading, processing, completed, error }

class VisitingCardState {
  final VisitingCardStatus status;
  final VisitingCard? visitingCard;
  final String? errorMessage;
  final double uploadProgress;

  VisitingCardState({
    required this.status,
    this.visitingCard,
    this.errorMessage,
    this.uploadProgress = 0.0,
  });

  factory VisitingCardState.initial() {
    return VisitingCardState(status: VisitingCardStatus.initial);
  }

  VisitingCardState copyWith({
    VisitingCardStatus? status,
    VisitingCard? visitingCard,
    String? errorMessage,
    double? uploadProgress,
  }) {
    return VisitingCardState(
      status: status ?? this.status,
      visitingCard: visitingCard ?? this.visitingCard,
      errorMessage: errorMessage,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }
}


