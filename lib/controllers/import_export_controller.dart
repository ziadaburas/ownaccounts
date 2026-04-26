import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../models/entry_model.dart';
import '../services/excel_service.dart';
import 'auth_controller.dart';
import 'dialog_helper.dart';
import 'entries_controller.dart';

enum ExportFilterType { all, customer, period, customerPeriod }

class ImportExportController extends GetxController {
  // حالة التصدير
  final Rx<ExportFilterType> exportFilterType = ExportFilterType.all.obs;
  final RxString selectedCustomer = ''.obs;
  final Rx<DateTime> fromDate = Rx<DateTime>(DateTime.now().subtract(const Duration(days: 30)));
  final Rx<DateTime> toDate = Rx<DateTime>(DateTime.now());
  final RxBool isExporting = false.obs;
  final RxBool isImporting = false.obs;

  // نتيجة الاستيراد
  final RxInt importedCount = 0.obs;
  final RxList<String> importErrors = <String>[].obs;
  final RxBool showImportResult = false.obs;

  List<String> get availableCustomers =>
      Get.find<EntriesController>().customerNames;

  List<EntryModel> get filteredEntries {
    final allEntries = Get.find<EntriesController>().entries;
    List<EntryModel> filtered = List.from(allEntries);

    if ((exportFilterType.value == ExportFilterType.customer ||
            exportFilterType.value == ExportFilterType.customerPeriod) &&
        selectedCustomer.value.isNotEmpty) {
      filtered = filtered
          .where((e) => e.customerName == selectedCustomer.value)
          .toList();
    }

    if (exportFilterType.value == ExportFilterType.period ||
        exportFilterType.value == ExportFilterType.customerPeriod) {
     
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

  String get exportFileName {
    final dateStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    switch (exportFilterType.value) {
      case ExportFilterType.all:
        return 'حساباتي_كل_القيود_$dateStr.xlsx';
      case ExportFilterType.customer:
        return 'حساباتي_${selectedCustomer.value}_$dateStr.xlsx';
      case ExportFilterType.period:
        return 'حساباتي_فترة_$dateStr.xlsx';
      case ExportFilterType.customerPeriod:
        return 'حساباتي_${selectedCustomer.value}_فترة_$dateStr.xlsx';
    }
  }


  /// تصدير للموبايل - يستخدم FilePicker
  Future<void> exportToExcelMobile() async {
    final entries = filteredEntries;
    if (entries.isEmpty) {
     
      showMsgDialog(message: 'لا توجد قيود مطابقة للفلتر المحدد',type: MsgType.warning);
      return;
    }

    isExporting.value = true;
    try {
      final bytes = await ExcelService.exportEntries(entries: entries);
      if (bytes == null) {
        
        showMsgDialog(message: 'فشل إنشاء ملف Excel',type: MsgType.error);
        return;
      }

      final savePath = await FilePicker.platform.saveFile(
        dialogTitle: 'حفظ ملف Excel',
        fileName: exportFileName,
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        bytes: bytes,
      );

      if (savePath != null) {
        
        showMsgDialog(message: 'تم حفظ الملف:\n$savePath',type: MsgType.success);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Export error: $e');
      
      showMsgDialog(message:'حدث خطأ أثناء التصدير' ,type: MsgType.error);
    } finally {
      isExporting.value = false;
    }
  }

  /// توليد bytes للتصدير (مشترك بين الويب والموبايل)
  Future<Uint8List?> generateExcelBytes() async {
    return await ExcelService.exportEntries(entries: filteredEntries);
  }

  Future<void> importFromExcel() async {
    isImporting.value = true;
    showImportResult.value = false;
    importErrors.clear();
    importedCount.value = 0;

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        isImporting.value = false;
        return;
      }

      final file = result.files.first;
      if (file.bytes == null) {
     
        showMsgDialog(message: 'لم يتم قراءة الملف بشكل صحيح',type: MsgType.error);
        isImporting.value = false;
        return;
      }

      final importResult = await ExcelService.importEntries(file.bytes!);

      if (importResult.successCount == 0 && importResult.hasErrors) {
        importErrors.assignAll(importResult.errors);
        showImportResult.value = true;
        isImporting.value = false;
        return;
      }

      // أضف القيود إلى قاعدة البيانات
      final authController = Get.find<AuthController>();
      final entriesController = Get.find<EntriesController>();
      final userId = authController.user.value?.uid;

      if (userId == null) {
        
        showMsgDialog(message: 'يجب تسجيل الدخول أولاً',type: MsgType.error);
        isImporting.value = false;
        return;
      }

      int added = 0;
      int failed = 0;
      for (final entry in importResult.entries) {
        try {
          final success = await entriesController.addEntry(userId, entry);
          if (success) {
            added++;
          } else {
            failed++;
          }
        } catch (e) {
          failed++;
        }
      }

      importedCount.value = added;
      importErrors.assignAll(importResult.errors);
      if (failed > 0) {
        importErrors.add('فشل إضافة $failed قيد');
      }
      showImportResult.value = true;

      if (added > 0) {
        
        showMsgDialog(message:'تم إضافة $added قيد من الملف' ,type: MsgType.success);
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Import error: $e');
      
      showMsgDialog(message: 'حدث خطأ أثناء الاستيراد: $e',type: MsgType.error);
    } finally {
      isImporting.value = false;
    }
  }

  void resetFilters() {
    exportFilterType.value = ExportFilterType.all;
    selectedCustomer.value = '';
    fromDate.value = DateTime.now().subtract(const Duration(days: 30));
    toDate.value = (DateTime.now());
  }

  void resetImportResult() {
    showImportResult.value = false;
    importErrors.clear();
    importedCount.value = 0;
  }
}
