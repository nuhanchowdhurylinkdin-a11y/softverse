import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../controller/shift_controller.dart';
import '../../widgets/shift_header.dart';
import '../../widgets/shift_info_card.dart';

class ShiftListScreen extends GetView<ShiftController> {
  const ShiftListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const ShiftHeader(title: 'Shifts'),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: controller.shiftHistory
                      .map(
                        (shift) => Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: GestureDetector(
                            onTap: () => controller.openShiftReport(shift),
                            child: ShiftInfoCard(shift: shift),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
