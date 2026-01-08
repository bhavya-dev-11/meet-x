// lib/providers/visiting_card_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meetzone/controllers/visiting_card_controller.dart';
import 'package:meetzone/data/visiting_card_repository.dart';
import 'package:meetzone/models/visiting_card_state.dart';

final visitingCardRepositoryProvider = Provider<VisitingCardRepository>((ref) {
  return VisitingCardRepository();
});

final visitingCardProvider =
    NotifierProvider<VisitingCardNotifier, VisitingCardState>(() {
      return VisitingCardNotifier();
    });


