import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/reports_controller.dart';
import '../../controllers/entries_controller.dart';
import '../../theme/app_theme.dart';

class ReportsView extends StatelessWidget {
  const ReportsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ReportsController());
    final dateFormatter = DateFormat('dd/MM/yyyy', 'en_US');
    final amountFormatter = NumberFormat('#,##0.##', 'en_US');

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [AppColors.primaryMedium, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: AppShadows.headerShadow,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.assessment_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'التقارير',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'myfont',
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'توليد وطباعة تقارير PDF',
                        style: TextStyle(
                          color: Color(0xFFB2D8C8),
                          fontSize: 12,
                          fontFamily: 'myfont',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Report Type Section
            _buildSectionTitle('نوع التقرير', Icons.tune_rounded),
            const SizedBox(height: 10),

            Obx(() => Column(
              children: [
                _buildReportTypeCard(
                  controller,
                  ReportType.all,
                  'كل القيود',
                  Icons.receipt_long_rounded,
                  'تقرير شامل لجميع القيود',
                ),
                _buildReportTypeCard(
                  controller,
                  ReportType.customer,
                  'عميل محدد',
                  Icons.person_rounded,
                  'تقرير قيود عميل معين',
                ),
                _buildReportTypeCard(
                  controller,
                  ReportType.period,
                  'فترة محددة',
                  Icons.date_range_rounded,
                  'تقرير قيود خلال فترة زمنية',
                ),
                _buildReportTypeCard(
                  controller,
                  ReportType.customerPeriod,
                  'عميل + فترة',
                  Icons.filter_alt_rounded,
                  'تقرير عميل خلال فترة محددة',
                ),
              ],
            )),

            const SizedBox(height: 20),

            // Filters Section
            Obx(() {
              final showCustomer =
                  controller.reportType.value == ReportType.customer ||
                      controller.reportType.value == ReportType.customerPeriod;
              final showDate =
                  controller.reportType.value == ReportType.period ||
                      controller.reportType.value == ReportType.customerPeriod;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showCustomer) ...[
                    _buildSectionTitle('اختر العميل', Icons.person_search_rounded),
                    const SizedBox(height: 10),
                    _buildCustomerDropdown(controller),
                    const SizedBox(height: 20),
                  ],
                  if (showDate) ...[
                    _buildSectionTitle('الفترة الزمنية', Icons.date_range_rounded),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            'من تاريخ',
                            controller.fromDate.value,
                            dateFormatter,
                            () => controller.selectFromDate(context),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateSelector(
                            context,
                            'إلى تاريخ',
                            controller.toDate.value,
                            dateFormatter,
                            () => controller.selectToDate(context),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ],
              );
            }),

            // Preview Section
            Obx(() {
              final entries = controller.filteredEntries;
              double credit = 0, debit = 0;
              for (final e in entries) {
                if (e.isCredit) {
                  credit += e.amount;
                } else {
                  debit += e.amount;
                }
              }
              final balance = credit - debit;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.cardShadow,
                  border: Border.all(
                    color: AppColors.primaryDark.withOpacity(0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.preview_rounded,
                            color: AppColors.primaryDark,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'معاينة التقرير',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                            fontFamily: 'myfont',
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryDark.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${entries.length} قيد',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryDark,
                              fontFamily: 'myfont',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: AppColors.lightGray, height: 1),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPreviewStat(
                            'لي (دائن)',
                            amountFormatter.format(credit),
                            AppColors.success,
                            Icons.arrow_upward_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.lightGray,
                        ),
                        Expanded(
                          child: _buildPreviewStat(
                            'علي (مدين)',
                            amountFormatter.format(debit),
                            AppColors.error,
                            Icons.arrow_downward_rounded,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 50,
                          color: AppColors.lightGray,
                        ),
                        Expanded(
                          child: _buildPreviewStat(
                            'الرصيد',
                            '${balance >= 0 ? "+" : ""}${amountFormatter.format(balance)}',
                            balance >= 0 ? AppColors.success : AppColors.error,
                            Icons.account_balance_wallet_rounded,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 20),

            // Generate PDF Button
            Obx(() => SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: controller.isGenerating.value
                    ? null
                    : () => controller.generateAndPrintPdf(),
                icon: controller.isGenerating.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.picture_as_pdf_rounded, size: 22),
                label: Text(
                  controller.isGenerating.value
                      ? 'جاري توليد التقرير...'
                      : 'توليد وطباعة PDF',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'myfont',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.primaryDark.withOpacity(0.3),
                ),
              ),
            )),

            const SizedBox(height: 12),

            // Reset Button
            Center(
              child: TextButton.icon(
                onPressed: () => controller.resetFilters(),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'إعادة تعيين الفلاتر',
                  style: TextStyle(fontFamily: 'myfont'),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.mediumGray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryMedium),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            fontFamily: 'myfont',
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
  ) {
    final isSelected = controller.reportType.value == type;

    return GestureDetector(
      onTap: () => controller.reportType.value = type,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryDark.withOpacity(0.06)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryMedium
                : AppColors.lightGray,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [] : AppShadows.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryDark.withOpacity(0.12)
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryDark
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
                          ? AppColors.primaryDark
                          : AppColors.textPrimary,
                      fontFamily: 'myfont',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mediumGray,
                      fontFamily: 'myfont',
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
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerDropdown(ReportsController controller) {
    final customers = Get.find<EntriesController>().customerNames;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: AppColors.lightGray),
        boxShadow: AppShadows.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: const Text(
            'اختر العميل',
            style: TextStyle(color: AppColors.textSubtitle, fontFamily: 'myfont'),
          ),
          value: controller.selectedCustomer.value.isNotEmpty
              ? controller.selectedCustomer.value
              : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryMedium),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontFamily: 'myfont',
            fontSize: 14,
          ),
          items: customers
              .map((name) => DropdownMenuItem(value: name, child: Text(name)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              controller.selectedCustomer.value = value;
            }
          },
        ),
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime? date,
    DateFormat formatter,
    VoidCallback onTap,
  ) {
    final hasDate = date != null;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: hasDate
              ? AppColors.primaryDark.withOpacity(0.04)
              : AppColors.cardBackground,
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: hasDate ? AppColors.primaryMedium : AppColors.lightGray,
            width: hasDate ? 1.5 : 1,
          ),
          boxShadow: AppShadows.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: hasDate ? AppColors.primaryMedium : AppColors.textSubtitle,
                fontFamily: 'myfont',
              ),
            ),
            const SizedBox(height: 5),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: hasDate ? AppColors.primaryMedium : AppColors.mediumGray,
                ),
                const SizedBox(width: 6),
                Text(
                  hasDate ? formatter.format(date) : 'اختر',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: hasDate ? AppColors.textPrimary : AppColors.textSubtitle,
                    fontFamily: 'myfont',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStat(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
            fontFamily: 'myfont',
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.mediumGray,
            fontFamily: 'myfont',
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
