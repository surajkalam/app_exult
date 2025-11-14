
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';

import '../../../core/core.dart';

class CoffeeReferFriendScreen extends StatelessWidget {
  const CoffeeReferFriendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        titleText: 'Refer a Coffee Lover',
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.brown[50]!,
              Colors.brown[100]!,
            ],
          ),
        ),
        child: SafeArea( // Added SafeArea for better layout
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0), // Reduced padding
            child: ConstrainedBox( // Added ConstrainedBox to ensure proper constraints
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                          MediaQuery.of(context).padding.top -
                          kToolbarHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Important for scrollable columns
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Coffee Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.brown[100],
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.brown[300]!, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                    clipBehavior: Clip.antiAlias,
                      child: Image.asset(
                        'assets/Images/coffee-powder.png',
                        // height: 80,
                        // width: 80,
                        fit: BoxFit.cover,
                    ),
                  ),
                  ),
                  SizedBox(height: 16),
                  // Title
                  Text(
                    'Share the Coffee Love',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[800],
                    ),
                  ),
                  
                  SizedBox(height: 8),
                  
                  // Description
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'Invite your friends to discover our amazing coffee experience! Share the joy of premium coffee, cozy ambiance, and special rewards.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown[700],
                        height: 1.5,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24),
                  
                  // Coffee Benefits Section
                  _buildCoffeeBenefitsSection(),
                  
                  SizedBox(height: 24),
                  
                  // Website Link Box
                  _buildWebsiteLinkBox(),
                  
                  SizedBox(height: 24),
                  
                  // Share Buttons
                  _buildShareButtons(context),
                  
                  SizedBox(height: 20),
                  
                  // Footer Note
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Thanks for spreading the coffee love! ☕',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.brown[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16), // Extra bottom padding for safety
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCoffeeBenefitsSection() {
    return Container(
      width: double.infinity, // Ensure full width
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.brown[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.brown[100]!,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.gift, color: Colors.brown[600], size: 18),
              SizedBox(width: 6),
              Text(
                'Referral Rewards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          _buildBenefitItem('☕ Free Coffee on Their First Visit'),
          _buildBenefitItem('🎁 Special Discount for Both'),
          _buildBenefitItem('⭐ Priority Access to New Blends'),
          _buildBenefitItem('🏆 Exclusive Member Perks'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.local_cafe, size: 14, color: Colors.brown[600]),
          SizedBox(width: 6),
          Expanded( // Use Expanded to prevent overflow
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebsiteLinkBox() {
    const String websiteLink = 'https://exultcoffeehouse.com/';
    
    return Container(
      width: double.infinity, // Ensure full width
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.brown[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.brown[100]!,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Iconsax.link, color: Colors.brown[600], size: 18),
              SizedBox(width: 6),
              Text(
                'Our Coffee Shop Website',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            width: double.infinity, // Ensure full width
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.brown[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: SelectableText(
              websiteLink,
              style: TextStyle(
                fontSize: 12,
                color: Colors.brown[700],
                fontWeight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Share this link with your coffee-loving friends!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: Colors.brown[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShareButtons(BuildContext context) {
    return Column(
      children: [
        // WhatsApp Button
        Container(
          width: double.infinity, // Ensure full width
          child: ElevatedButton.icon(
            onPressed: () => _shareViaWhatsApp(),
            icon: Icon(Iconsax.message, color: Colors.white, size: 18),
            label: Text(
              'Share via WhatsApp',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
          ),
        ),
        
        SizedBox(height: 10),
        
        // Other Apps Button
        Container(
          width: double.infinity, // Ensure full width
          child: OutlinedButton.icon(
            onPressed: () => _shareViaOtherApps(),
            icon: Icon(Iconsax.share, color: Colors.brown[700], size: 18),
            label: Text(
              'Share via Other Apps',
              style: TextStyle(color: Colors.brown[700], fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.brown[400]!),
            ),
          ),
        ),
        
        SizedBox(height: 10),
        
        // Copy Link Button
        Container(
          width: double.infinity, // Ensure full width
          child: OutlinedButton.icon(
            onPressed: () => _copyLinkToClipboard(context),
            icon: Icon(Iconsax.copy, color: Colors.brown[600], size: 18),
            label: Text(
              'Copy Link',
              style: TextStyle(color: Colors.brown[600], fontSize: 14),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.brown[300]!),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _shareViaWhatsApp() async {
    const String websiteLink = 'https://exultcoffeehouse.com/';
    final String message = '''
☕ Discover Your New Favorite Coffee Spot! ☕

I found this amazing coffee shop and thought you'd love it too!

🌟 What makes it special:
• Premium artisan coffee blends
• Cozy and welcoming atmosphere
• Delicious pastries & snacks
• Friendly baristas
• Perfect work/study spot

🎁 Special offer for you:
Mention my referral for a welcome discount!

📍 Visit: $websiteLink

Perfect for coffee lovers like us! Let me know what you think! ☕✨''';

    final String url = "https://wa.me/?text=${Uri.encodeFull(message)}";
    
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        // ignore: deprecated_member_use
        await Share.share(message);
      }
    } catch (e) {
      // ignore: deprecated_member_use
      await Share.share(message);
    }
  }

  Future<void> _shareViaOtherApps() async {
    const String websiteLink = 'https://exultcoffeehouse.com/';
    final String message = '''
☕ Amazing Coffee Experience Awaits! 

Check out this wonderful coffee shop I discovered. Perfect coffee, great vibes!

🔗 $websiteLink

Perfect for our next coffee catchup! ☕''';

    try {
      await Share.share(message);
    } catch (e) {
      print('Error sharing: $e');
    }
  }

  Future<void> _copyLinkToClipboard(BuildContext context) async {
    const String websiteLink = 'https://exultcoffeehouse.com/';
    
    try {
      await Clipboard.setData(ClipboardData(text: websiteLink));
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('Coffee shop link copied! ☕', style: TextStyle(fontSize: 13)),
            ],
          ),
          backgroundColor: Colors.green[600],
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy link', style: TextStyle(fontSize: 13)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}