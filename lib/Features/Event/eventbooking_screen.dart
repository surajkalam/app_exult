
import 'package:coffee_exult_app/Authentication/authenticationService.dart';
import 'package:coffee_exult_app/Features/Event/provider/eventprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';
import 'package:lottie/lottie.dart';
import '../../core/core.dart';

class EventbookingScreen2 extends ConsumerWidget {
  const EventbookingScreen2({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final authState = ref.watch(authNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Event Booking',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: authState.when(
        data: (user) {
          if (user == null) {
            return _buildSignUpPrompt(context,colorScheme,textTheme);
          } else {
            return _buildBookingContent(height, width, user,colorScheme,textTheme);
          }
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildSignUpPrompt(context,colorScheme,textTheme),
      ),
    );
  }
  // Build sign up prompt
  Widget _buildSignUpPrompt(BuildContext context,ColorScheme colorscheme,TextTheme texttheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          Lottie.asset('Assets/Icons/404 error. oops page not found.json',
          height: 200,
          width:280 ,
          fit: BoxFit.fill
          ),
            SizedBox(height: 16),
            Text(
              'Sign In to Book Events',
              style: textTheme.titleMedium?.copyWith(
              color: colorscheme.primaryContainer,
            ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Create an account or sign in to book events and make reservations',
              textAlign: TextAlign.center,
               style: textTheme.bodyMedium?.copyWith(
              color: colorscheme.secondary,
              fontSize: 11
            ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () =>
                    context.go('/phone-auth'), // Redirect to phone auth
                style: ElevatedButton.styleFrom(
                  backgroundColor:colorscheme.onPrimaryFixedVariant,
                  foregroundColor: colorscheme. onSecondaryFixed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text('Sign Up / Sign In',
               style: textTheme.bodyMedium?.copyWith(
              color: colorscheme.onSecondaryFixed,
              fontSize: 11
            ),
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => context.go('/navbar'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: colorscheme.onPrimaryFixedVariant),
                ),
                child: Text(
                  'Continue as Guest',
                  style: TextStyle(color: colorscheme.onPrimaryFixedVariant),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build booking content for authenticated users
  Widget _buildBookingContent(double height, double width, user ,ColorScheme colorscheme,TextTheme texttheme) {
    // final String primaryContact =
    //     user.phoneNumber != null && user.phoneNumber!.isNotEmpty
    //     ? user.phoneNumber!
    //     : user.email ?? 'Unknown User';
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildWelcomeCard(user, height, width,colorscheme,textTheme),
          SizedBox(height: 24),
          _buildContactSection(height, width,colorscheme,textTheme),
          SizedBox(height: 24),
          _buildBookingSection(height, width,colorscheme,textTheme),
          SizedBox(height: 24),
        ],
      ),
    );
  }

  // Build welcome card
  // ignore: strict_top_level_inference
  Widget _buildWelcomeCard(user, double height, double width,ColorScheme colorscheme,TextTheme texttheme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorscheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorscheme.onPrimaryFixedVariant,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Iconsax.calendar_add, size: 32, color:colorscheme.onSecondaryFixed),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome, ${user.email?.split('@').first ?? 'Guest'}!",
                 style: texttheme.bodyLarge?.copyWith(
                 color:colorscheme.primary,
                 ),
                ),
                SizedBox(height: 4),
                Text(
                  "Book your perfect event experience",
                  style: texttheme.bodySmall?.copyWith(
                 color:colorscheme.secondary,
                 fontSize: 10,
                 ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build contact section
  Widget _buildContactSection(double height, double width,ColorScheme colorscheme,TextTheme texttheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          "Contact Us",
          style: texttheme.labelMedium?.copyWith(
            color: colorscheme.primary,
            fontSize: 14,
          ),
        ),
        children: [_buildContactForm(height, width,colorscheme,texttheme)],
      ),
    );
  }

  // Build contact form
  Widget _buildContactForm(double height, double width,ColorScheme colorscheme,TextTheme texttheme) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController suggestionController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          _buildTextField(
            controller: nameController,
            hintText: "Enter your name",
            icon: Iconsax.user,
            colorscheme:  colorscheme,
             texttheme:   texttheme,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: emailController,
            hintText: "Enter your email",
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            colorscheme:  colorscheme,
             texttheme:   texttheme,
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: suggestionController,
            hintText: "Your suggestions or questions",
            icon: Iconsax.message,
            maxLines: 4,
            colorscheme:  colorscheme,
             texttheme:   texttheme,
          ),
          SizedBox(height: 24),
          _buildSubmitButton(
            height: height * 0.05,
            width: width * 0.6,
            text: "Send Message",
            onPressed: () {
              // Handle form submission
            },
             colorscheme:  colorscheme,
             texttheme:   texttheme,
          ),
        ],
      ),
    );
  }

  // Build booking section
  Widget _buildBookingSection(double height, double width,ColorScheme colorscheme,TextTheme texttheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
        title: Text(
          "Book a Table",
           style: texttheme.bodyMedium?.copyWith(
            color: colorscheme.primary,
            // fontSize: 14,
          ),
        ),
        children: [_buildBookingForm(height, width,colorscheme,texttheme)],
      ),
    );
  }

  // Build booking form
  Widget _buildBookingForm(double height, double width, ColorScheme colorscheme,TextTheme texttheme) {
    TextEditingController nameController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController reservationDate = TextEditingController();
    TextEditingController phonenumberController = TextEditingController();
    TextEditingController guestnumberController = TextEditingController();
    TextEditingController requestController = TextEditingController();

    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Planning a visit? Skip the wait and reserve your favorite seat in advance. Quick, easy, and confirmed in minutes!",
            style: texttheme.bodySmall?.copyWith(
            color: colorscheme.secondary,
            fontSize: 11
          ),
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: nameController,
            hintText: "Enter your name",
            icon: Iconsax.user,
            colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: emailController,
            hintText: "Enter your email",
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
             colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: phonenumberController,
            hintText: "Enter phone number",
            icon: Iconsax.call,
            keyboardType: TextInputType.phone,
             colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: reservationDate,
            hintText: "Date of reservation",
            icon: Iconsax.calendar,
             colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 16),
          _buildTimeSlotSection(height, width,colorscheme,texttheme),
          SizedBox(height: 16),
          _buildTextField(
            controller: guestnumberController,
            hintText: "Number of guests",
            icon: Iconsax.people,
            keyboardType: TextInputType.number,
             colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 16),
          _buildTextField(
            controller: requestController,
            hintText: "Special requests",
            icon: Iconsax.note,
            maxLines: 3,
             colorscheme: colorscheme,
            texttheme: texttheme
          ),
          SizedBox(height: 24),
          _buildSubmitButton(
            height: height * 0.05,
            width: width * 0.6,
            text: "Confirm Booking",
            onPressed: () {
              // Handle booking submission
            },
            colorscheme: colorscheme,
            texttheme: texttheme
          ),
        ],
      ),
    );
  }

  // Build text field with icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required ColorScheme colorscheme,
    required TextTheme texttheme

  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: texttheme.bodySmall?.copyWith(color: colorscheme.secondary,fontSize: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color:colorscheme.shadow),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorscheme.shadow),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color:colorscheme.onPrimaryFixedVariant),
        ),
        prefixIcon: Icon(icon, color: colorscheme.secondaryFixed),
        contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
    );
  }

  // Build time slot section
  Widget _buildTimeSlotSection(double height, double width,ColorScheme colorscheme,TextTheme texttheme) {
    final List<Map<String, String>> timeSlots = [
      {'label': 'Morning', 'time': '8:00 AM - 12:00 PM'},
      {'label': 'Afternoon', 'time': '12:00 PM - 4:00 PM'},
      {'label': 'Evening', 'time': '4:00 PM - 8:00 PM'},
      {'label': 'Night', 'time': '8:00 PM - 10:00 PM'},
    ];

    return Consumer(
      builder: (context, ref, child) {
        final selectedTimeSlot = ref.watch(timeSlotProvider);
        final timeSlotNotifier = ref.read(timeSlotProvider.notifier);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preferred Time Slot',
            style: texttheme.bodyMedium?.copyWith(
            color: colorscheme.primary,
            fontSize: 13,
          ),
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: timeSlots.map((slot) {
                final isSelected = selectedTimeSlot == slot['time'];
                return ChoiceChip(
                  label: Text(
                    '${slot['label']}\n${slot['time']}',
                    style: texttheme.bodySmall?.copyWith(
                      color: isSelected ? colorscheme.onSecondaryFixed : colorscheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    timeSlotNotifier.selectTimeSlot(
                      selected ? slot['time'] : null,
                    );
                  },
                  // ignore: deprecated_member_use
                  selectedColor: colorscheme.onPrimaryFixedVariant.withOpacity(0.6),
                  // ignore: deprecated_member_use
                  backgroundColor:colorscheme.primary.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
              }).toList(),
            ),
            if (selectedTimeSlot != null) ...[
              SizedBox(height: 8),
              Text(
                'Selected: $selectedTimeSlot',
            style: texttheme.bodySmall?.copyWith(
            color: colorscheme.secondaryFixed,
            fontSize: 11,
          ),
              ),
            ],
          ],
        );
      },
    );
  }

  // Build submit button
  Widget _buildSubmitButton({
    required double height,
    required double width,
    required String text,
    required VoidCallback onPressed,
    required ColorScheme colorscheme,
    required TextTheme texttheme ,
  }) {
    return SizedBox(
      width: width,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorscheme.onPrimaryFixedVariant,
          foregroundColor: colorscheme.onSecondaryFixed,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
        ),
        child: Text(
          text,
        style: texttheme.bodyMedium?.copyWith(
            color: colorscheme.onSecondaryFixed,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
