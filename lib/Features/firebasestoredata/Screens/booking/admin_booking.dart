// features/Admin/presentation/admin_bookings_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coffee_exult_app/Features/firebasestoredata/Screens/booking/booking_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() =>
      _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  final Map<String, String> _predefinedResponses = {
    'approved':
        'We\re excited to host your event at Exult Coffee Shop! Our team will be in touch shortly to confirm the details and discuss any special arrangements you may need.',
    'rejected_time':
        'We apologize, but the requested time slot is unfortunately unavailable. We\'d be happy to suggest alternative dates/times that work for you.',
    'rejected_capacity':
        'Due to space constraints, we\'re unable to accommodate the number of guests for this event type. We can discuss alternative options.',
    'rejected_venue':
        'This event type requires special arrangements that we\'re currently unable to provide at our venue.',
    'custom': '',
  };

  // features/Admin/presentation/admin_bookings_screen.dart - Update the build method
  @override
  Widget build(BuildContext context) {
    final bookings = ref.watch(filteredBookingsProvider);
    final stats = ref.watch(bookingStatsProvider);
    // final filter = ref.watch(bookingFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Bookings Management'),
        actions: [_buildFilterDropdown(), const SizedBox(width: 16)],
      ),
      body: Column(
        children: [
          // Statistics Card - FIX: Use Consumer to refresh stats
          Consumer(
            builder: (context, ref, child) {
              return stats.when(
                data: (statsData) => _buildStatsCard(statsData, context),
                loading: () => const LinearProgressIndicator(),
                error: (error, stack) => Container(
                  padding: const EdgeInsets.all(16),
                  child: Text('Error loading stats: $error'),
                ),
              );
            },
          ),

          // Bookings List
          Expanded(
            child: bookings.isEmpty
                ? const Center(child: Text('No bookings found'))
                : RefreshIndicator(
                    onRefresh: () async {
                      // Refresh both bookings and stats
                      ref.invalidate(adminBookingsProvider);
                      ref.invalidate(bookingStatsProvider);
                    },
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(bookings[index], context);
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Map<String, int> stats, BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem('Total', stats['total'] ?? 0, Colors.blue),
            _buildStatItem('Pending', stats['pending'] ?? 0, Colors.orange),
            _buildStatItem('Approved', stats['approved'] ?? 0, Colors.green),
            _buildStatItem('Rejected', stats['rejected'] ?? 0, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Text(
            count.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildFilterDropdown() {
    return DropdownButton<String>(
      value: ref.read(bookingFilterProvider),
      onChanged: (value) {
        ref.read(bookingFilterProvider.notifier).state = value!;
      },
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Bookings')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'approved', child: Text('Approved')),
        DropdownMenuItem(value: 'rejected', child: Text('Rejected')),
      ],
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking, BuildContext context) {
    final bookingDetails = booking['bookingDetails'] ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info and status
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(
                    booking['status'],
                  ).withValues(alpha: 0.2),
                  child: Icon(
                    _getStatusIcon(booking['status']),
                    color: _getStatusColor(booking['status']),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking['userName'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '• ${booking['userId']}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(booking['status']),
              ],
            ),

            const SizedBox(height: 16),

            // Booking Details
            _buildDetailRow('Event Type', bookingDetails['eventType'] ?? 'N/A'),
            _buildDetailRow(
              'Date',
              _formatDate(bookingDetails['selectedDate']),
            ),
            _buildDetailRow(
              'Time',
              '${_formatTime(bookingDetails['selectedTime'])} - ${_formatTime(bookingDetails['endingTime'])}',
            ),
            _buildDetailRow(
              'Guests',
              '${bookingDetails['numberOfGuests']} people',
            ),

            if (bookingDetails['specialRequests']?.isNotEmpty == true) ...[
              _buildDetailRow(
                'Special Requests',
                bookingDetails['specialRequests'],
              ),
            ],

            if (booking['adminResponse']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Your Response:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(booking['adminResponse']),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 16),

            // Admin Actions (only for pending bookings)
            if (booking['status'] == 'pending') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _handleBookingAction(booking, 'approved', context),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showRejectionOptions(booking, context),
                      icon: const Icon(Icons.close, size: 18),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
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

  String _formatDate(dynamic date) {
    if (date is Timestamp) {
      final datetime = date.toDate();
      return '${datetime.day}/${datetime.month}/${datetime.year}';
    }
    return 'Invalid date';
  }

  String _formatTime(dynamic time) {
    if (time is Map) {
      final hour = time['hour'] ?? 0;
      final minute = time['minute'] ?? 0;
      final period = hour >= 12 ? 'PM' : 'AM';
      final displayHour = hour > 12 ? hour - 12 : hour;
      return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
    }
    return 'Invalid time';
  }

  void _handleBookingAction(
    Map<String, dynamic> booking,
    String action,
    BuildContext context,
  ) async {
    final adminService = ref.read(adminFirestoreServiceProvider);
    final response = await _showResponseDialog(context, action, booking);

    if (response != null) {
      try {
        await adminService.updateBookingStatus(
          bookingId: booking['bookingId'],
          status: action,
          adminResponse: response,
          userId: booking['userId'],
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Booking ${action == 'approved' ? 'approved' : 'rejected'} successfully',
            ),
            backgroundColor: action == 'approved'
                ? Colors.green
                : Colors.orange,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  void _showRejectionOptions(
    Map<String, dynamic> booking,
    BuildContext context,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Rejection Reason',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRejectionOption(
              context,
              'Time Unavailable',
              'We apologize, but the requested time slot is unavailable.',
              booking,
            ),
            _buildRejectionOption(
              context,
              'Capacity Issue',
              'Unfortunately, we cannot accommodate the number of guests.',
              booking,
            ),
            _buildRejectionOption(
              context,
              'Venue Constraints',
              'This event type requires arrangements we cannot provide.',
              booking,
            ),
            _buildRejectionOption(
              context,
              'Custom Response',
              'Write your own response...',
              booking,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRejectionOption(
    BuildContext context,
    String title,
    String response,
    Map<String, dynamic> booking,
  ) {
    return ListTile(
      leading: const Icon(Icons.info_outline),
      title: Text(title),
      subtitle: response != 'Write your own response...'
          ? Text(response)
          : null,
      onTap: () {
        Navigator.pop(context);
        if (title == 'Custom Response') {
          _handleBookingAction(booking, 'rejected', context);
        } else {
          _handleBookingAction(booking, 'rejected', context);
        }
      },
    );
  }

  Future<String?> _showResponseDialog(
    BuildContext context,
    String action,
    Map<String, dynamic> booking,
  ) async {
    TextEditingController controller = TextEditingController();

    // Pre-fill with appropriate response
    final bookingDetails = booking['bookingDetails'] ?? {};
    // final eventType = bookingDetails['eventType'] ?? 'event';

    if (action == 'approved') {
      controller.text = _predefinedResponses['approved']!;
    }

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${action.toUpperCase()} Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Event: ${bookingDetails['eventType']}'),
            Text('User: ${booking['userName']}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Enter your response to the user...',
                labelText: 'Admin Response',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(action == 'approved' ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );
  }
}
