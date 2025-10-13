// screens/event_booking_screen.dart
import 'dart:developer';


import 'package:coffee_exult_app/Features/Event/provider/user_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../Authentication/provider/current_user.dart';
import '../../../core/core.dart';
import '../provider/event_provider.dart';

class EventBookingScreen extends ConsumerStatefulWidget {
  const EventBookingScreen({super.key});

  @override
  ConsumerState<EventBookingScreen> createState() => _EventBookingScreenState();
}

class _EventBookingScreenState extends ConsumerState<EventBookingScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _specialRequestsController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // int _currentStep = 0;

  final Map<String, List<String>> _eventTypeOptions = {
    'private': ['Birthday Party', 'Anniversary', 'Baby Shower', 'Engagement'],
    'music': ['Open Mic Performance', 'Live Music Attendance', 'Band Booking'],
    'workshop': [
      'Coffee Workshop',
      'Community Meeting',
      'Art Class',
      'Book Club',
    ],
    'corporate': [
      'Team Meeting',
      'Client Presentation',
      'Team Building',
      'Corporate Training',
    ],
  };

  final Map<String, Map<String, dynamic>> _additionalOptions = {
    'private': {
      'cakeService': false,
      'decorations': false,
      'photographer': false,
    },
    'music': {
      'instrumentRental': false,
      'soundCheck': false,
      'recording': false,
    },
    'workshop': {'projector': false, 'whiteboard': false, 'materials': false},
    'corporate': {
      'catering': false,
      'avEquipment': false,
      'dedicatedHost': false,
    },
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _specialRequestsController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitBooking(double height, double width) async {
    if (_formKey.currentState!.validate()) {
      final booking = ref.read(eventBookingProvider);
      final firestoreService = ref.read(userFirestoreServiceProvider);
      final currentuser = ref.read(currentUserProvider);
      // final notifier = ref.read(eventBookingProvider.notifier);

      if (currentuser == null) {
        log('User is null');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please log in to book an event'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      final userId = currentuser.uid;
      log('User ID: $userId');

      try {
        // Show loading dialog for user details
        if (!mounted) return;
        log('Showing loading dialog');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(26),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.secondaryFixed,
                    ),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading user details...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        final userDetails = await ref.read(userDetailsProvider.future);
        log('Form validation passed');
        // Save to Firebase
        final bookingId = await firestoreService.saveBooking(
          userId: currentuser.phoneNumber ?? userId,
          booking: booking,
          userName: userDetails.name,
          userEmail: userDetails.email,
          userPhone: userDetails.phone,
        );
        // ignore: use_build_context_synchronously
        if (!mounted) return;
        log('Closing loading dialog');
        Navigator.pop(context);

        // Show success dialog
        if (!mounted) return;
        log('Showing booking submission dialog');
        showDialog(
          // ignore: use_build_context_synchronously
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.all(20),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 300),
              padding: EdgeInsets.all(width * 0.026),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).colorScheme.surface,
                    Theme.of(context).colorScheme.surfaceContainerLow,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Theme.of(
                    context,
                    // ignore: deprecated_member_use
                  ).colorScheme.outlineVariant.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(
                      context,
                      // ignore: deprecated_member_use
                    ).colorScheme.shadow.withOpacity(0.15),
                    blurRadius: 25,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success Icon
                    Container(
                      padding: EdgeInsets.all(width * 0.018),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            // ignore: deprecated_member_use
                            Colors.green.withOpacity(0.15),
                            // ignore: deprecated_member_use
                            Colors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          // ignore: deprecated_member_use
                          color: Colors.green.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: Colors.green,
                        size: width * 0.08, // Responsive size
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Text(
                      'Booking Confirmed!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).colorScheme.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: height * 0.01),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.016,
                        vertical: height * 0.008,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                          // ignore: deprecated_member_use
                        ).colorScheme.secondaryFixed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                            // ignore: deprecated_member_use
                          ).colorScheme.secondaryFixed.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        'ID: ${bookingId.substring(0, 10)}...',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.secondaryFixed,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    SizedBox(height: height * 0.02),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(height * 0.018),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                          // ignore: deprecated_member_use
                        ).colorScheme.surfaceContainerHigh.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(
                            context,
                            // ignore: deprecated_member_use
                          ).colorScheme.outlineVariant.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildCompactInfoRow(
                            'Category',
                            _getCategoryName(booking.categoryId),
                            context,
                            height,
                            width,
                          ),
                          const SizedBox(height: 8),
                          _buildCompactInfoRow(
                            'Event Type',
                            booking.eventType,
                            context,
                            height,
                            width,
                          ),
                          const SizedBox(height: 8),
                          _buildCompactInfoRow(
                            'Date',
                            '${_getWeekday(booking.selectedDate.weekday)}, ${booking.selectedDate.day}/${booking.selectedDate.month}/${booking.selectedDate.year}',
                            context,
                            height,
                            width,
                          ),
                          SizedBox(height: height * 0.01),
                          _buildCompactInfoRow(
                            'Time',
                            booking.selectedTime.format(context),
                            context,
                            height,
                            width,
                          ),
                          _buildCompactInfoRow(
                            'Time',
                            '${booking.selectedTime.format(context)} - ${booking.endingTime.format(context)}',
                            context,
                            height,
                            width,
                          ),
                          SizedBox(height: height * 0.01),
                          _buildCompactInfoRow(
                            'Guests',
                            '${booking.numberOfGuests} ${booking.numberOfGuests == 1 ? 'person' : 'people'}',
                            context,
                            height,
                            width,
                          ),
                          if (booking.specialRequests?.isNotEmpty == true) ...[
                            SizedBox(height: height * 0.01),
                            _buildCompactInfoRow(
                              'Special Requests',
                              booking.specialRequests!,
                              context,
                              height,
                              width,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: height * 0.025),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.014,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.outlineVariant,
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.014),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Row(
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                      SizedBox(width: width * 0.016),
                                      Expanded(
                                        child: Text(
                                          'Booking submitted successfully!',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                fontSize: 14,
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.secondary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  backgroundColor: Colors.green,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                              ref.read(eventBookingProvider.notifier).reset();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondaryFixed,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 16,
                                  color: Colors.white,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'New Booking',
                                  style: Theme.of(context).textTheme.bodyMedium
                                      ?.copyWith(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      } catch (e) {
        // Close loading dialog
        // ignore: use_build_context_synchronously
        if (!mounted) return;
        Navigator.pop(context);

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(width * 0.026),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: Theme.of(
                      context,
                    ).colorScheme.shadow.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Theme.of(context).colorScheme.error,
                    size: 48,
                  ),
                  SizedBox(height: height * 0.017),
                  Text(
                    'Booking Failed',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: height * 0.09),
                  Text(
                    'Error: $e', // Show actual error
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: height * 0.02),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.error,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: height * 0.013),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'OK',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }
    }
  }

  String _getWeekday(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  // Add this helper method for compact info rows
  Widget _buildCompactInfoRow(
    String label,
    String value,
    BuildContext context,
    double height,
    double width,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(width: width * 0.01),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(String categoryId) {
    final categories = ref.read(eventCategoriesProvider);
    return categories.firstWhere((cat) => cat.id == categoryId).name;
  }

  Widget _buildStepIndicator(double height, double width) {
    final booking = ref.watch(eventBookingProvider);
    int activeStep = booking.categoryId.isEmpty
        ? 0
        : booking.eventType.isEmpty
        ? 1
        : 2;

    return Container(
      margin: EdgeInsets.symmetric(vertical: height * 0.02),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: width * 0.04),
        child: Row(
          children: [
            _buildStepDot(0, activeStep >= 0, 'Category', width, height),
            Expanded(child: _buildStepLine(activeStep >= 1)),
            _buildStepDot(1, activeStep >= 1, 'Details', width, height),
            Expanded(child: _buildStepLine(activeStep >= 2)),
            _buildStepDot(2, activeStep >= 2, 'Confirm', width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildStepDot(
    int step,
    bool isActive,
    String label,
    double width,
    double height,
  ) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isActive
                ? Theme.of(context).colorScheme.onSecondary
                : Theme.of(context).colorScheme.primaryFixedDim,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Theme.of(
                        context,
                        // ignore: deprecated_member_use
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: isActive
                ? Icon(
                    Icons.check,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 18,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
        SizedBox(height: height * 0.01),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondaryFixed,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: isActive
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildEventTypeSection(
    String categoryId,
    ColorScheme colorscheme,
    double width,
    double height,
  ) {
    final booking = ref.watch(eventBookingProvider);
    final options = _eventTypeOptions[categoryId] ?? [];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Event Type',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.014),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: DropdownButtonFormField<String>(
              value:
                  booking.eventType.isNotEmpty &&
                      options.contains(booking.eventType)
                  ? booking.eventType
                  : null,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.all(16),
                hintText: 'Select event type',
                hintStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(
                    context,
                    // ignore: deprecated_member_use
                  ).colorScheme.secondary.withOpacity(0.2),
                  fontSize: 11,
                ),
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              icon: Icon(
                Icons.arrow_drop_down_rounded,
                color: Theme.of(context).colorScheme.secondary,
                size: 24,
              ),
              iconSize: 24,
              borderRadius: BorderRadius.circular(12),
              items: options.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                ref.read(eventBookingProvider.notifier).setEventType(value!);
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select an event type';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalOptions(
    String categoryId,
    ColorScheme colorscheme,
    TextTheme texttheme,
    double height,
    double width,
  ) {
    final booking = ref.watch(eventBookingProvider);
    final options = _additionalOptions[categoryId] ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: width * 0.01),
            Text(
              'Additional Services',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 14,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.01),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: options.keys.map((key) {
              return Container(
                margin: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: booking.additionalOptions[key] == true
                      // ignore: deprecated_member_use
                      ? Theme.of(
                          context,
                          // ignore: deprecated_member_use
                        ).colorScheme.secondaryFixed.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CheckboxListTile(
                  title: Text(
                    _formatOptionName(key),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontSize: 13,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  value: booking.additionalOptions[key] ?? false,
                  onChanged: (value) {
                    ref
                        .read(eventBookingProvider.notifier)
                        .setAdditionalOption(key, value);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  activeColor: Theme.of(context).colorScheme.secondary,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _formatOptionName(String key) {
    return key
        .replaceAllMapped(RegExp(r'[A-Z]'), (match) => ' ${match.group(0)}')
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join(' ')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = ref.watch(eventCategoriesProvider);
    final booking = ref.watch(eventBookingProvider);
    final textTheme = Theme.of(context).textTheme;
    final currentuser = ref.read(currentUserProvider);
    log('Current User: $currentuser');
    log('Current User Phone: ${currentuser?.phoneNumber}');
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Book Your Event',
        titleWidget: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Your Event',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 16,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            Text(
              'Create memorable experiences',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        toolbarHeight: kToolbarHeight + 16,
        actions: [
          IconButton(
            onPressed: () {
              context.push('/my-bookings'); // or use Navigator.push
            },
            icon: Icon(Icons.event_available),
            tooltip: 'View My Bookings',
          ),
        ],
      ),

      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainerLow,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            _buildStepIndicator(height, width),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: ListView(
                    physics: AlwaysScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: EdgeInsets.all(width * 0.02),
                    children: [
                      Container(
                        padding: EdgeInsets.all(height * 0.02),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: colorScheme.shadow.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.category,
                                  color: colorScheme.primary,
                                  size: 24,
                                ),
                                SizedBox(width: width * 0.02),
                                Text(
                                  'Select Event Category',
                                  style: Theme.of(context).textTheme.labelLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.w400,
                                        color: colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: height * 0.02),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio: 0.9,
                                  ),
                              itemCount: categories.length,
                              itemBuilder: (context, index) {
                                final category = categories[index];
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  child: CategoryCard(
                                    icon: category.icon,
                                    title: category.name,
                                    description: category.description,
                                    isSelected:
                                        booking.categoryId == category.id,
                                    onTap: () {
                                      ref
                                          .read(eventBookingProvider.notifier)
                                          .setCategory(category.id);
                                    },
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      if (booking.categoryId.isNotEmpty) ...[
                        SizedBox(height: height * 0.02),
                        // Event Details Card
                        Container(
                          padding: EdgeInsets.all(height * 0.02),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildEventTypeSection(
                                booking.categoryId,
                                colorScheme,
                                width,
                                height,
                              ),
                              SizedBox(height: height * 0.02),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Text(
                                    'Select Date & Time',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.014),
                              Container(
                                padding: EdgeInsets.all(height * 0.01),
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: DateTimePicker(
                                  selectedDate: booking.selectedDate,
                                  selectedTime: booking.selectedTime,
                                  endingTime: booking.endingTime,
                                  onDateChanged: (date) {
                                    ref
                                        .read(eventBookingProvider.notifier)
                                        .setDate(date);
                                  },
                                  onTimeChanged: (time) {
                                    ref
                                        .read(eventBookingProvider.notifier)
                                        .setTime(time);
                                  },
                                  onEndingTimeChanged: (endingTime) {
                                    ref
                                        .read(eventBookingProvider.notifier)
                                        .setEndingTime(endingTime);
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.024),
                              Row(
                                children: [
                                  Icon(
                                    Icons.people,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Text(
                                    'Number of Guests',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.014),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    // ignore: deprecated_member_use
                                    color: Theme.of(
                                      context,
                                      // ignore: deprecated_member_use
                                    ).colorScheme.secondary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: DropdownButtonFormField<int>(
                                  initialValue: booking.numberOfGuests,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(
                                      width * 0.03,
                                    ),
                                  ),
                                  items: List.generate(20, (index) => index + 1)
                                      .map((int value) {
                                        return DropdownMenuItem<int>(
                                          value: value,
                                          child: Text(
                                            '$value ${value == 1 ? 'guest' : 'guests'}',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.secondary,
                                                ),
                                          ),
                                        );
                                      })
                                      .toList(),
                                  onChanged: (value) {
                                    ref
                                        .read(eventBookingProvider.notifier)
                                        .setGuests(value!);
                                  },
                                  validator: (value) {
                                    if (value == null || value < 1) {
                                      return 'Please select number of guests';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.02),
                        Container(
                          padding: EdgeInsets.all(width * 0.024),
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              // ignore: deprecated_member_use
                              color: Theme.of(
                                context,
                                // ignore: deprecated_member_use
                              ).colorScheme.secondary.withOpacity(0.3),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: colorScheme.shadow.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildAdditionalOptions(
                                booking.categoryId,
                                colorScheme,
                                textTheme,
                                height,
                                width,
                              ),
                              SizedBox(height: height * 0.025),
                              // Special Requests
                              Row(
                                children: [
                                  Icon(
                                    Icons.note_add,
                                    color: colorScheme.primary,
                                    size: 20,
                                  ),
                                  SizedBox(width: width * 0.01),
                                  Text(
                                    'Special Requests',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          fontSize: 14,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                        ),
                                  ),
                                ],
                              ),
                              SizedBox(height: height * 0.014),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    // ignore: deprecated_member_use
                                    color: Theme.of(
                                      context,
                                      // ignore: deprecated_member_use
                                    ).colorScheme.secondary.withOpacity(0.3),
                                    width: 1.5,
                                  ),
                                ),
                                child: TextFormField(
                                  controller: _specialRequestsController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    hintText:
                                        'Any special requirements or requests...',
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.all(
                                      width * 0.02,
                                    ),
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.secondary,
                                        ),
                                  ),
                                  onChanged: (value) {
                                    ref
                                        .read(eventBookingProvider.notifier)
                                        .setSpecialRequests(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: height * 0.03),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: colorScheme.secondaryFixed.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _submitBooking(height, width),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: EdgeInsets.symmetric(
                                vertical: height * 0.013,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send, color: colorScheme.onPrimary),
                                SizedBox(width: width * 0.01),
                                Text(
                                  'Submit Booking Request',
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                      SizedBox(height: height * 0.1),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
