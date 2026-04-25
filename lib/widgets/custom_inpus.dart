import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
// تأكد من استدعاء مسار AppColors الخاص بك هنا

class CustomSuggestionField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final List<String> suggestions;
  final bool isDark;
  final int maxLines;

  const CustomSuggestionField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    required this.suggestions,
    required this.isDark,
    this.maxLines = 1,
  });

  @override
  State<CustomSuggestionField> createState() => _CustomSuggestionFieldState();
}

class _CustomSuggestionFieldState extends State<CustomSuggestionField> {
  // متغيرات الحالة الطبيعية بدلاً من Rx
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          scrollPadding: const EdgeInsets.only(bottom: 250),
          maxLines: widget.maxLines,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Padding(
              padding: widget.maxLines > 1
                  ? const EdgeInsets.only(bottom: 24)
                  : EdgeInsets.zero,
              child: Icon(widget.prefixIcon, color: AppColors.primaryLight),
            ),
            suffixIcon: widget.suggestions.isNotEmpty
                ? Padding(
                    padding: widget.maxLines > 1
                        ? const EdgeInsets.only(bottom: 24)
                        : EdgeInsets.zero,
                    child: IconButton(
                      icon: Icon(
                        _showSuggestions
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: AppColors.primaryMedium,
                      ),
                      onPressed: () {
                        // استخدام سياق الفلتر الطبيعي بدلاً من Get.context!
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showSuggestions = !_showSuggestions;
                          if (_showSuggestions) {
                            _filteredSuggestions = List.from(widget.suggestions);
                          }
                        });
                      },
                    ),
                  )
                : null,
            filled: true,
            fillColor: widget.isDark ? AppColors.darkCard : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                  color: widget.isDark ? AppColors.darkDivider : Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
          ),
          onChanged: (value) {
            setState(() {
              _filteredSuggestions = widget.suggestions
                  .where((s) => s.toLowerCase().contains(value.toLowerCase()))
                  .toList();
              _showSuggestions = _filteredSuggestions.isNotEmpty;
            });
          },
          onTap: () {
            setState(() {
              _filteredSuggestions = widget.suggestions
                  .where((s) => s.toLowerCase().contains(widget.controller.text.toLowerCase()))
                  .toList();
              _showSuggestions = true;
            });

            final textLength = widget.controller.text.length;
            if (widget.controller.selection.isCollapsed &&
                widget.controller.selection.baseOffset == textLength - 1) {
              widget.controller.selection =
                  TextSelection.collapsed(offset: textLength);
            }
          },
        ),
        
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    if (_filteredSuggestions.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 4),
      constraints: const BoxConstraints(maxHeight: 180),
      decoration: BoxDecoration(
        color: widget.isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(vertical: 4),
        itemCount: _filteredSuggestions.length,
        separatorBuilder: (_, __) => Divider(
            height: 1,
            color: widget.isDark ? AppColors.darkDivider : Colors.grey.shade100),
        itemBuilder: (context, index) {
          final suggestion = _filteredSuggestions[index];
          return ListTile(
            dense: true,
            leading: const Icon(Icons.history, size: 18, color: Colors.grey),
            title: Text(
              suggestion,
              style: const TextStyle(fontSize: 14),
            ),
            onTap: () {
              setState(() {
                widget.controller.text = suggestion;
                _showSuggestions = false;
              });
            },
          );
        },
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final List<String> items;
  final String hintText;
  final String? selectedValue;
  final ValueChanged<String?>? onChanged;
  final bool isDark;

  const CustomDropdownField({
    super.key,
    required this.items,
    required this.hintText,
    this.selectedValue,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.cardBackground,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: isDark ? AppColors.darkDivider : AppColors.lightGray),
        boxShadow: isDark ? null : AppShadows.cardShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          dropdownColor: isDark ? AppColors.darkCard : null,
          hint: Text(
            hintText,
            style: TextStyle(
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSubtitle,
              fontFamily: 'myfont'
            ),
          ),
          value: (selectedValue != null && selectedValue!.isNotEmpty && items.contains(selectedValue))
              ? selectedValue
              : null,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.primaryMedium),
          style: TextStyle(
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
            fontSize: 14,
          ),
          items: items
              .map((name) => DropdownMenuItem(
                    value: name,
                    alignment: Alignment.centerRight,
                    child: Text(name,style: const TextStyle(fontFamily: 'myfont'),),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class CustomDateTimePicker extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onChanged;
  final bool includeTime; // للتحكم بظهور الوقت
  final bool isDark;
  final String? hint;

  const CustomDateTimePicker({
    super.key,
    required this.selectedDate,
    required this.onChanged,
    this.includeTime = true, // القيمة الافتراضية: نعم مع الوقت
    required this.isDark,
    this.hint
  });

  // دالة مدمجة لحساب اليوم/أمس/غداً لتكون الويدجت مستقلة 100%
  String _getRelativeDate(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (dateToCheck == today) return 'اليوم';
    if (dateToCheck == yesterday) return 'أمس';
    if (dateToCheck == tomorrow) return 'غداً';
    return ''; // يمكن إرجاع أي نص افتراضي هنا أو تركه فارغاً
  }

  Future<void> _selectDate(BuildContext context) async {
    // 1. اختيار التاريخ أولاً
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: AppColors.primaryLight,
                    onPrimary: Colors.white,
                  )
                : const ColorScheme.light(
                    primary: AppColors.primaryLight,
                    onPrimary: Colors.white,
                  ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      // 2. إذا كان المستخدم يريد الوقت أيضاً، افتح نافذة الوقت
      if (includeTime) {
        final pickedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(selectedDate),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: isDark
                    ? const ColorScheme.dark(
                        primary: AppColors.primaryLight,
                        onPrimary: Colors.white,
                      )
                    : const ColorScheme.light(
                        primary: AppColors.primaryLight,
                        onPrimary: Colors.white,
                      ),
              ),
              child: child!,
            );
          },
        );

        // 3. دمج التاريخ والوقت
        if (pickedTime != null) {
          final finalDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          onChanged(finalDateTime); // إرسال النتيجة المدمجة
        }
      } else {
        // إذا كان includeTime بـ false، أرسل التاريخ فقط
        onChanged(pickedDate);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // تحديد التنسيق بناءً على اختيار إظهار الوقت
    final dateFormat = includeTime
        ? DateFormat('dd/MM/yyyy - hh:mm a', 'en_US')
        : DateFormat('dd/MM/yyyy', 'en_US');

    return InkWell(
      onTap: () => _selectDate(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkDivider : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if(hint != null)
            Text(hint!,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 10),
            ),
            const SizedBox(height: 5,),
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, color: AppColors.primaryLight,size: 15,),
                const SizedBox(width: 12),
                Text(
                  dateFormat.format(selectedDate),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Text(
                  _getRelativeDate(selectedDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}