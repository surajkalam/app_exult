// model/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventBooking {
  final String bookingId;
  final String categoryId;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TimeOfDay endingTime; 
  final int numberOfGuests;
  final String eventType;
  final String? specialRequests;
  final Map<String, dynamic> additionalOptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;
  final String? adminResponse; 

  EventBooking({
    required this.bookingId,
    required this.categoryId,
    required this.selectedDate,
    required this.selectedTime,
    required this.endingTime,
    required this.numberOfGuests,
    required this.eventType,
    this.specialRequests,
    Map<String, dynamic>? additionalOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = 'pending',
      this.adminResponse,
  })  : additionalOptions = additionalOptions ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  EventBooking copyWith({
    String? bookingId,
    String? categoryId,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
     TimeOfDay? endingTime,
    int? numberOfGuests,
    String? eventType,
    String? specialRequests,
    Map<String, dynamic>? additionalOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
    String? adminResponse, 
  }) {
    return EventBooking(
      bookingId: bookingId ?? this.bookingId,
      categoryId: categoryId ?? this.categoryId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      endingTime: endingTime ?? this.endingTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      eventType: eventType ?? this.eventType,
      specialRequests: specialRequests ?? this.specialRequests,
      additionalOptions: additionalOptions ?? this.additionalOptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'categoryId': categoryId,
      'selectedDate': Timestamp.fromDate(selectedDate),
      'selectedTime': {
        'hour': selectedTime.hour,
        'minute': selectedTime.minute,
      },
       'endingTime': { 
        'hour': endingTime.hour,
        'minute': endingTime.minute,
      },
      'numberOfGuests': numberOfGuests,
      'eventType': eventType,
      'specialRequests': specialRequests,
      'additionalOptions': additionalOptions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
       'adminResponse': adminResponse,
    };
  }

  factory EventBooking.fromMap(String bookingId, Map<String, dynamic> map) {
    final timeData = map['selectedTime'] as Map<String, dynamic>;
      // final endingTimeData = map['endingTime'] as Map<String, dynamic>; 
       TimeOfDay endingTime;
    if (map['endingTime'] != null) {
      final endingTimeData = map['endingTime'] as Map<String, dynamic>;
      endingTime = TimeOfDay(
        hour: endingTimeData['hour'] as int,
        minute: endingTimeData['minute'] as int,
      );
    } else {
      // Default to 1 hour after start time
      final startTime = TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      );
      endingTime = TimeOfDay(
        hour: (startTime.hour + 1) % 24,
        minute: startTime.minute,
      );
    }
    return EventBooking(
      bookingId: bookingId,
      categoryId: map['categoryId'] as String,
      selectedDate: (map['selectedDate'] as Timestamp).toDate(),
      selectedTime: TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      ),
       endingTime: endingTime,
      numberOfGuests: map['numberOfGuests'] as int,
      eventType: map['eventType'] as String,
      specialRequests: map['specialRequests'] as String?,
      additionalOptions: Map<String, dynamic>.from(map['additionalOptions'] as Map),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'pending',
        adminResponse: map['adminResponse'] as String?, 
    );
  }
}

