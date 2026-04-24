import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/sync_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/sync_status_bar.dart';
import '../add_entry/add_entry_view.dart';
import '../entries/entries_view.dart';
import '../customers/customers_view.dart';
import '../reports/reports_view.dart';
import '../import_export/import_export_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final authController = Get.find<AuthController>();
    final entriesController = Get.find<EntriesController>();

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
          backgroundColor: AppColors.background,
          // ===== DRAWER =====
          drawer: AppDrawer(
            currentIndex: homeController.currentTabIndex.value,
            onItemSelected: homeController.changeTab,
          ),
          body: Column(
            children: [
              // Custom AppBar
              _buildAppBar(context, homeController, authController, entriesController),
              // Sync status bar
              const SyncStatusBar(),
              // Tab content
              Expanded(
                child: _buildTabContent(homeController.currentTabIndex.value),
              ),
            ],
          ),
          // Bottom Navigation Bar
          bottomNavigationBar: _buildBottomNav(homeController),
          // FAB
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
        return const EntriesView();
      case 2:
        return const ReportsView();
      case 3:
        return const CustomersView();
      case 4:
        return const ImportExportView();
      default:
        return const EntriesView();
    }
  }

  Widget _buildAppBar(
    BuildContext context,
    HomeController homeController,
    AuthController authController,
    EntriesController entriesController,
  ) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [AppColors.primaryMedium, AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F3D2E),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Top row
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Row(
                children: [
                  // Drawer button (hamburger)
                  Builder(
                    builder: (ctx) => IconButton(
                      onPressed: () => Scaffold.of(ctx).openDrawer(),
                      icon: const Icon(
                        Icons.menu_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                      tooltip: 'القائمة',
                    ),
                  ),
                  // Logo
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        'assets/accounts_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // User info
                  Expanded(
                    child: Obx(() {
                      final user = authController.user.value;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرحباً، ${user?.displayName ?? 'المستخدم'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              fontFamily: 'myfont',
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user?.email != null)
                            Text(
                              user!.email,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.65),
                                fontSize: 11,
                                fontFamily: 'myfont',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      );
                    }),
                  ),
                  // Sync button
                  Obx(() {
                    final syncController = Get.find<SyncController>();
                    return IconButton(
                      onPressed: syncController.isSyncing.value
                          ? null
                          : () {
                              final userId = authController.user.value?.uid;
                              if (userId != null) {
                                authController.refreshToken().then((_) {
                                  syncController.syncNow(userId);
                                });
                              }
                            },
                      icon: syncController.isSyncing.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.cloud_sync_rounded, color: Colors.white, size: 22),
                      tooltip: 'مزامنة',
                    );
                  }),
                  // User avatar
                  Obx(() {
                    final user = authController.user.value;
                    return GestureDetector(
                      onTap: () => _showUserMenu(context, authController),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primaryLight.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white.withOpacity(0.15),
                          backgroundImage: user?.photoUrl.isNotEmpty == true
                              ? NetworkImage(user!.photoUrl)
                              : null,
                          child: user?.photoUrl.isEmpty != false
                              ? Text(
                                  user?.displayName.isNotEmpty == true
                                      ? user!.displayName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    fontFamily: 'myfont',
                                  ),
                                )
                              : null,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
            // Balance summary
            Obx(() => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildBalanceItem(
                        'لي (دائن)',
                        entriesController.totalCredit,
                        AppColors.primaryLight,
                        Icons.arrow_upward_rounded,
                      ),
                    ),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
                    Expanded(
                      child: _buildBalanceItem(
                        'علي (مدين)',
                        entriesController.totalDebit,
                        const Color(0xFFFF8A80),
                        Icons.arrow_downward_rounded,
                      ),
                    ),
                    Container(width: 1, height: 42, color: Colors.white.withOpacity(0.2)),
                    Expanded(
                      child: _buildBalanceItem(
                        'الرصيد',
                        entriesController.totalBalance,
                        Colors.white,
                        Icons.account_balance_wallet_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceItem(String label, double amount, Color color, IconData icon) {
    final formatter = NumberFormat('#,##0.##', 'en_US');
    return Column(
      children: [
        Icon(icon, color: color.withOpacity(0.8), size: 14),
        const SizedBox(height: 4),
        Text(
          formatter.format(amount),
          style: TextStyle(
            color: color,
            fontSize: 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'myfont',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 10,
            fontFamily: 'myfont',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBottomNav(HomeController homeController) {
    final tabs = [
      {'icon': Icons.receipt_long_rounded, 'label': 'القيود', 'index': 1},
      {'icon': Icons.assessment_rounded, 'label': 'التقارير', 'index': 2},
      {'icon': Icons.people_rounded, 'label': 'العملاء', 'index': 3},
      {'icon': Icons.import_export_rounded, 'label': 'تصدير/استيراد', 'index': 4},
    ];

    return Obx(() {
      // Map display index: 0,1 -> 0 (entries), 2->1, 3->2, 4->3
      int displayActive = homeController.currentTabIndex.value;
      if (displayActive <= 1) displayActive = 0;
      else if (displayActive == 2) displayActive = 1;
      else if (displayActive == 3) displayActive = 2;
      else if (displayActive == 4) displayActive = 3;

      return Directionality(
        textDirection: ui.TextDirection.ltr,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Items before FAB (2 items)
                ...tabs.take(2).toList().asMap().entries.map((entry) {
                  
                  final tab = entry.value;
                  final tabIndex = tab['index'] as int;
                  final isActive = homeController.currentTabIndex.value == tabIndex ||
                      (tabIndex == 1 && homeController.currentTabIndex.value == 0);
                  return Expanded(
                    child: _buildNavItem(
                      tab['icon'] as IconData,
                      tab['label'] as String,
                      isActive,
                      () => homeController.changeTab(tabIndex),
                    ),
                  );
                }),
                // FAB space
                const SizedBox(width: 70),
                // Items after FAB (2 items)
                ...tabs.skip(2).toList().asMap().entries.map((entry) {
                  final tab = entry.value;
                  final tabIndex = tab['index'] as int;
                  final isActive = homeController.currentTabIndex.value == tabIndex;
                  return Expanded(
                    child: _buildNavItem(
                      tab['icon'] as IconData,
                      tab['label'] as String,
                      isActive,
                      () => homeController.changeTab(tabIndex),
                    ),
                  );
                }),
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
                fontFamily: 'myfont',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB(HomeController homeController) {
    return Obx(() {
      final tabIndex = homeController.currentTabIndex.value;
      // Hide FAB on reports and import/export tabs
      if (tabIndex == 2 || tabIndex == 4) {
        return const SizedBox.shrink();
      }

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
            onTap: () => Get.to(() => const AddEntryView()),
            child: const Center(
              child: Icon(Icons.add_rounded, color: Colors.white, size: 28),
            ),
          ),
        ),
      );
    });
  }

  void _showUserMenu(BuildContext context, AuthController authController) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40, height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.lightGray,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Obx(() {
                final user = authController.user.value;
                return Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.primaryDark.withOpacity(0.1),
                      backgroundImage: user?.photoUrl.isNotEmpty == true
                          ? NetworkImage(user!.photoUrl) : null,
                      child: user?.photoUrl.isEmpty != false
                          ? Text(
                              user?.displayName.isNotEmpty == true
                                  ? user!.displayName[0].toUpperCase() : '?',
                              style: const TextStyle(
                                color: AppColors.primaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 22, fontFamily: 'myfont',
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'المستخدم',
                            style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary, fontFamily: 'myfont',
                            ),
                          ),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13, color: AppColors.mediumGray, fontFamily: 'myfont',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 20),
              const Divider(color: AppColors.lightGray),
              const SizedBox(height: 8),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
                ),
                title: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontWeight: FontWeight.w600, color: AppColors.error, fontFamily: 'myfont',
                  ),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _showLogoutConfirm(context, authController);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirm(BuildContext context, AuthController authController) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.logout_rounded, color: AppColors.error, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'تسجيل الخروج',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'myfont'),
              ),
            ],
          ),
          content: const Text(
            'هل تريد تسجيل الخروج من حسابك؟',
            style: TextStyle(fontSize: 14, fontFamily: 'myfont'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.mediumGray, fontFamily: 'myfont')),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                authController.signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _showExitConfirmDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => Directionality(
        textDirection: ui.TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
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
              const Text(
                'الخروج من التطبيق',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, fontFamily: 'myfont'),
              ),
            ],
          ),
          content: const Text(
            'هل تريد الخروج من التطبيق؟',
            style: TextStyle(fontSize: 14, fontFamily: 'myfont'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('إلغاء',
                  style: TextStyle(color: AppColors.mediumGray, fontFamily: 'myfont')),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('خروج', style: TextStyle(fontFamily: 'myfont')),
            ),
          ],
        ),
      ),
    );
    return result ?? false;
  }
}
