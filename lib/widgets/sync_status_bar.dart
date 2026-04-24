import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/sync_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/sync_service.dart';
import '../theme/app_theme.dart';

class SyncStatusBar extends GetView<SyncController> {
  const SyncStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final state = controller.syncState.value;
      final message = controller.syncMessage.value;
      final pending = controller.pendingChanges.value;

      if (state == SyncState.synced && message.isEmpty) {
        return const SizedBox.shrink();
      }

      Color bgColor;
      IconData icon;
      bool showSyncButton = false;

      switch (state) {
        case SyncState.synced:
          bgColor = AppColors.success;
          icon = Icons.cloud_done_rounded;
          break;
        case SyncState.syncing:
          bgColor = AppColors.primaryMedium;
          icon = Icons.sync_rounded;
          break;
        case SyncState.pending:
          bgColor = const Color(0xFFD97706);
          icon = Icons.cloud_upload_rounded;
          showSyncButton = !controller.isSyncing.value;
          break;
        case SyncState.error:
          bgColor = AppColors.error;
          icon = Icons.cloud_off_rounded;
          showSyncButton = !controller.isSyncing.value;
          break;
        case SyncState.offline:
          bgColor = AppColors.mediumGray;
          icon = Icons.wifi_off_rounded;
          break;
      }

      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: bgColor),
        child: Row(
          children: [
            if (state == SyncState.syncing)
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            else
              Icon(icon, color: Colors.white, size: 15),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message.isNotEmpty ? message : _defaultMessage(state, pending),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'myfont',
                ),
              ),
            ),
            if (showSyncButton)
              GestureDetector(
                onTap: () {
                  final userId = Get.find<AuthController>().user.value?.uid;
                  if (userId != null) {
                    final authController = Get.find<AuthController>();
                    authController.refreshToken().then((_) {
                      controller.syncNow(userId);
                    });
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'مزامنة الآن',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'myfont',
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  String _defaultMessage(SyncState state, int pending) {
    switch (state) {
      case SyncState.synced:
        return 'تمت المزامنة بنجاح';
      case SyncState.syncing:
        return 'جاري المزامنة...';
      case SyncState.pending:
        return pending > 0
            ? '$pending قيد غير مزامن - اتصل بالإنترنت للمزامنة'
            : 'في انتظار المزامنة';
      case SyncState.error:
        return 'فشلت المزامنة - اضغط للمحاولة مجدداً';
      case SyncState.offline:
        return 'غير متصل - البيانات محفوظة محلياً${pending > 0 ? " ($pending قيد غير مزامن)" : ""}';
    }
  }
}
