import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/core.dart';

final selectedOptionProvider = StateProvider<int?>((ref) => 1);

class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: CustomAppBar(
        titleText: 'Help & Support',
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Column(
            children: [
              _buildExpansionTile(
                context: context,
                title: "FAQ",
                icon: Icons.help_outline,
                child: FQAcontainer(height, width, colorScheme, textTheme),
                isIOS: isIOS,
                colorscheme: colorScheme,
                texttheme: textTheme,
              ),
              SizedBox(height: height * 0.02),
              _buildExpansionTile(
                context: context,
                title: "Contact Support",
                icon: Icons.support_agent,
                child: _buildContactSupport(
                  context,
                  height,
                  width,
                  colorScheme,
                  textTheme,
                ),
                isIOS: isIOS,
                colorscheme: colorScheme,
                texttheme: textTheme,
              ),
              SizedBox(height: height * 0.02),
              _buildExpansionTile(
                context: context,
                title: "Order Support",
                icon: Icons.shopping_bag,
                child: ordersupport(
                  height,
                  width,
                  context,
                  colorScheme,
                  textTheme,
                ),
                isIOS: isIOS,
                colorscheme: colorScheme,
                texttheme: textTheme,
              ),
              SizedBox(height: height * 0.02),
              _buildExpansionTile(
                context: context,
                title: "Store Information",
                icon: Icons.store,
                child: storeinfo(
                  context,
                  height,
                  width,
                  '8766866017',
                  colorScheme,
                  textTheme,
                ),
                isIOS: isIOS,
                colorscheme: colorScheme,
                texttheme: textTheme,
              ),
              SizedBox(height: height * 0.02),
              _buildExpansionTile(
                context: context,
                title: "Feedback & Suggestions",
                icon: Icons.feedback,
                child: feedbacksuggestion(
                  height,
                  width,
                  context,
                  colorScheme,
                  textTheme,
                ),
                isIOS: isIOS,
                colorscheme: colorScheme,
                texttheme: textTheme,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpansionTile({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
    required bool isIOS,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    // final width = MediaQuery.of(context).size.width;

    if (isIOS) {
      return CupertinoListSection.insetGrouped(
        margin: EdgeInsets.zero,
        children: [
          CupertinoListTile(
            title: Text(
              title,
              style: textTheme.bodyMedium?.copyWith(
                color: colorscheme.primaryContainer,
              ),
              //color:colorscheme.primaryContainer,
            ),
            leading: Icon(icon, color: colorscheme.secondaryFixed, size: 24),
            trailing: const Icon(CupertinoIcons.chevron_down, size: 18),
            onTap: () {
              _showIOSBottomSheet(context, title, child);
            },
          ),
        ],
      );
    } else {
      return ExpansionTile(
        leading: Icon(icon, color: colorscheme.secondaryFixed),
        backgroundColor: colorscheme.surface,
        iconColor: colorscheme.secondary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
        collapsedIconColor: colorscheme.secondary,
        collapsedBackgroundColor: colorscheme.surface,
        title: Text(
          title,
          style: textTheme.bodyMedium?.copyWith(
            color: colorscheme.primaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        children: [child],
      );
    }
  }

  void _showIOSBottomSheet(BuildContext context, String title, Widget content) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: Text(
          title,
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        message: content,
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text('Close', style: TextStyle(color: AppColors.primary)),
        ),
      ),
    );
  }

  Widget _buildContactSupport(
    BuildContext context,
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Padding(
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildContactOption(
            icon: Icons.phone,
            title: "Toll Free Customer Service",
            subtitle: "3746237467",
            onTap: () => _makePhoneCall('3746237467'),
            colorscheme: colorscheme,
            texttheme: textTheme,
          ),
          SizedBox(height: height * 0.02),
          _buildContactOption(
            icon: Icons.email,
            title: "Email Support",
            subtitle: "support@coffeeshop.com",
            onTap: () => _launchEmail('support@coffeeshop.com'),
            colorscheme: colorscheme,
            texttheme: textTheme,
          ),
          SizedBox(height: height * 0.02),
          _buildContactOption(
            icon: Icons.access_time,
            title: "Support Hours",
            subtitle: "Mon-Sun: 8AM - 10PM",
            onTap: () {},
            colorscheme: colorscheme,
            texttheme: textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: colorscheme.shadow.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: colorscheme.secondaryFixed, size: 24),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: texttheme.labelMedium?.copyWith(
                      color: colorscheme.primaryContainer,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: texttheme.bodySmall?.copyWith(
                      color: colorscheme.secondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  // Rest of the existing methods remain the same with minor styling improvements...

  Widget feedbacksuggestion(
    double height,
    double width,
    BuildContext context,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    TextEditingController requestController = TextEditingController();
    return Padding(
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorscheme.onSecondaryFixed,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: colorscheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: requestController,
              maxLines: 5,
              cursorHeight: 12,
              decoration: InputDecoration(
                hintText: "Share your feedback or suggestions...",
                hintStyle: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: colorscheme.secondary,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
            ),
          ),
          SizedBox(height: height * 0.03),
          SizedBox(
            width: double.infinity,
            child: CupertinoButton(
              color: colorscheme.onPrimaryFixedVariant,
              borderRadius: BorderRadius.circular(12),
              onPressed: () {
                _submitFeedback(requestController.text, context);
              },
              child: Text(
                "Submit Feedback",
                style: textTheme.labelMedium?.copyWith(
                  color: colorscheme.onSecondaryFixed,
                  fontWeight: FontWeight.w400,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _submitFeedback(String feedback, BuildContext context) {
    if (feedback.isEmpty) {
      _showIOSDialog(
        context,
        "Empty Feedback",
        "Please enter your feedback before submitting.",
      );
      return;
    }

    // Simulate feedback submission
    _showIOSDialog(
      context,
      "Thank You!",
      "Your feedback has been submitted successfully.",
    );
  }

  void _showIOSDialog(BuildContext context, String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailLaunchUri = Uri(scheme: 'mailto', path: email);

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    } else {
      throw 'Could not launch email';
    }
  }

  // Rest of your existing methods (FQAcontainer, _makePhoneCall, _launchWhatsApp,
  // _launchInstagram, _launchWebsite, storeinfo, ordersupport, containerwidget)
  // remain the same but with updated styling to match iOS aesthetics

  // ignore: non_constant_identifier_names
  Widget FQAcontainer(
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.02,
        vertical: height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFAQItem(
            question: "How do I place an order?",
            answer:
                "To place an order, simply browse our menu, select your items, customize them if needed, and proceed to checkout. You can pay using various methods including credit/debit cards, mobile wallets, or cash on delivery.",
            colorscheme,
            texttheme,
          ),
          _buildFAQItem(
            question: "What payment methods do you accept?",
            answer:
                "We accept all major credit and debit cards, PayPal, Google Pay, Apple Pay, and also offer cash on delivery option. All transactions are secure and encrypted for your safety.",
            colorscheme,
            texttheme,
          ),
          _buildFAQItem(
            question: "Rewards Program Explanations",
            answer:
                "For every purchase you make, you earn points that can be redeemed for free drinks and food items. You'll get 1 point for every dollar spent. Once you reach 100 points, you get a free drink of your choice!.",
            colorscheme,
            texttheme,
          ),
          _buildFAQItem(
            question: "Do you offer seasonal drinks?",
            answer:
                "Yes! We offer a rotating selection of seasonal drinks throughout the year. Our Pumpkin Spice Latte is available in the fall, Peppermint Mocha during winter, and refreshing fruit-infused iced drinks in the summer.",
            colorscheme,
            texttheme,
          ),
          _buildFAQItem(
            question: "Do you have gluten-free and dairy-free options?",
            answer:
                "Yes, we offer several gluten-free pastries and snacks. We also have dairy-free milk alternatives including almond milk, oat milk, and soy milk at no extra cost. Please inform our staff about any allergies so we can take extra precautions.",
            colorscheme,
            texttheme,
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(
    ColorScheme colorscheme,
    TextTheme texttheme, {
    required String question,
    required String answer,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.primary,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 8),
          Text(
            answer,
            style: texttheme.bodySmall?.copyWith(
              color: colorscheme.primary.withValues(alpha: 0.5),
              fontSize: 10,
            ),
          ),
          SizedBox(height: 16),
          Divider(height: 1, color: colorscheme.shadow),
        ],
      ),
    );
  }

  // Update storeinfo method to use iOS-style cards
  Widget storeinfo(
    BuildContext context,
    double height,
    double width,
    String number,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Padding(
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        children: [
          SizedBox(height: height * 0.02),
          Text(
            "Connect with us",
            style: texttheme.labelMedium?.copyWith(
              color: colorscheme.secondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: height * 0.02),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                context,
                imagePath: "assets/Icons/exault.jpg",
                onTap: () => _launchWebsite(
                  context,
                  'https://exultcoffeehouse.com/menu/',
                ),
                colorscheme: colorscheme,
                texttheme: texttheme,
              ),
              _buildSocialButton(
                context,
                imagePath: "assets/Icons/insta.jpg",
                onTap: () => _launchInstagram('', context),
                colorscheme: colorscheme,
                texttheme: texttheme,
              ),
              _buildSocialButton(
                context,
                imagePath: "assets/Icons/whattapp.jpg",
                onTap: () => _launchWhatsApp(
                  context,
                  phoneNumber: number,
                  message:
                      'Hii I am user of exault Coffee shop .Whatapp Special Today.',
                ),
                colorscheme: colorscheme,
                texttheme: texttheme,
              ),
              _buildSocialButton(
                context,
                imagePath: "assets/Icons/call.jpg",
                onTap: () => _makePhoneCall(number),
                colorscheme: colorscheme,
                texttheme: texttheme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String imagePath,
    required VoidCallback onTap,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: colorscheme.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    // Remove any non-digit characters except '+'
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final Uri launchUri = Uri(scheme: 'tel', path: cleanedNumber);

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $launchUri';
    }
  }

  //Redirect on Whatapp
  Future<void> _launchWhatsApp(
    BuildContext context, {
    String? phoneNumber,
    String? message,
  }) async {
    try {
      String url = 'https://wa.me/';

      if (phoneNumber != null) {
        // Remove all non-digit characters
        String cleanedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');

        // Remove plus sign if present
        cleanedNumber = cleanedNumber.replaceAll('+', '');

        // Check if number has country code
        if (cleanedNumber.isEmpty) {
          throw 'Phone number is empty';
        }

        // If number doesn't start with country code, you might want to add it
        // For example, if you expect US numbers without country code:
        if (!cleanedNumber.startsWith('1') && cleanedNumber.length == 10) {
          cleanedNumber = '91$cleanedNumber'; // Add US country code
        }

        url += cleanedNumber;
      } else {
        // If no phone number provided, open WhatsApp main screen
        url = 'https://wa.me/';
      }

      if (message != null) {
        // Add message parameter with proper encoding
        url += '?text=${Uri.encodeComponent(message)}';
      }

      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw 'WhatsApp is not installed on this device';
      }
    } catch (e) {
      log('Error launching WhatsApp: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open WhatsApp: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  //Goes on coffee shop Insta page
  Future<void> _launchInstagram(
    String usernameOrUrl,
    BuildContext context,
  ) async {
    try {
      String url;

      // Check if input is a URL or username
      if (usernameOrUrl.startsWith('http')) {
        url = usernameOrUrl;
      } else {
        // Remove @ symbol if present and create Instagram profile URL
        String cleanedUsername = usernameOrUrl.replaceFirst('@', '');
        url = 'https://www.instagram.com/$cleanedUsername/';
      }

      // Try to open in Instagram app first
      String appUrl = url.replaceFirst(
        'https://www.instagram.com/',
        'instagram://user?username=',
      );

      if (await canLaunchUrl(Uri.parse(appUrl))) {
        await launchUrl(Uri.parse(appUrl));
      }
      // Fallback to opening in browser
      else if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch Instagram';
      }
    } catch (e) {
      log('Error launching Instagram: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open Instagram'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Exault Coffee Shop Website
  Future<void> _launchWebsite(BuildContext context, String url) async {
    try {
      // Ensure the URL has https:// prefix
      String formattedUrl = url;
      if (!formattedUrl.startsWith('http://') &&
          !formattedUrl.startsWith('https://')) {
        formattedUrl = 'https://$formattedUrl';
      }

      final Uri uri = Uri.parse(formattedUrl);

      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView, // Opens in in-app browser
          webViewConfiguration: const WebViewConfiguration(
            enableJavaScript: true,
            enableDomStorage: true,
          ),
        );
      } else {
        throw 'Could not launch website';
      }
    } catch (e) {
      log('Error launching website: $e');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open website: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Widget ordersupport(
    double height,
    double width,
    BuildContext context,
    ColorScheme colorscheme,
    TextTheme textTheme,
  ) {
    final List<Map<String, dynamic>> orderSupportOptions = [
      {'title': 'Missing item', 'icon': Icons.inventory_2_outlined},
      {
        'title': 'Order not received / delayed',
        'icon': Icons.access_time_outlined,
      },
      {'title': 'Wrong item delivered', 'icon': Icons.warning_amber_outlined},
      {
        'title': 'Change delivery address or pickup time',
        'icon': Icons.location_on_outlined,
      },
      {'title': 'Payment issues', 'icon': Icons.payment_outlined},
      {'title': 'Order cancellation / refund', 'icon': Icons.cancel_outlined},
    ];

    return Padding(
      padding: EdgeInsets.all(width * 0.03),
      child: Column(
        children: [
          Text(
            "Select the issue you're facing with your order",
            style: textTheme.bodySmall?.copyWith(
              color: colorscheme.secondary,
              fontSize: 11,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: height * 0.02),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: width * 0.03,
              mainAxisSpacing: height * 0.015,
              childAspectRatio: 1.5,
            ),
            itemCount: orderSupportOptions.length,
            itemBuilder: (context, index) {
              final option = orderSupportOptions[index];
              return _buildOrderSupportCard(
                context,
                icon: option['icon'] as IconData,
                title: option['title'] as String,
                onTap: () => _handleOrderSupportSelection(
                  context,
                  option['title'] as String,
                ),
                colorscheme: colorscheme,
                texttheme: textTheme,
              );
            },
          ),
          SizedBox(height: height * 0.03),
          _buildAdditionalHelpSection(
            context,
            height,
            width,
            colorscheme,
            textTheme,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSupportCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorscheme.onPrimary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: colorscheme.shadow.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: colorscheme.primaryFixedDim, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 28, color: colorscheme.secondaryFixed),
              SizedBox(height: 8),
              Text(
                title,
                style: textTheme.labelMedium?.copyWith(
                  color: colorscheme.secondary,
                  fontWeight: FontWeight.w400,
                  fontSize: 09,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalHelpSection(
    BuildContext context,
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Column(
      children: [
        Divider(color: colorscheme.shadow, thickness: 1, height: 20),
        SizedBox(height: height * 0.02),
        Text(
          "Need immediate assistance?",
          style: textTheme.labelMedium?.copyWith(
            color: colorscheme.primaryContainer,
          ),
        ),
        SizedBox(height: height * 0.01),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.phone,
              label: "Call",
              onTap: () => _makePhoneCall('3746237467'),
              colorscheme: colorscheme,
              texttheme: texttheme,
            ),
            SizedBox(width: width * 0.04),
            _buildQuickActionButton(
              context,
              icon: Icons.chat,
              label: "Chat",
              onTap: () {
                context.push('/chat-screen');
              },
              colorscheme: colorscheme,
              texttheme: texttheme,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required ColorScheme colorscheme,
    required TextTheme texttheme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          // ignore: deprecated_member_use
          color: colorscheme.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ignore: deprecated_member_use
            color: colorscheme.onPrimaryFixedVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: colorscheme.secondaryFixed),
            SizedBox(width: 6),
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorscheme.secondaryFixed,
                fontWeight: FontWeight.w400,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleOrderSupportSelection(BuildContext context, String issue) {
    // Show a dialog or navigate to a detailed support form
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(
          "Help with: $issue",
          style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
        ),
        content: Text(
          "How would you like to get help with this issue?",
          style: GoogleFonts.dmSans(),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _launchWhatsApp(
                context,
                phoneNumber: '9657546519',
                message: 'I need help with: $issue',
              );
            },
            child: Text("Chat with Support"),
          ),
          CupertinoDialogAction(
            onPressed: () {
              Navigator.pop(context);
              _makePhoneCall('3746237467');
            },
            child: Text("Call Support"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Widget containerwidget(String text) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colorclass.containerfantgreencolor,
          border: Border.all(color: Colorclass.secondaryshadowcolor, width: 2),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Colorclass.blackcolor,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
        ),
      ),
    );
  }
}
