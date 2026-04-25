import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/reports_controller.dart';
import '../controllers/entries_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/balance_header.dart';
import '../widgets/custom_inpus.dart';
// تأكد من استيراد مسارات الويدجت الخاصة بك هنا:
// import '../widgets/custom_app_bar.dart';
// import '../widgets/balance_header.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
        body: Column(
          children: [
            // Header: استخدام CustomAppBar و BalanceHeader
            Obx(() {
              // حساب الإحصائيات لعرضها في الهيدر بناءً على الفلاتر المحددة
              final entries = controller.filteredEntries;
              double credit = 0, debit = 0;
              for (final e in entries) {
                if (e.isCredit) {
                  credit += e.amount;
                } else {
                  debit += e.amount;
                }
              }

              return CustomAppBar(
                onDrawerPressed: () => Get.back(),
                drawerIcon: Icons.arrow_forward_ios_rounded,
                drawerTooltip: 'رجوع',
                
                // أيقونة التقارير
                profileWidget: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.assessment_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                welcomeText: 'التقارير',
                emailText: 'توليد وطباعة تقارير PDF',
                
                // تمرير الرصيد وعدد القيود للهيدر المخصص
                balanceHeader: BalanceHeader(
                  totalCredit: credit,
                  totalDebit: debit,
                  //entriesCount: entries.length,
                ),
              );
            }),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Report Type Section
                    _buildSectionTitle('نوع التقرير', Icons.tune_rounded, isDark),
                    const SizedBox(height: 10),

                    Obx(() => Column(
                          children: [
                            _buildReportTypeCard(controller, ReportType.all,
                                'كل القيود', Icons.receipt_long_rounded,
                                'تقرير شامل لجميع القيود', isDark),
                            _buildReportTypeCard(controller, ReportType.customer,
                                'عميل محدد', Icons.person_rounded,
                                'تقرير قيود عميل معين', isDark),
                            _buildReportTypeCard(controller, ReportType.period,
                                'فترة محددة', Icons.date_range_rounded,
                                'تقرير قيود خلال فترة زمنية', isDark),
                            _buildReportTypeCard(
                                controller, ReportType.customerPeriod,
                                'عميل + فترة', Icons.filter_alt_rounded,
                                'تقرير عميل خلال فترة محددة', isDark),
                          ],
                        )),

                    const SizedBox(height: 20),

                    // Filters Section
                    Obx(() {
                      final showCustomer =
                          controller.reportType.value == ReportType.customer ||
                              controller.reportType.value ==
                                  ReportType.customerPeriod;
                      final showDate =
                          controller.reportType.value == ReportType.period ||
                              controller.reportType.value ==
                                  ReportType.customerPeriod;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showCustomer) ...[
                            _buildSectionTitle(
                                'اختر العميل', Icons.person_search_rounded, isDark),
                            const SizedBox(height: 10),
                            CustomDropdownField(
  items: Get.find<EntriesController>().customerNames, // أو controller.availableCustomers
  hintText: 'اختر العميل',
  selectedValue: controller.selectedCustomer.value,
  isDark: isDark,
  onChanged: (value) {
    if (value != null) {
      controller.selectedCustomer.value = value;
    }
  },
),
                            const SizedBox(height: 20),
                          ],
                          if (showDate) ...[
                            _buildSectionTitle(
                                'الفترة الزمنية', Icons.date_range_rounded, isDark),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomDateTimePicker(
                                    selectedDate: controller.fromDate.value,
                                    isDark: isDark,
                                    includeTime: false, // اجعلها false إذا كنت تريد تاريخ فقط بدون وقت
                                    hint: 'من تاريخ',
                                    onChanged: (newDate) {
                                      controller.fromDate.value = newDate;
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: 
                                 CustomDateTimePicker(
                                    selectedDate:controller.toDate.value,
                                    isDark: isDark,
                                    includeTime: false, // اجعلها false إذا كنت تريد تاريخ فقط بدون وقت
                                    hint: 'إلى تاريخ',
                                    onChanged: (newDate) {
                                      controller.toDate.value = newDate;
                                    },
                                  ),
                                  
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ],
                      );
                    }),

                    const SizedBox(height: 16),

                    // Reset Button
                    Center(
                      child: TextButton.icon(
                        onPressed: () => controller.resetFilters(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: const Text(
                          'إعادة تعيين الفلاتر',
                          style: TextStyle(),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.mediumGray,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        // FAB لتوليد التقرير
        floatingActionButton: Obx(() => FloatingActionButton.extended(
              onPressed: controller.isGenerating.value
                  ? null
                  : () => controller.generateAndPrintPdf(),
              backgroundColor: controller.isGenerating.value
                  ? AppColors.mediumGray
                  : AppColors.primaryDark,
              icon: controller.isGenerating.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
              label: Text(
                controller.isGenerating.value
                    ? 'جاري التوليد...'
                    : 'توليد PDF',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10), 
              ),
            )),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryMedium),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildReportTypeCard(
    ReportsController controller,
    ReportType type,
    String title,
    IconData icon,
    String subtitle,
    bool isDark,
  ) {
    final isSelected = controller.reportType.value == type;

    return GestureDetector(
      onTap: () {
        controller.resetFilters();
        controller.reportType.value = type;
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.primaryMedium.withOpacity(0.15) : AppColors.primaryDark.withOpacity(0.06))
              : (isDark ? AppColors.darkCard : AppColors.cardBackground),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryMedium
                : (isDark ? AppColors.darkDivider : AppColors.lightGray),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [] : (isDark ? null : AppShadows.cardShadow),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark ? AppColors.primaryMedium.withOpacity(0.2) : AppColors.primaryDark.withOpacity(0.12))
                    : (isDark ? AppColors.darkSurface : AppColors.background),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                    : AppColors.mediumGray,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: isSelected
                          ? (isDark ? AppColors.primaryLight : AppColors.primaryDark)
                          : (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.primaryMedium,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }
}