// model/event_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EventCategory {
  final String id;
  final String name;
  final String icon;
  final String description;

  const EventCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'description': description,
    };
  }

  factory EventCategory.fromMap(Map<String, dynamic> map) {
    return EventCategory(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: map['icon'] as String,
      description: map['description'] as String,
    );
  }
}

class EventBooking {
  final String bookingId;
  final String categoryId;
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final int numberOfGuests;
  final String eventType;
  final String? specialRequests;
  final Map<String, dynamic> additionalOptions;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String status;

  EventBooking({
    required this.bookingId,
    required this.categoryId,
    required this.selectedDate,
    required this.selectedTime,
    required this.numberOfGuests,
    required this.eventType,
    this.specialRequests,
    Map<String, dynamic>? additionalOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.status = 'pending',
  })  : additionalOptions = additionalOptions ?? {},
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  EventBooking copyWith({
    String? bookingId,
    String? categoryId,
    DateTime? selectedDate,
    TimeOfDay? selectedTime,
    int? numberOfGuests,
    String? eventType,
    String? specialRequests,
    Map<String, dynamic>? additionalOptions,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? status,
  }) {
    return EventBooking(
      bookingId: bookingId ?? this.bookingId,
      categoryId: categoryId ?? this.categoryId,
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      numberOfGuests: numberOfGuests ?? this.numberOfGuests,
      eventType: eventType ?? this.eventType,
      specialRequests: specialRequests ?? this.specialRequests,
      additionalOptions: additionalOptions ?? this.additionalOptions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
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
      'numberOfGuests': numberOfGuests,
      'eventType': eventType,
      'specialRequests': specialRequests,
      'additionalOptions': additionalOptions,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'status': status,
    };
  }

  factory EventBooking.fromMap(String bookingId, Map<String, dynamic> map) {
    final timeData = map['selectedTime'] as Map<String, dynamic>;
    
    return EventBooking(
      bookingId: bookingId,
      categoryId: map['categoryId'] as String,
      selectedDate: (map['selectedDate'] as Timestamp).toDate(),
      selectedTime: TimeOfDay(
        hour: timeData['hour'] as int,
        minute: timeData['minute'] as int,
      ),
      numberOfGuests: map['numberOfGuests'] as int,
      eventType: map['eventType'] as String,
      specialRequests: map['specialRequests'] as String?,
      additionalOptions: Map<String, dynamic>.from(map['additionalOptions'] as Map),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      status: map['status'] as String? ?? 'pending',
    );
  }
}