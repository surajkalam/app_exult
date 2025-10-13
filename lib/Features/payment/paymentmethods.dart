import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFFC67C4E);
  static const Color primaryDark = Color(0xFF372213);
  static const Color primaryLight = Color(0xFFFFF5EE);
  static const Color accent = Color(0xFF36C07E);
  static const Color background = Color(0xFFF9F9F9);
  static const Color textPrimary = Color(0xFF2F2D2C);
  static const Color textSecondary = Color(0xFF9B9B9B);
  static const Color lightBorder = Color(0xFFEAEAEA);
}

class PaymentMethodScreen extends StatefulWidget {
  const PaymentMethodScreen({super.key});

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  String selectedMethod = 'upi';
  final Map<String, bool> expandedSections = {
    'upi': false,
    'cards': false,
    'emi': false,
    'netbanking': false,
    'wallets': false,
  };

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Payment Method',
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select payment method',
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: height * 0.02),
            _buildPaymentOption(
              context: context,
              title: 'UPI',
              subtitle: 'Pay using UPI apps',
              iconPath:
                  'Assets/Icons/bhimupi.jpg', // Replace with your UPI icon
              methodKey: 'upi',
              width: width,
              height: height,
            ),
            SizedBox(height: height * 0.015),
            _buildPaymentOption(
              context: context,
              title: 'Credit/Debit Cards',
              subtitle: 'Pay using cards',
              iconPath: 'Assets/Icons/cards.jpg', // Replace with your card icon
              methodKey: 'cards',
              width: width,
              height: height,
            ),
            SizedBox(height: height * 0.015),
            _buildPaymentOption(
              context: context,
              title: 'Net Banking',
              subtitle: 'Bank transfer',
              iconPath:
                  'Assets/Icons/bank.jpg', // Replace with your netbanking icon
              methodKey: 'netbanking',
              width: width,
              height: height,
            ),
            SizedBox(height: height * 0.015),
            _buildPaymentOption(
              context: context,
              title: 'Wallets',
              subtitle: 'Pay using wallets',
              iconPath:
                  'Assets/Icons/wallet.jpg', // Replace with your wallet icon
              methodKey: 'wallets',
              width: width,
              height: height,
            ),
            SizedBox(height: height * 0.03),
            _buildContinueButton(context, width, height),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String iconPath,
    required String methodKey,
    required double width,
    required double height,
  }) {
    final isSelected = selectedMethod == methodKey;
    final isExpanded = expandedSections[methodKey] ?? false;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            // ignore: deprecated_member_use
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: width * 0.04,
              vertical: height * 0.01,
            ),
            leading: Container(
              width: width * 0.12,
              height: width * 0.12,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryLight
                    : AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  iconPath,
                  // width: width * 0.07,
                  // height: width * 0.07,
                  fit: BoxFit.cover,
                  // color: isSelected ? AppColors.primary : AppColors.textSecondary,
                ),
              ),
            ),
            title: Text(
              title,
              style: GoogleFonts.dmSans(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              subtitle,
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
            trailing: Radio<String>(
              value: methodKey,
              groupValue: selectedMethod,
              activeColor: AppColors.primary,
              onChanged: (value) {
                setState(() {
                  selectedMethod = value!;
                  expandedSections[methodKey] = !isExpanded;
                });
              },
            ),
            onTap: () {
              setState(() {
                selectedMethod = methodKey;
                expandedSections[methodKey] = !isExpanded;
              });
            },
          ),
          if (isSelected && isExpanded)
            _buildExpandedContent(methodKey, width, height),
        ],
      ),
    );
  }

  Widget _buildExpandedContent(String methodKey, double width, double height) {
    switch (methodKey) {
      case 'upi':
        return _buildUpiContent(width, height);
      case 'cards':
        return _buildCardsContent(width, height);
      case 'netbanking':
        return _buildNetbankingContent(width, height);
      case 'wallets':
        return _buildWalletsContent(width, height);
      default:
        return const SizedBox();
    }
  }

  Widget _buildUpiContent(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.01,
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Enter UPI ID',
              hintStyle: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
          Text(
            'Popular UPI Apps',
            style: GoogleFonts.dmSans(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: height * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildUpiAppIcon('Assets/Icons/googlepay.jpg', 'GPay', width),
              _buildUpiAppIcon('Assets/Icons/phonepay.jpg', 'PhonePe', width),
              _buildUpiAppIcon(
                'Assets/Icons/Paytm png images.jpg',
                'Paytm',
                width,
              ),
              _buildUpiAppIcon(
                'Assets/Icons/BHIM UPI Icon PNG and SVG Vector Free Download.jpg',
                'BHIM',
                width,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpiAppIcon(String iconPath, String label, double width) {
    return Column(
      children: [
        Container(
          width: width * 0.12,
          height: width * 0.12,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.lightBorder),
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                iconPath,
                width: width * 0.08,
                height: width * 0.08,
              ),
            ),
          ),
        ),
        SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildCardsContent(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.01,
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Card Number',
              hintStyle: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
            ),
          ),
          SizedBox(height: height * 0.015),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'MM/YY',
                    hintStyle: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.015,
                    ),
                  ),
                ),
              ),
              SizedBox(width: width * 0.03),
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: 'CVV',
                    hintStyle: GoogleFonts.dmSans(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: width * 0.04,
                      vertical: height * 0.015,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: height * 0.015),
          TextFormField(
            decoration: InputDecoration(
              hintText: 'Cardholder Name',
              hintStyle: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetbankingContent(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.01,
      ),
      child: Column(
        children: [
          TextFormField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              hintText: 'Search for your bank',
              hintStyle: GoogleFonts.dmSans(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: width * 0.04,
                vertical: height * 0.015,
              ),
            ),
          ),
          SizedBox(height: height * 0.02),
          _buildBankOption(
            'State Bank of India',
            'Assets/Icons/SBI logo.jpg',
            width,
          ),
          SizedBox(height: height * 0.015),
          _buildBankOption(
            'HDFC Bank',
            'Assets/Icons/HDFC BANK LOGO.jpg',
            width,
          ),
          SizedBox(height: height * 0.015),
          _buildBankOption('ICICI Bank', 'Assets/Icons/icici bank.jpg', width),
          SizedBox(height: height * 0.015),
          _buildBankOption('Axis Bank', 'Assets/Icons/Axisbank.jpg', width),
        ],
      ),
    );
  }

  Widget _buildBankOption(String bankName, String iconPath, double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: width * 0.08, height: width * 0.08),
          SizedBox(width: width * 0.03),
          Text(
            bankName,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletsContent(double width, double height) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: width * 0.04,
        vertical: height * 0.01,
      ),
      child: Column(
        children: [
          _buildWalletOption(
            'Paytm Wallet',
            'Assets/Icons/paytmwallets.jpg',
            width,
          ),
          SizedBox(height: height * 0.015),
          _buildWalletOption('Amazon Pay', 'Assets/Icons/amzon.jpg', width),
          SizedBox(height: height * 0.015),
          _buildWalletOption('MobiKwik', 'Assets/Icons/amzon.jpg', width),
          SizedBox(height: height * 0.015),
          _buildWalletOption(
            'PhonePe Wallet',
            'Assets/Icons/phonepay.jpg',
            width,
          ),
        ],
      ),
    );
  }

  Widget _buildWalletOption(String walletName, String iconPath, double width) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: width * 0.04, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Image.asset(iconPath, width: width * 0.08, height: width * 0.08),
          SizedBox(width: width * 0.03),
          Text(
            walletName,
            style: GoogleFonts.dmSans(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton(
    BuildContext context,
    double width,
    double height,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          // Handle payment continuation
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: EdgeInsets.symmetric(vertical: height * 0.02),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Text(
          'Continue',
          style: GoogleFonts.dmSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
