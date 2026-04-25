import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
// تأكد من استدعاء مسار AppColors الخاص بك هنا

class CustomAppBar extends StatelessWidget {
  // 1. إعدادات الزر الأيمن (لفتح القائمة أو الرجوع)
  final VoidCallback onDrawerPressed;
  final IconData drawerIcon;
  final String drawerTooltip;

  // 2. إعدادات المستخدم أو العميل
  final Widget profileWidget; 
  final String welcomeText;
  final String? emailText; 

  // 3. إعدادات زر الإجراء الأيسر (مزامنة، مشاركة، إلخ)
  final VoidCallback? onActionPressed;
  final IconData actionIcon;
  final String actionTooltip;
  final bool isActionLoading;

  // 4. إعدادات الرصيد (اختياري)
  final Widget? balanceHeader;

  const CustomAppBar({
    super.key,
    required this.onDrawerPressed,
    this.drawerIcon = Icons.menu_rounded,
    this.drawerTooltip = 'القائمة',
    required this.profileWidget,
    required this.welcomeText,
    this.emailText,
    this.onActionPressed,
    this.actionIcon = Icons.cloud_sync_rounded, // القيمة الافتراضية
    this.actionTooltip = 'إجراء',
    this.isActionLoading = false,
    this.balanceHeader, // إذا تم تمرير null، سيختفي هذا القسم تماماً
  });

  @override
  Widget build(BuildContext context) {
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
            Padding(
              padding: const EdgeInsets.fromLTRB(6, 6, 16, 6),
              child: Row(
                children: [
                  // --- الزر الأيمن (قائمة أو رجوع) ---
                  IconButton(
                    onPressed: onDrawerPressed,
                    icon: Icon(
                      drawerIcon,
                      color: Colors.white,
                      size: 26,
                    ),
                    tooltip: drawerTooltip,
                  ),

                  // --- صورة / أيقونة المستخدم أو العميل ---
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primaryLight.withOpacity(0.5),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(child: profileWidget),
                  ),

                  const SizedBox(width: 10),

                  // --- النصوص (الاسم والبريد/الوصف) ---
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          welcomeText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (emailText != null && emailText!.isNotEmpty)
                          Text(
                            emailText!,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.65),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),

                  // --- زر الإجراء الأيسر (مزامنة/مشاركة) ---
                  if (onActionPressed != null) // يعرض فقط إذا مررت دالة
                    IconButton(
                      onPressed: isActionLoading ? null : onActionPressed,
                      icon: isActionLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Icon(actionIcon, color: Colors.white, size: 22),
                      tooltip: actionTooltip,
                    ),
                ],
              ),
            ),

            // --- ويدجت الرصيد (يُعرض فقط إذا تم تمريره) ---
            if (balanceHeader != null)
              Padding(
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
                  child: balanceHeader!,
                ),
              ),
          ],
        ),
      ),
    );
  }
}