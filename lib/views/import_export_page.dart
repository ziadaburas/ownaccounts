import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/entries_controller.dart';
import '../controllers/import_export_controller.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/balance_header.dart';
import '../widgets/custom_inpus.dart';
// تأكد من استيراد مسارات الويدجت الخاصة بك هنا:
// import '../widgets/custom_app_bar.dart';
// import '../widgets/balance_header.dart';

class ImportExportPage extends StatelessWidget {
  const ImportExportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ImportExportController());
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: Column(
          children: [
            // Header: استخدام CustomAppBar و BalanceHeader
            Obx(() {
              // حساب الإحصائيات لعرضها في الهيدر بناءً على فلاتر التصدير المحددة
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

                // أيقونة التصدير والاستيراد
                profileWidget: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.import_export_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                welcomeText: 'التصدير والاستيراد',
                emailText: 'تبادل البيانات مع ملفات Excel',

                // تمرير الرصيد وعدد القيود
                balanceHeader: BalanceHeader(
                  totalCredit: credit,
                  totalDebit: debit,
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
                    // ========== Export Section ==========
                    _buildSectionHeader(
                      'تصدير إلى Excel',
                      Icons.file_download_rounded,
                      AppColors.success,
                    ),
                    const SizedBox(height: 12),

                    Obx(() => Column(
                          children: [
                            _buildFilterOption(
                                controller,
                                ExportFilterType.all,
                                'كل القيود',
                                Icons.receipt_long_rounded,
                                'تصدير جميع القيود',
                                isDark),
                            _buildFilterOption(
                                controller,
                                ExportFilterType.customer,
                                'عميل محدد',
                                Icons.person_rounded,
                                'تصدير قيود عميل معين',
                                isDark),
                            _buildFilterOption(
                                controller,
                                ExportFilterType.period,
                                'فترة محددة',
                                Icons.date_range_rounded,
                                'تصدير قيود خلال فترة زمنية',
                                isDark),
                            _buildFilterOption(
                                controller,
                                ExportFilterType.customerPeriod,
                                'عميل + فترة',
                                Icons.filter_alt_rounded,
                                'تصدير قيود عميل في فترة محددة',
                                isDark),
                          ],
                        )),

                    const SizedBox(height: 14),

                    // Additional Filters
                    Obx(() {
                      final showCustomer = controller.exportFilterType.value ==
                              ExportFilterType.customer ||
                          controller.exportFilterType.value ==
                              ExportFilterType.customerPeriod;
                      final showDate = controller.exportFilterType.value ==
                              ExportFilterType.period ||
                          controller.exportFilterType.value ==
                              ExportFilterType.customerPeriod;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showCustomer) ...[
                            _buildLabel('اختر العميل', isDark),
                            const SizedBox(height: 8),
                            CustomDropdownField(
                              items: Get.find<EntriesController>()
                                  .customerNames, // أو controller.availableCustomers
                              hintText: 'اختر العميل',
                              selectedValue: controller.selectedCustomer.value,
                              isDark: isDark,
                              onChanged: (value) {
                                if (value != null) {
                                  controller.selectedCustomer.value = value;
                                }
                              },
                            ),
                            const SizedBox(height: 14),
                          ],
                          if (showDate) ...[
                            _buildLabel('الفترة الزمنية', isDark),
                            const SizedBox(height: 8),
                           
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
                            const SizedBox(height: 14),
                          ],
                        ],
                      );
                    }),

                    // Export Button (تم حذف مربع المعاينة من هنا)
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: controller.isExporting.value
                                ? null
                                : () => _handleExport(context, controller),
                            icon: controller.isExporting.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.download_rounded),
                            label: Text(
                              controller.isExporting.value
                                  ? 'جاري التصدير...'
                                  : 'تصدير إلى Excel',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.success,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)),
                              elevation: 2,
                              shadowColor: AppColors.success.withOpacity(0.3),
                            ),
                          ),
                        )),

                    const SizedBox(height: 14),

                    Center(
                      child: TextButton.icon(
                        onPressed: () => controller.resetFilters(),
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('إعادة تعيين الفلاتر',
                            style: TextStyle()),
                        style: TextButton.styleFrom(
                            foregroundColor: AppColors.mediumGray),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Divider(
                        color: isDark
                            ? AppColors.darkDivider
                            : AppColors.lightGray,
                        thickness: 1.5),
                    const SizedBox(height: 16),

                    // ========== Import Section ==========
                    _buildSectionHeader(
                      'استيراد من Excel',
                      Icons.file_upload_rounded,
                      AppColors.primaryMedium,
                    ),
                    const SizedBox(height: 12),

                    // Instructions
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.primaryMedium.withOpacity(0.08)
                            : AppColors.primaryDark.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                            color: isDark
                                ? AppColors.darkDivider
                                : AppColors.primaryDark.withOpacity(0.1)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline_rounded,
                                  color: AppColors.primaryMedium, size: 17),
                              SizedBox(width: 8),
                              Text(
                                'تعليمات الاستيراد',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryMedium,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildInstruction('1',
                              'الملف يجب أن يكون بصيغة .xlsx أو .xls', isDark),
                          _buildInstruction(
                              '2',
                              'الصف الأول يجب أن يكون رأس الجدول (التاريخ، العميل، الاتجاه، المبلغ)',
                              isDark),
                          _buildInstruction(
                              '3', 'عمود الاتجاه: "لي" أو "عليّا"', isDark),
                          _buildInstruction(
                              '4',
                              'التاريخ بصيغة DD/MM/YYYY (مثال: 25/01/2025)',
                              isDark),
                          _buildInstruction(
                              '5',
                              'يمكن استيراد ملفات تم تصديرها مسبقاً من التطبيق مباشرة',
                              isDark),
                        ],
                      ),
                    ),

                    const SizedBox(height: 14),

                    // Import Button
                    Obx(() => SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: controller.isImporting.value
                                ? null
                                : () => controller.importFromExcel(),
                            icon: controller.isImporting.value
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : const Icon(Icons.upload_rounded),
                            label: Text(
                              controller.isImporting.value
                                  ? 'جاري الاستيراد...'
                                  : 'اختر ملف Excel للاستيراد',
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13)),
                              elevation: 2,
                            ),
                          ),
                        )),

                    // Import Result
                    Obx(() {
                      if (!controller.showImportResult.value) {
                        return const SizedBox.shrink();
                      }

                      final isSuccess = controller.importedCount.value > 0;
                      final resultColor =
                          isSuccess ? AppColors.success : AppColors.error;

                      return Container(
                        margin: const EdgeInsets.only(top: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: resultColor.withOpacity(0.07),
                          borderRadius: BorderRadius.circular(13),
                          border:
                              Border.all(color: resultColor.withOpacity(0.25)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isSuccess
                                      ? Icons.check_circle_rounded
                                      : Icons.error_rounded,
                                  color: resultColor,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isSuccess
                                        ? 'تم استيراد ${controller.importedCount.value} قيد بنجاح'
                                        : 'فشل الاستيراد',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: resultColor,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      controller.resetImportResult(),
                                  icon:
                                      const Icon(Icons.close_rounded, size: 18),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  color: AppColors.mediumGray,
                                ),
                              ],
                            ),
                            if (controller.importErrors.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'تنبيهات:',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.orange.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              ...controller.importErrors
                                  .take(5)
                                  .map((e) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 2),
                                        child: Text(
                                          '\u2022 $e',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.orange.shade800),
                                        ),
                                      )),
                              if (controller.importErrors.length > 5)
                                Text(
                                  '... و ${controller.importErrors.length - 5} تنبيه آخر',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade800),
                                ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String label, bool isDark) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(
    ImportExportController controller,
    ExportFilterType type,
    String title,
    IconData icon,
    String subtitle,
    bool isDark,
  ) {
    final isSelected = controller.exportFilterType.value == type;
    return GestureDetector(
      onTap: () => controller.exportFilterType.value = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.primaryMedium.withOpacity(0.15)
                  : AppColors.primaryDark.withOpacity(0.06))
              : (isDark ? AppColors.darkCard : AppColors.cardBackground),
          borderRadius: BorderRadius.circular(12),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? (isDark
                        ? AppColors.primaryMedium.withOpacity(0.2)
                        : AppColors.primaryDark.withOpacity(0.1))
                    : (isDark ? AppColors.darkSurface : AppColors.background),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon,
                  color: isSelected
                      ? (isDark
                          ? AppColors.primaryLight
                          : AppColors.primaryDark)
                      : AppColors.mediumGray,
                  size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: isSelected
                            ? (isDark
                                ? AppColors.primaryLight
                                : AppColors.primaryDark)
                            : (isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.textPrimary),
                      )),
                  Text(subtitle,
                      style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.mediumGray)),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 20,
                height: 20,
                decoration: const BoxDecoration(
                    color: AppColors.primaryMedium, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 13),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction(String number, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primaryMedium.withOpacity(0.2)
                  : AppColors.primaryDark.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(number,
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryMedium)),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.mediumGray)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleExport(
      BuildContext context, ImportExportController controller) async {
    final entries = controller.filteredEntries;
    if (entries.isEmpty) {
      Get.snackbar(
        'تنبيه',
        'لا توجد قيود مطابقة للفلتر المحدد',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    controller.isExporting.value = true;
    try {
      final bytes = await controller.generateExcelBytes();
      if (bytes == null) {
        Get.snackbar(
          'خطأ',
          'فشل إنشاء ملف Excel',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
        return;
      }

      if (kIsWeb) {
        _downloadFileWeb(bytes, controller.exportFileName);
        Get.snackbar(
          'تم التصدير بنجاح',
          'تم تحميل ملف Excel (${entries.length} قيد)',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success,
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
          margin: const EdgeInsets.all(12),
        );
      } else {
        await controller.exportToExcelMobile();
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'حدث خطأ: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      controller.isExporting.value = false;
    }
  }

  void _downloadFileWeb(List<int> bytes, String fileName) {
    if (kDebugMode) {
      debugPrint('Web download: $fileName (${bytes.length} bytes)');
    }
  }
}
