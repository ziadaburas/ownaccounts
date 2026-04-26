import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../controllers/dialog_helper.dart';
import '../controllers/entries_controller.dart';
import '../models/entry_model.dart';
import '../services/pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar.dart';
import '../widgets/balance_header.dart';
import '../widgets/card_entry.dart';
import 'add_entry_view.dart';

class CustomerEntriesView extends StatelessWidget {
  final String customerName;

  const CustomerEntriesView({super.key, required this.customerName});

  @override
  Widget build(BuildContext context) {
    final entriesController = Get.find<EntriesController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        body: Obx(() {
          final entries = entriesController.getCustomerEntries(customerName);

          double totalCredit = 0;
          double totalDebit = 0;
          for (final entry in entries) {
            if (entry.isCredit) {
              totalCredit += entry.amount;
            } else {
              totalDebit += entry.amount;
            }
          }

          return Column(
            children: [
              // ===== هيدر مشابه للرئيسية =====
              CustomAppBar(
                // 1. زر الرجوع (بدلاً من القائمة)
                onDrawerPressed: () => Get.back(),
                drawerIcon: Icons.arrow_forward_ios_rounded,
                drawerTooltip: 'رجوع',

                // 2. صورة واسم العميل
                profileWidget: Container(
                  color: Colors.white.withOpacity(0.2),
                  alignment: Alignment.center,
                  child: Text(
                    customerName.isNotEmpty
                        ? customerName[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                welcomeText: customerName,
                emailText: null, // لا يوجد بريد إلكتروني هنا

                // 3. زر المشاركة (بدلاً من المزامنة)
                actionIcon: Icons.share_rounded,
                actionTooltip: 'مشاركة تقرير PDF',
                onActionPressed: () => _shareCustomerPdf(entries, customerName),
                isActionLoading: false,

                // 4. الرصيد
                balanceHeader: BalanceHeader(
                  totalCredit: totalCredit,
                  totalDebit: totalDebit,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text(
                      'القيود (${entries.length})',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : const Color(0xFF37474F),
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: entries.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long_rounded,
                                size: 64,
                                color: isDark
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text(
                              'لا توجد قيود لهذا العميل',
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          return _buildEntryTile(
                            entries[index],
                            index == 0
                                ? null
                                : entries[index - 1],
                          );
                        },
                      ),
              ),
            ],
          );
        }),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              Get.to(() => AddEntryView(presetCustomerName: customerName)),
          backgroundColor: AppColors.primaryMedium,
          foregroundColor: Colors.white,
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Future<void> _shareCustomerPdf(
      List<EntryModel> entries, String customerName) async {
    if (entries.isEmpty) {
      
      showMsgDialog(message: 'لا توجد قيود لمشاركتها',type: MsgType.warning);
      return;
    }

    try {
    


      final pdfBytes = await PdfService.generateReport(
        entries: entries,
        reportTitle: 'تقرير العميل: $customerName',
        customerName: customerName,
      );

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'حساباتي_${customerName}_${DateTime.now()}.pdf',
      );
    } catch (e) {
     
      showMsgDialog(message:'فشل إنشاء التقرير: $e' ,type: MsgType.error);
    }
  }

  Widget _buildEntryTile(EntryModel entry, EntryModel? lastEntry) {
    final currentItem = entry;
    bool showDateHeader = false;
    final entriesController = Get.find<EntriesController>();

    if (lastEntry == null) {
      showDateHeader = true;
    } else {
      final previousItem = lastEntry;
      if (currentItem.date.toString().split(" ").first !=
          previousItem.date.toString().split(" ").first) {
        showDateHeader = true;
      }
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      if (showDateHeader)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          child: Text(
            currentItem.date.toString().split(" ").first,
            textAlign: ui.TextAlign.left,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      CardEntryTile(
          entry: entry,
          onDelete: () => entriesController.confirmDelete(entry),
          onTap: () => Get.to(() => AddEntryView(editEntry: entry)))
    ]);
  }
}
