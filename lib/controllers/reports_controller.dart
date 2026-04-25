import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:printing/printing.dart';
import '../models/entry_model.dart';
import '../services/pdf_service.dart';
import 'entries_controller.dart';

enum ReportType { all, customer, period, customerPeriod }

class ReportsController extends GetxController {
  final Rx<ReportType> reportType = ReportType.all.obs;
  final RxString selectedCustomer = ''.obs;
  final Rx<DateTime> fromDate = Rx<DateTime>(DateTime.now().subtract(const Duration(days: 30)));
  final Rx<DateTime> toDate = Rx<DateTime>(DateTime.now());
  final RxBool isGenerating = false.obs;


  List<String> get availableCustomers =>
      Get.find<EntriesController>().customerNames;

  List<EntryModel> get filteredEntries {
    final allEntries = Get.find<EntriesController>().entries;
    List<EntryModel> filtered = List.from(allEntries);

    // Filter by customer
    if ((reportType.value == ReportType.customer ||
            reportType.value == ReportType.customerPeriod) &&
        selectedCustomer.value.isNotEmpty) {
      filtered = filtered
          .where((e) => e.customerName == selectedCustomer.value)
          .toList();
    }

    // Filter by date
    if (reportType.value == ReportType.period ||
        reportType.value == ReportType.customerPeriod) {
      
        filtered = filtered
            .where((e) => !e.date.isBefore(fromDate.value))
            .toList();
      
      
        final endOfDay = DateTime(
          toDate.value.year,
          toDate.value.month,
          toDate.value.day,
          23,
          59,
          59,
        );
        filtered =
            filtered.where((e) => !e.date.isAfter(endOfDay)).toList();
      
    }

    filtered.sort((a, b) => b.date.compareTo(a.date));
    return filtered;
  }

  String get reportTitle => switch(reportType.value){
    ReportType.customer => 'عميل محدد',
    ReportType.period => 'فترة محددة',
    ReportType.customerPeriod => 'عميل + فترة',
    _ => 'كل القيود',
  };

  Future<void> generateAndPrintPdf() async {
    isGenerating.value = true;
    try {
      final entries = filteredEntries;
      if (entries.isEmpty) {
        Get.snackbar(
          'تنبيه',
          'لا توجد قيود مطابقة للفلتر المحدد',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        isGenerating.value = false;
        return;
      }

      final pdfBytes = await PdfService.generateReport(
        entries: entries,
        reportTitle: reportTitle,
        customerName: selectedCustomer.value.isNotEmpty
            ? selectedCustomer.value
            : null,
        fromDate: fromDate.value,
        toDate: toDate.value,
      );

      await Printing.layoutPdf(
        onLayout: (format) => pdfBytes,
        name: 'تقرير_حساباتي',
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل توليد التقرير: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
    isGenerating.value = false;
  }

  void resetFilters() {
    reportType.value = ReportType.all;
    selectedCustomer.value = '';
    fromDate.value = DateTime.now().subtract(const Duration(days: 30));
    toDate.value = DateTime.now();
  }
}
