import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '/controllers/sync_controller.dart';
import '../controllers/auth_controller.dart';
import '../theme/app_theme.dart';
import 'home_view.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              AppColors.primaryMedium,
              AppColors.primaryDark,
              Color(0xFF072218),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: -40,
                right: -40,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              Positioned(
                bottom: -60,
                left: -40,
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.04),
                  ),
                ),
              ),
              // Main Content
              Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 25,
                          spreadRadius: 3,
                          offset: const Offset(0, 10),
                        ),
                        BoxShadow(
                          color: AppColors.primaryLight.withOpacity(0.25),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.asset(
                        'assets/hisabati_logo.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 64,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'حساباتي',
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontFamily: 'myfont',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'إدارة حساباتك بسهولة',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white.withOpacity(0.75),
                      fontFamily: 'myfont',
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Features
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Column(
                      children: [
                        _buildFeatureRow(Icons.receipt_long_rounded, 'تتبع جميع قيودك المالية'),
                        const SizedBox(height: 14),
                        _buildFeatureRow(Icons.people_rounded, 'إدارة حسابات العملاء'),
                        const SizedBox(height: 14),
                        _buildFeatureRow(Icons.cloud_sync_rounded, 'مزامنة تلقائية على السحابة'),
                        const SizedBox(height: 14),
                        _buildFeatureRow(Icons.picture_as_pdf_rounded, 'تقارير PDF احترافية'),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                  // Sign In Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 36),
                    child: Obx(() {
                      return Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: controller.isSigningIn.value
                              ? null
                              : () => _handleSignIn(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primaryDark,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: controller.isSigningIn.value
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: AppColors.primaryDark,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 28,
                                      height: 28,
                                      decoration: const BoxDecoration(shape: BoxShape.circle),
                                      child: const Icon(Icons.g_mobiledata, size: 28),
                                    ),
                                    const SizedBox(width: 10),
                                    const Text(
                                      'تسجيل الدخول بحساب Google',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'myfont',
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, color: Colors.white54, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        'بياناتك آمنة ومحمية',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.55),
                          fontFamily: 'myfont',
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Icon(icon, color: AppColors.primaryLight, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w400,
              fontFamily: 'myfont',
            ),
          ),
        ),
        Icon(Icons.check_circle_rounded,
            color: AppColors.primaryLight.withOpacity(0.6), size: 16),
      ],
    );
  }

  Future<void> _handleSignIn() async {
    final success = await controller.signInWithGoogle();

    if (success) {
      Get.offAll(() => const HomeView());
      var authController = Get.find<AuthController>();
      var syncController = Get.find<SyncController>();
      final userId = authController.user.value?.uid;
      if (userId != null) {
        authController.refreshToken().then((_) {
          syncController.syncNow(userId);
        });
      }
    } else if (controller.error.value.isNotEmpty) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول: ${controller.error.value}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }
}
