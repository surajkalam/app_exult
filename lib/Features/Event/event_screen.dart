import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';

class EventScreen extends ConsumerWidget {
  const EventScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: colorScheme.onPrimary,
      appBar: _buildAppBar(context, colorScheme, textTheme),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderSection(height, width, colorScheme, textTheme),
            SizedBox(height: 24),
            _buildFeaturesGrid(height, width, colorScheme, textTheme),
            SizedBox(height: 24),
            _buildSectionTitle("Our Event Services", colorScheme, textTheme),
            SizedBox(height: 16),
            _buildEventCard(
              height,
              width,
              "Assets/Images/bdaycelebrate.png",
              "Private Celebration",
              "Birthdays, anniversaries, bridal showers, baby showers — we make your moments unforgettable with delicious food, aromatic brews, and warm hospitality.",
              "🎉",
              colorScheme,
              textTheme,
            ),
            SizedBox(height: 16),
            _buildEventCard(
              height,
              width,
              "Assets/Images/musicday.png",
              "Live Music and Open Mic Night",
              "Barista classes, coffee brewing workshops, art jam sessions, book clubs, or photography meetups — our café is where creativity meets community.",
              "🎶",
              colorScheme,
              textTheme,
            ),
            SizedBox(height: 16),
            _buildEventCard(
              height,
              width,
              "Assets/Images/workshop&comm.png",
              "Workshop & Community Meetup",
              "Hold team meetings, networking events, or product launches in a relaxed yet professional setting with custom catering options.",
              "👔",
              colorScheme,
              textTheme,
            ),
            SizedBox(height: 16),
            _buildEventCard(
              height,
              width,
              "Assets/Images/workshop&comm.png",
              "Corporate & Team Events",
              "Perfect setting for corporate gatherings, team building activities, and business meetings with premium coffee and catering services.",
              "💼",
              colorScheme,
              textTheme,
            ),
            SizedBox(height: 32),
            _buildBookEventButton(
              context,
              height,
              width,
              colorScheme,
              textTheme,
            ),
            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Build iOS-style app bar
  // ignore: strict_top_level_inference
  PreferredSizeWidget _buildAppBar(context, colorscheme, texttheme) {
    return AppBar(
      backgroundColor: colorscheme.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Events',
        style: texttheme.titleLarge?.copyWith(color: colorscheme.primary),
      ),
    );
  }

  // Build header section
  Widget _buildHeaderSection(
    double height,
    double width,
    ColorScheme colorscheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorscheme.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: width * 0.2,
            height: height * 0.08,
            decoration: BoxDecoration(
              color: colorscheme.onPrimaryFixedVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Iconsax.people, size: 32, color: colorscheme.onPrimary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Brew, Gather, Celebrate...",
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorscheme.primary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Create unforgettable moments with us",
                  style: textTheme.labelSmall?.copyWith(
                    color: colorscheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build features grid
  Widget _buildFeaturesGrid(
    double height,
    double width,
    colorscheme,
    texttheme,
  ) {
    final features = [
      {"title": "Custom Menus", "icon": Iconsax.menu_board},
      {"title": "Cozy Ambience", "icon": Iconsax.home_hashtag},
      {"title": "Flexible Spaces", "icon": Iconsax.buildings},
      {"title": "Event Support", "icon": Iconsax.support},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.5,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return _buildFeatureCard(
          features[index]['title'] as String,
          features[index]['icon'] as IconData,
          colorscheme,
          texttheme,
        );
      },
    );
  }

  // Build feature card
  Widget _buildFeatureCard(
    String title,
    IconData icon,
    colorscheme,
    texttheme,
  ) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorscheme.onPrimary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: colorscheme.secondaryFixed),
          SizedBox(height: 8),
          Text(
            title,
            style: texttheme.labelSmall?.copyWith(
              color: colorscheme.primaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Build section title
  Widget _buildSectionTitle(String title, colorscheme, texttheme) {
    return Text(
      title,
      style: texttheme.bodyMedium?.copyWith(
        color: colorscheme.primaryContainer,
      ),
    );
  }

  // Build event card
  Widget _buildEventCard(
    double height,
    double width,
    String imagePath,
    String title,
    String description,
    String emoji,
    ColorScheme colorscheme,
    TextTheme texttheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorscheme.onSecondaryFixed,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: colorscheme.shadow,
            offset: Offset(4, 4),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        children: [
          // Image section
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Container(
              height: height * 0.2,
              width: double.infinity,
              color: colorscheme.onSecondaryFixed,
              child: Image.asset(
                imagePath,
                fit: BoxFit.fill,
                errorBuilder: (_, _, _) =>
                    _buildEventImagePlaceholder(emoji, colorscheme, texttheme),
              ),
            ),
          ),
          // Content section
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorscheme.onPrimary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(emoji, style: TextStyle(fontSize: 16)),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        title,
                        style: texttheme.bodyMedium?.copyWith(
                          color: colorscheme.primary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  description,
                  style: texttheme.bodySmall?.copyWith(
                    color: colorscheme.secondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build event image placeholder
  Widget _buildEventImagePlaceholder(
    String emoji,
    ColorScheme colorscheme,
    texttheme,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: 40)),
          SizedBox(height: 8),
          Text(
            "Event Image",
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: colorscheme.secondary,
            ),
          ),
        ],
      ),
    );
  }

  // Build book event button
  Widget _buildBookEventButton(
    BuildContext context,
    double height,
    double width,
    colorscheme,
    texttheme,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          context.push('/eventform');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: colorscheme.secondaryFixed,
          foregroundColor: colorscheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          // ignore: deprecated_member_use
          shadowColor: colorscheme.secondaryFixed.withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.calendar_add, size: 24),
            SizedBox(width: 12),
            Text(
              "Book Your Event",
               style: texttheme.bodyMedium?.copyWith(
              color: colorscheme.onSecondaryFixed,
            ),
            ),
          ],
        ),
      ),
    );
  }
}

// Define a color palette for the app
