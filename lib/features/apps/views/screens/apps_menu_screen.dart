import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../core/common/styles/global_text_style.dart';
import '../../../../core/services/feature_settings.dart';
import '../../../../core/services/main_station_server.dart';
import '../../../../core/utils/constants/colors.dart';
import '../../../../routes/app_routes.dart';
import '../../models/app_device_model.dart';

class AppsMenuScreen extends StatelessWidget {
  const AppsMenuScreen({super.key});

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
          'Apps',
          style: getTextStyle(
            fontSize: 16.4,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder<String>(
                future: MainStationServer.instance.localUrl(),
                builder: (context, snapshot) => Container(
                  padding: EdgeInsets.all(14.w),
                  margin: EdgeInsets.only(bottom: 12.h),
                  decoration: BoxDecoration(
                    color: AppColors.chipBackground,
                    border: Border.all(color: AppColors.cardBorder),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Main station IP',
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingBackground,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        snapshot.data ?? 'Starting...',
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onboardingBackground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Obx(
                () => FeatureSettings.isEnabled('customer_displays')
                    ? Column(
                        children: [
                          _AppTile(
                            type: AppDeviceType.cds,
                            onTap: () => Get.toNamed(
                              AppRoute.getAppDeviceListScreen(),
                              arguments: AppDeviceType.cds,
                            ),
                          ),
                          SizedBox(height: 12.h),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),
              Obx(
                () => FeatureSettings.isEnabled('kitchen_printers')
                    ? _AppTile(
                        type: AppDeviceType.kds,
                        onTap: () => Get.toNamed(
                          AppRoute.getAppDeviceListScreen(),
                          arguments: AppDeviceType.kds,
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  final AppDeviceType type;
  final VoidCallback onTap;

  const _AppTile({required this.type, required this.onTap});

  List<String> _connectedIps() => type == AppDeviceType.cds
      ? MainStationServer.instance.connectedCdsIps
      : MainStationServer.instance.connectedKdsIps;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppColors.rowGradientEnd],
          ),
          border: Border.all(color: AppColors.cardBorder),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              Iconsax.monitor,
              size: 26.sp,
              color: AppColors.onboardingBackground,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.label,
                    style: getTextStyle(
                      fontSize: 14.6,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onboardingBackground,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  // ponytail: 2s poll of an in-process singleton; switch to a
                  // stream on MainStationServer if this ever needs to be instant.
                  StreamBuilder<List<String>>(
                    stream: Stream.periodic(
                      const Duration(seconds: 2),
                      (_) => _connectedIps(),
                    ),
                    initialData: _connectedIps(),
                    builder: (context, snapshot) {
                      final ips = snapshot.data ?? const <String>[];
                      final connected = ips.isNotEmpty;
                      return Row(
                        children: [
                          Container(
                            width: 8.w,
                            height: 8.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: connected
                                  ? AppColors.success
                                  : AppColors.chipInactiveText,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              connected
                                  ? '${ips.length} connected — ${ips.join(', ')}'
                                  : 'Not connected',
                              overflow: TextOverflow.ellipsis,
                              style: getTextStyle(
                                fontSize: 12,
                                color: connected
                                    ? AppColors.success
                                    : AppColors.chipInactiveText,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
