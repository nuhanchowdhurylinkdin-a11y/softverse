import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/common/widgets/primary_button.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/add_table_controller.dart';

class AddTableScreen extends GetView<AddTableController> {
  const AddTableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 58.h,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.posHeaderStart, AppColors.posHeaderEnd],
            ),
          ),
        ),
        title: Text(
          'Tables',
          style: getTextStyle(
            fontSize: 21.9,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Field(
                controller: controller.nameController,
                label: 'Table name',
                hint: 'Table-1',
                icon: Icons.table_restaurant,
              ),
              SizedBox(height: 14.h),
              _Field(
                controller: controller.capacityController,
                label: 'Seats',
                hint: '4',
                icon: Icons.people_alt_outlined,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),
              SizedBox(height: 28.h),
              Obx(
                () => PrimaryButton(
                  label: 'Add Table',
                  onPressed: controller.createTable,
                  isLoading: controller.isSubmitting.value,
                  gradient: const LinearGradient(
                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  ),
                  textColor: Colors.white,
                  height: 56,
                  borderRadius: 12,
                  fontSize: 16.4,
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'All Tables',
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w600,
                  color: AppColors.authTextDark,
                ),
              ),
              SizedBox(height: 12.h),
              Obx(() {
                if (controller.isLoadingTables.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.tables.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.chipBackground,
                      border: Border.all(color: AppColors.cardBorder),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'No table found',
                      style: getTextStyle(
                        fontSize: 14.6,
                        color: AppColors.chipInactiveText,
                      ),
                    ),
                  );
                }
                return Column(
                  children: controller.tables.map((table) {
                    final deleting = controller.deletingTableIds.contains(
                      table.tableId,
                    );
                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: Container(
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: AppColors.chipBackground,
                          border: Border.all(color: AppColors.cardBorder),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.table_restaurant,
                              color: AppColors.onboardingBackground,
                              size: 22.sp,
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    table.tableName,
                                    style: getTextStyle(
                                      fontSize: 15.2,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.authTextDark,
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Text(
                                    table.capacity == null
                                        ? table.availability
                                        : '${table.capacity} seats • ${table.availability}',
                                    style: getTextStyle(
                                      fontSize: 12.8,
                                      color: AppColors.chipInactiveText,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: deleting
                                  ? null
                                  : () => controller.deleteTable(table),
                              icon: deleting
                                  ? SizedBox(
                                      width: 18.w,
                                      height: 18.w,
                                      child: const CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.delete_outline,
                                      color: AppColors.dangerRed,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(
            fontSize: 14.6,
            fontWeight: FontWeight.w500,
            color: AppColors.onboardingBackground,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppColors.chipInactiveText),
            filled: true,
            fillColor: AppColors.chipBackground,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(
                color: AppColors.onboardingBackground,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
