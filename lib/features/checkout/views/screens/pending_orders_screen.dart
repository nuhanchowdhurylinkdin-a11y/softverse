import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:intl/intl.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../controller/checkout_controller.dart';

class PendingOrdersScreen extends GetView<CheckoutController> {
  const PendingOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: false,
        toolbarHeight: 55.h,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 22.sp),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
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
          'Pending Order',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: RefreshIndicator(
          onRefresh: controller.fetchPendingOrders,
          child: Obx(() {
            final orders = controller.pendingOrders;
            if (orders.isEmpty && !controller.isLoadingPendingOrders.value) {
              return ListView(
                padding: EdgeInsets.all(16.w),
                children: [
                  SizedBox(height: 160.h),
                  Icon(
                    Iconsax.clock,
                    size: 58.sp,
                    color: AppColors.chipInactiveText,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No pending order found.',
                    textAlign: TextAlign.center,
                    style: getTextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount:
                  orders.length +
                  (controller.isLoadingPendingOrders.value ? 1 : 0),
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                if (controller.isLoadingPendingOrders.value && index == 0) {
                  return const LinearProgressIndicator(minHeight: 2);
                }
                final order =
                    orders[index -
                        (controller.isLoadingPendingOrders.value ? 1 : 0)];
                return _PendingOrderTile(order: order);
              },
            );
          }),
        ),
      ),
    );
  }
}

class _PendingOrderTile extends GetView<CheckoutController> {
  final Map<String, dynamic> order;

  const _PendingOrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    final customerName = _text(
      order['customerName'],
      fallback: 'Not Registered',
    );
    final orderNumber = _text(order['orderNumber'], fallback: 'Pending Order');

    return Material(
      color: AppColors.chipBackground,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: () => _modify(context),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                customerName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                orderNumber,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: getTextStyle(
                  fontSize: 16.4,
                  fontWeight: FontWeight.w500,
                  color: AppColors.onboardingBackground,
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                _date(order['createdAt']),
                style: getTextStyle(
                  fontSize: 12,
                  color: AppColors.chipInactiveText,
                ),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _ActionIcon(
                    icon: Iconsax.edit,
                    tooltip: 'Modify',
                    onTap: () => _modify(context),
                  ),
                  SizedBox(width: 6.w),
                  _ActionIcon(
                    icon: Iconsax.printer,
                    tooltip: 'Print',
                    onTap: () {
                      final id = order['id']?.toString();
                      if (id != null && id.isNotEmpty) {
                        controller.printPendingOrder(id);
                      }
                    },
                  ),
                  SizedBox(width: 6.w),
                  _ActionIcon(
                    icon: Iconsax.trash,
                    tooltip: 'Delete',
                    color: AppColors.dangerRed,
                    onTap: () => _confirmDelete(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _modify(BuildContext context) async {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty) return;
    final opened = await controller.loadOrderForCheckout(id);
    if (opened) Get.back();
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final id = order['id']?.toString();
    if (id == null || id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete order?'),
        content: const Text(
          'This pending order will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Delete', style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deletePendingOrder(id);
    }
  }

  String _text(dynamic value, {required String fallback}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  String _date(dynamic value) {
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed == null) return '';
    return DateFormat('dd/MM/yyyy hh:mma').format(parsed.toLocal());
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final Color? color;

  const _ActionIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        onPressed: onTap,
        tooltip: tooltip,
        icon: Icon(icon, size: 18.sp, color: color ?? AppColors.onboardingBackground),
        constraints: BoxConstraints.tight(Size(34.w, 34.w)),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
