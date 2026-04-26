import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/dialog_helper.dart';
import '../theme/app_theme.dart';
import '../controllers/add_entry_controller.dart';
import '../models/entry_model.dart';
import '../widgets/custom_inpus.dart';

// ignore: must_be_immutable
class AddEntryView extends StatelessWidget {
  final EntryModel? editEntry;
  final String? presetCustomerName;

  AddEntryView({super.key, this.editEntry, this.presetCustomerName});
  var isDark = false;
  @override
  Widget build(BuildContext context) {
    isDark = Theme.of(context).brightness == Brightness.dark;

    final controller = Get.put(AddEntryController());
    if (editEntry != null) {
      controller.initForEdit(editEntry);
    } else if (presetCustomerName != null) {
      controller.initForCustomer(presetCustomerName!);
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.primaryMedium,
          foregroundColor: Colors.white,
          elevation: 0,
          title: Text(
            controller.isEditing ? 'تعديل القيد' : 'إضافة قيد جديد',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Credit/Debit Toggle
              Container(
                width: double.infinity,
                color: AppColors.primaryMedium,
                padding: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
                child: Obx(() => Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.all(4),
                      child: Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.isCredit.value = true,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: controller.isCredit.value
                                      ? AppColors.success
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_upward_rounded,
                                      color: controller.isCredit.value
                                          ? Colors.white
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'لي',
                                      style: TextStyle(
                                        color: controller.isCredit.value
                                            ? Colors.white
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => controller.isCredit.value = false,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: !controller.isCredit.value
                                      ? AppColors.error
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.arrow_downward_rounded,
                                      color: !controller.isCredit.value
                                          ? Colors.white
                                          : Colors.white60,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'عليا',
                                      style: TextStyle(
                                        color: !controller.isCredit.value
                                            ? Colors.white
                                            : Colors.white60,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Amount
                      _buildLabel('المبلغ *'),
                      const SizedBox(height: 8),
                      Obx(() => TextFormField(
                            controller: controller.amountController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold),
                            textDirection: ui.TextDirection.ltr,
                            textAlign: ui.TextAlign.left,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              hintText: ' المبلغ',
                              hintStyle: TextStyle(color: Colors.grey.shade400),
                              suffixIcon: Container(
                                width: 48,
                                alignment: Alignment.center,
                                child: Text(
                                  '\$',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: controller.isCredit.value
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ),
                              filled: true,
                              fillColor: isDark ? AppColors.darkCard : null,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                    color: isDark
                                        ? AppColors.darkDivider
                                        : Colors.grey.shade200),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: Color(0xFF1565C0), width: 2),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'الرجاء إدخال المبلغ';
                              }
                              final amount = double.tryParse(value);
                              if (amount == null || amount <= 0) {
                                return 'الرجاء إدخال مبلغ صحيح';
                              }
                              return null;
                            },
                          )),

                      const SizedBox(height: 20),

                      // Customer Name
                      _buildLabel('اسم العميل'),
                      const SizedBox(height: 8),
                      CustomSuggestionField(
                        controller: controller.customerController,
                        hintText: 'أدخل اسم العميل ',
                        prefixIcon: Icons.person_rounded,
                        suggestions: controller
                            .customerSuggestions, // تمرير القائمة الأصلية فقط
                        isDark: isDark,
                      ),
                      // _buildCustomerField(controller),

                      const SizedBox(height: 20),

                      // Date
                      // Date
                      _buildLabel('التاريخ والوقت *'), // تم تغيير العنوان
                      const SizedBox(height: 8),
                      Obx(() => CustomDateTimePicker(
      selectedDate: controller.selectedDate.value,
      isDark: isDark,
      includeTime: true, // اجعلها false إذا كنت تريد تاريخ فقط بدون وقت
      onChanged: (newDate) {
        controller.selectedDate.value = newDate;
      },
    )),

                      const SizedBox(height: 20),

                      // Note
                      _buildLabel('الملاحظة'),
                      const SizedBox(height: 8),
                      CustomSuggestionField(
                        controller: controller.noteController,
                        hintText: 'أدخل ملاحظة',
                        prefixIcon: Icons.note_rounded,
                        suggestions: controller.noteSuggestions,
                        isDark: isDark,
                        maxLines: 2, // تحديد عدد الأسطر
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: Obx(() => ElevatedButton(
                              onPressed: controller.isSaving.value
                                  ? null
                                  : () async {
                                      final success =
                                          await controller.saveEntry();
                                      if (success) {
                                        Get.back();
                                        
                                        showMsgDialog(message:controller.isEditing
                                              ? 'تم تحديث القيد'
                                              : 'تم إضافة القيد' ,type: MsgType.success);
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: controller.isCredit.value
                                    ? AppColors.success
                                    : AppColors.error,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                elevation: 2,
                              ),
                              child: controller.isSaving.value
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          controller.isEditing
                                              ? Icons.save_rounded
                                              : Icons.add_rounded,
                                          size: 22,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          controller.isEditing
                                              ? 'حفظ التعديلات'
                                              : 'إضافة القيد',
                                          style: const TextStyle(
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        //color: AppColors.primaryLight,
      ),
    );
  }
}
