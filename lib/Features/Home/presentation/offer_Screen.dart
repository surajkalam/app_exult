import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/utils/utils.dart';
import '../../../core/widget/widgets.dart';
import '../../Menu/Provider/Provider.dart';

class OfferScreen extends ConsumerWidget {
  const OfferScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    log("welcome to offerscreen");

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar(titleText: "Offer", centerTitle: true),
      body: Padding(
        padding: EdgeInsets.all(height * 0.01),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: height * 0.02),
              child: Text(
                "Special Offers",
                style: GoogleFonts.dmSans(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: height * 0.34,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: offerlist.length,
                itemBuilder: (context, index) {
                  final offer = offerlist[index];
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: height * 0.01,
                          ),
                          child: Container(
                            width: width * 0.45,
                            margin: EdgeInsets.only(right: width * 0.03),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.03),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.grey.withValues(alpha: 0.3),
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(width * 0.03),
                                    topRight: Radius.circular(width * 0.03),
                                  ),
                                  child: Image.asset(
                                    offer['image'] ??
                                        'assets/Images/default.png',
                                    height: height * 0.15,
                                    width: width * 0.6,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(width * 0.01),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        offer['name'],
                                        style: TextStyle(
                                          fontSize: width * 0.04,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.005),
                                      Text(
                                        offer['description'],
                                        style: TextStyle(
                                          fontSize: width * 0.035,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        "usecode : COFFEE20",
                                        style: TextStyle(
                                          fontSize: height * 0.016,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.green,
                                        ),
                                      ),
                                      SizedBox(height: height * 0.01),
                                      Padding(
                                        padding: EdgeInsets.only(
                                          left: width * 0.036,
                                        ),
                                        child: addtextcartbutton(
                                          height * 0.03,
                                          width * 0.35,
                                          'apply',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
