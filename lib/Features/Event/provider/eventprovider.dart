// time_slot_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimeSlotNotifier extends StateNotifier<String?> {
  TimeSlotNotifier() : super(null);

  void selectTimeSlot(String? timeSlot) {
    state = timeSlot;
  }
}

final timeSlotProvider = StateNotifierProvider<TimeSlotNotifier, String?>((ref) {
  return TimeSlotNotifier();
});