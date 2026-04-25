import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/entries_controller.dart';
import '../controllers/home_controller.dart';
import '../controllers/sync_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/app_drawer.dart';
import '../widgets/balance_header.dart';
import '../widgets/sync_status_bar.dart';
import 'add_entry_view.dart';
import 'entries_view.dart';
import 'customers_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final entriesController = Get.find<EntriesController>();
    final syncController = Get.find<SyncController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitConfirmDialog(context);
        if (shouldExit) {
          SystemNavigator.pop();
        }
        return false;
      },
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Obx(() => Scaffold(
          backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
          drawer: AppDrawer(
            currentIndex: homeController.currentTabIndex.value,
            onItemSelected: homeController.changeTab,
          ),
          body: Builder(
            builder: (ctx) {
              return Column(
                children: [
                  //_buildAppBar(context, homeController, authController, entriesController),
                  // تأكد من استدعاء الكنترولرز هنا
              
              Obx(() {
              final user = authController.user.value;
              final isSyncingData = syncController.isSyncing.value;
              
                return CustomAppBar(
  // القائمة
  onDrawerPressed: () => Scaffold.of(ctx).openDrawer(),
  drawerIcon: Icons.menu_rounded,
  drawerTooltip: 'افتح القائمة',

  // المستخدم
  profileWidget: user?.photoUrl.isNotEmpty == true
      ? Image.network(user!.photoUrl, fit: BoxFit.cover)
      : Container(
          color: Colors.white.withOpacity(0.15),
          alignment: Alignment.center,
          child: Text(
            user?.displayName.isNotEmpty == true
                ? user!.displayName[0].toUpperCase()
                : '?',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
  welcomeText: 'مرحباً، ${user?.displayName ?? 'المستخدم'}',
  emailText: user?.email,

  // الإجراء (تم تغيير المسميات هنا لتعمل مع التعديل الجديد)
  actionIcon: Icons.cloud_sync_rounded,
  actionTooltip: 'مزامنة البيانات',
  isActionLoading: isSyncingData, // بدلاً من isSyncing
  onActionPressed: () {          // بدلاً من onSyncPressed
    final userId = user?.uid;
    if (userId != null) {
      authController.refreshToken().then((_) {
        syncController.syncNow(userId);
      });
    }
  },

  // الرصيد
  balanceHeader: BalanceHeader(
    totalCredit: entriesController.totalCredit,
    totalDebit: entriesController.totalDebit,
    
  ),
);
              }),
                  const SyncStatusBar(),
                  Expanded(
                    child: _buildTabContent(homeController.currentTabIndex.value),
                  ),
                ],
              );
            }
          ),
          bottomNavigationBar: _buildBottomNav(context, homeController),
          floatingActionButton: _buildFAB(homeController),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        )),
      ),
    );
  }

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
      case 1:
        return  EntriesView();
      case 3:
        return  CustomersView();
      default:
        return  EntriesView();
    }
  }

 

  Widget _buildBottomNav(BuildContext context, HomeController homeController) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // فقط القيود والعملاء
    final tabs = [
      {'icon': Icons.receipt_long_rounded, 'label': 'القيود', 'index': 1},
      {'icon': Icons.people_rounded, 'label': 'العملاء', 'index': 3},
    ];

    return Obx(() {
      return Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : AppColors.primaryDark,
            boxShadow: [
              BoxShadow(
                color: (isDark ? Colors.black : AppColors.primaryDark).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // القيود (يسار)
                Expanded(
                  child: _buildNavItem(
                    tabs[0]['icon'] as IconData,
                    tabs[0]['label'] as String,
                    homeController.currentTabIndex.value == 1 ||
                        homeController.currentTabIndex.value == 0,
                    () => homeController.changeTab(1),
                  ),
                ),
                // مساحة FAB
                const SizedBox(width: 70),
                // العملاء (يمين)
                Expanded(
                  child: _buildNavItem(
                    tabs[1]['icon'] as IconData,
                    tabs[1]['label'] as String,
                    homeController.currentTabIndex.value == 3,
                    () => homeController.changeTab(3),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryLight : AppColors.bottomNavInactive,
              size: 22,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primaryLight : AppColors.bottomNavInactive,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(HomeController homeController) {
    return Container(
      width: 58,
      height: 58,
      margin: const EdgeInsets.only(bottom: 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryLight, Color(0xFF16A34A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryLight.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => Get.to(() =>  AddEntryView()),
          child: const Center(
            child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? AppColors.darkCard : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryDark.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.exit_to_app_rounded, color: AppColors.primaryDark, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'الخروج من التطبيق',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'هل تريد الخروج من التطبيق؟',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : null,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.mediumGray)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج', style: TextStyle()),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
