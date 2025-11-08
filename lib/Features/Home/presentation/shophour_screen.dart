import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/core.dart';

class ShophourScreen extends ConsumerWidget {
  const ShophourScreen({super.key});
  // Shop hours data
  final Map<String, String> shopHours = const {
    'Monday': '7:00 AM - 7:00 PM',
    'Tuesday': '7:00 AM - 7:00 PM',
    'Wednesday': '7:00 AM - 7:00 PM',
    'Thursday': '7:00 AM - 7:00 PM',
    'Friday': '7:00 AM - 7:00 PM',
    'Saturday': '7:00 AM - 7:00 PM',
    'Sunday': '7:00 AM - 7:00 PM',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final now = DateTime.now();
    final today = DateFormat('EEEE').format(now); // e.g. "Monday"
    final todayHours = shopHours[today] ?? 'Closed';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        titleText: 'Shop Hours',
        centerTitle: true,
        backgroundColor: AppColors.primary,
        // foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTodayHoursCard(context, today, todayHours, width, height),
            SizedBox(height: height * 0.03),
            _buildWeeklyScheduleHeader(),
            SizedBox(height: height * 0.02),
            _buildWeeklyScheduleList(context, today, width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayHoursCard(
    BuildContext context,
    String today,
    String todayHours,
    double width,
    double height,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(width * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Today's Hours",
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: height * 0.015),
          _buildDayTimeRow(
            context,
            today,
            todayHours,
            isToday: true,
            width: width,
            height: height,
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleHeader() {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        "Weekly Schedule",
        style: GoogleFonts.dmSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildWeeklyScheduleList(
    BuildContext context,
    String today,
    double width,
    double height,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: ListView.separated(
            itemCount: shopHours.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              thickness: 1,
              color: AppColors.lightBorder,
              indent: width * 0.05,
              endIndent: width * 0.05,
            ),
            itemBuilder: (context, index) {
              final day = shopHours.keys.elementAt(index);
              final hours = shopHours[day]!;
              return _buildDayTimeRow(
                context,
                day,
                hours,
                isToday: day == today,
                width: width,
                height: height,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDayTimeRow(
    BuildContext context,
    String day,
    String time, {
    required bool isToday,
    required double width,
    required double height,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.015,
      ),
      decoration: BoxDecoration(
        color: isToday
            ? AppColors.accent.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            height: height * 0.05,
            width: width * 0.1,
            decoration: BoxDecoration(
              color: isToday
                  ? AppColors.accent.withValues(alpha: 0.2)
                  : AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Icon(
                Icons.calendar_today,
                color: isToday ? AppColors.accent : AppColors.primary,
                size: 20,
              ),
            ),
          ),
          SizedBox(width: width * 0.04),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  day,
                  style: GoogleFonts.dmSans(
                    fontSize: 15,
                    fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
                    color: isToday ? AppColors.accent : AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: height * 0.004),
                Text(
                  time,
                  style: GoogleFonts.dmSans(
                    fontSize: 13,
                    color: isToday ? AppColors.accent : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (isToday)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: width * 0.03,
                vertical: height * 0.006,
              ),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Today',
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
