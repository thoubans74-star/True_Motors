import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class TermsCondition extends StatefulWidget {
  const TermsCondition({super.key});

  @override
  State<TermsCondition> createState() => _TermsConditionState();
}

class _TermsConditionState extends State<TermsCondition> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        backgroundColor: const Color(0xFFFBF8F8),
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back,
            size: 24.r,
            color: const Color(0xFF01422D),
          ),
        ),
        title: Text(
          "Terms & Conditions",
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 18.sp,
            color: const Color(0xFF01422D),
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Service Booking – Terms & Conditions",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w500
              ),
            ),

            SizedBox(height: 10.h),

            Text(
              "Thank you for booking your vehicle service with TrueMotors. Please read and acknowledge the following terms:",
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w400,
              ),
            ),

            SizedBox(height: 12.h),

            _buildTerm(
              "1. Booking Confirmation",
              [
                "Your booking is confirmed based on the details provided.",
                "Changes in booking (reschedule/cancellation) can be done up to 2 hours before your scheduled time.",
              ],
            ),

            _buildTerm(
              "2. Vehicle Pickup & Drop",
              [
                "Ensure your vehicle is ready at the pickup time and location if you have chosen home pickup & drop.",
                "Remove all valuables from the vehicle before handing it over to our service partner.",
              ],
            ),

            _buildTerm(
              "3. Service Scope",
              [
                "The final service charges may vary based on actual inspection and service requirements.",
                "Only genuine parts or manufacturer-approved alternatives will be used for replacements.",
              ],
            ),

            _buildTerm(
              "4. Payments",
              [
                "Full payment must be completed before the vehicle is released post-service.",
                "Any additional services or parts replacements will be informed and charged separately.",
              ],
            ),

            _buildTerm(
              "5. Liability",
              [
                "TrueMotors is not responsible for pre-existing damages or mechanical failures unrelated to the service performed.",
                "Warranty on parts and service is as per the manufacturer’s or service partner’s policy.",
              ],
            ),

            _buildTerm(
              "6. Cancellation Policy",
              [
                "Cancellations within 2 hours of scheduled time may attract cancellation charges as per our policy.",
              ],
            ),

            _buildTerm(
              "7. Disputes",
              [
                "For any concerns or disputes regarding your service, please contact our support team for resolution.",
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTerm(String title, List<String> points) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
            style: TextStyle(
              fontSize: 13.5.sp,
              fontWeight: FontWeight.w600
            ),
          ),
          SizedBox(height: 4.h),

          ...points.map(
                (point) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("  •   ", style: TextStyle(fontSize: 13.sp)),
                  Expanded(
                    child: Text(
                      point,
                      style: TextStyle(fontSize: 13.sp, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}