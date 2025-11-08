// features/Event/presentation/user_bookings_screen.dart
import 'package:coffee_exult_app/Authentication/provider/current_user.dart';
import 'package:coffee_exult_app/Features/Event/provider/event_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/widget/widgets.dart';

class UserBookingsScreen extends ConsumerWidget {
  const UserBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final userBookings = ref.watch(
      userBookingsProvider(currentUser?.phoneNumber ?? ''),
    );
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: CustomAppBar(titleText: 'Book Your Event', centerTitle: true),
      body: userBookings.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (bookings) {
          if (bookings.isEmpty) {
            return Center(
              child: Text(
                'No bookings found',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bookings.length,
            itemBuilder: (context, index) {
              final booking = bookings[index];
              return _buildBookingCard(
                booking,
                context,
                height,
                width,
                colorScheme,
                textTheme,
              );
            },
          );
        },
      ),
    );
  }

  // ignore: strict_top_level_inference
  Widget _buildBookingCard(
    booking,
    BuildContext context,
    double height,
    double width,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Card(
      margin: EdgeInsets.only(bottom: height * 0.017),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(width * 0.018),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildStatusIcon(booking.status, height, width),
                SizedBox(width: width * 0.014),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.eventType,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: 13,
                        ),
                      ),
                      Text(
                        _formatDate(booking.selectedDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          // ignore: deprecated_member_use
                          color: Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, booking.status, width, height),
              ],
            ),

            SizedBox(height: height * 0.008),

            // Booking Details
            _buildDetailRow(
              context,
              'Time',
              '${booking.selectedTime.format(context)} - ${booking.endingTime.format(context)}',
              width,
              height,
            ),
            _buildDetailRow(
              context,
              'Guests',
              '${booking.numberOfGuests} people',
              width,
              height,
            ),
            _buildDetailRow(
              context,
              'Category',
              _getCategoryName(booking.categoryId),
              width,
              height,
            ),

            if (booking.specialRequests?.isNotEmpty == true) ...[
              _buildDetailRow(
                context,
                'Special Requests',
                booking.specialRequests!,
                width,
                height,
              ),
            ],

            // Admin Response (if available)
            if (booking.status != 'pending' &&
                booking.adminResponse?.isNotEmpty == true) ...[
              SizedBox(height: height * 0.01),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(width * 0.018),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: _getStatusColor(booking.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    // ignore: deprecated_member_use
                    color: _getStatusColor(
                      booking.status,
                    ).withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          booking.status == 'approved'
                              ? Icons.check_circle
                              : Icons.info,
                          color: _getStatusColor(booking.status),
                          size: 16,
                        ),
                        SizedBox(width: width * 0.014),
                        Text(
                          booking.status == 'approved'
                              ? 'Approved!'
                              : 'Admin Response',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getStatusColor(booking.status),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: height * 0.002),
                    Text(
                      booking.adminResponse!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        // ignore: deprecated_member_use
                        color: Theme.of(
                          context,
                          // ignore: deprecated_member_use
                        ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (booking.additionalOptions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Additional Services:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              _buildAdditionalOptions(booking.additionalOptions, context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalOptions(
    Map<String, dynamic> additionalOptions,
    BuildContext context,
  ) {
    final enabledOptions = additionalOptions.entries
        .where((entry) => entry.value == true)
        .toList();

    if (enabledOptions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: enabledOptions.map((entry) {
        return Chip(
          label: Text(_formatOptionName(entry.key)),
          // ignore: deprecated_member_use
          backgroundColor: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.1),
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontSize: 12,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusIcon(String status, double width, double height) {
    return Container(
      padding: EdgeInsets.all(width * 0.01),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: _getStatusColor(status).withValues(alpha: 0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        _getStatusIcon(status),
        color: _getStatusColor(status),
        size: 20,
      ),
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    String status,
    double width,
    double height,
  ) {
    final color = _getStatusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.014,
        vertical: height * 0.008,
      ),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: color, fontSize: 10),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    String label,
    String value,
    double width,
    double height,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: height * 0.008),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: width * 0.3,
            child: Text(
              '$label :',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontSize: 11,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primaryContainer,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.orange;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'approved':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.pending_actions;
      default:
        return Icons.pending;
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEE, MMM d, yyyy').format(date);
  }

  String _getCategoryName(String categoryId) {
    // You'll need to import your categories provider or define this method
    final categories = {
      'private': 'Private Celebration',
      'music': 'Live Music & Open Mic',
      'workshop': 'Workshop & Meeting',
      'corporate': 'Corporate Event',
    };
    return categories[categoryId] ?? 'Unknown Category';
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
}
