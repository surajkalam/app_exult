// providers/event_provider.dart

import 'package:coffee_exult_app/Features/Event/model/event_category.dart' show EventCategory;
import 'package:coffee_exult_app/Features/Event/provider/event_firebase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/event_model.dart';
final eventCategoriesProvider = Provider<List<EventCategory>>((ref) {
  return [
    EventCategory(
      id: 'private',
      name: 'Private Celebration',
      icon: '🎂',
      description: 'Birthday, Anniversary, Baby Shower',
    ),
    EventCategory(
      id: 'music',
      name: 'Live Music & Open Mic',
      icon: '🎵',
      description: 'Enjoy performances or take the stage',
    ),
    EventCategory(
      id: 'workshop',
      name: 'Workshop & Meeting',
      icon: '📚',
      description: 'Learn, connect, and share with community',
    ),
    EventCategory(
      id: 'corporate',
      name: 'Corporate Event',
      icon: '💼',
      description: 'Productive meetings or team bonding',
    ),
  ];
});

final userFirestoreServiceProvider = Provider<UserFirestoreService>((ref) {
  return UserFirestoreService();
});

final eventBookingProvider = StateNotifierProvider<EventBookingNotifier, EventBooking>((ref) {
  return EventBookingNotifier();
});

final userBookingsProvider = StreamProvider.family<List<EventBooking>, String>((ref, userId) {
  final firestoreService = ref.watch(userFirestoreServiceProvider);
  return firestoreService.getUserBookings(userId);
});
class EventBookingNotifier extends StateNotifier<EventBooking> {
  EventBookingNotifier() : super(
    EventBooking(
      bookingId: '',
      categoryId: '',
      selectedDate: DateTime.now(),
      selectedTime: const TimeOfDay(hour: 18, minute: 0),
      endingTime: const TimeOfDay(hour: 11, minute: 0),
      numberOfGuests: 1,
      eventType: '',
      createdAt: DateTime.now(),
    )
  );

  void setCategory(String categoryId) {
    state = state.copyWith(categoryId: categoryId);
  }

  void setDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  void setTime(TimeOfDay time) {

    state = state.copyWith(selectedTime: time);
   if (state.endingTime.hour == 11 && state.endingTime.minute == 0) { // Only if it's the default
      final endingTime = TimeOfDay(
        hour: (time.hour + 1) % 24,
        minute: time.minute,
      );
      state = state.copyWith(endingTime: endingTime);
    }
  }
   void setEndingTime(TimeOfDay endingTime) {
    state = state.copyWith(endingTime: endingTime);
  }

  void setGuests(int guests) {
    state = state.copyWith(numberOfGuests: guests);
  }

  void setEventType(String type) {
    state = state.copyWith(eventType: type);
  }

  void setSpecialRequests(String requests) {
    state = state.copyWith(specialRequests: requests);
  }

  void setAdditionalOption(String key, dynamic value) {
    state = state.copyWith(
      additionalOptions: {...state.additionalOptions, key: value},
    );
  }

  void reset() {
    state = EventBooking(
      bookingId: '',
      categoryId: '',
      selectedDate: DateTime.now(),
      selectedTime: const TimeOfDay(hour: 18, minute: 0),
      endingTime: const TimeOfDay(hour: 11, minute: 0),
      numberOfGuests: 1,
      eventType: '',
      createdAt: DateTime.now(),
    );
  }
}