import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/initialize_car_data.dart';

class PredictedCodeDescription extends StatelessWidget {
  const PredictedCodeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // Parse the AI Response
    final rawAiResponse = predictedCodesList?.openAiResponse ?? '{}';
    Map<String, dynamic> aiData = {};
    try {
      aiData = jsonDecode(rawAiResponse);
    } catch (e) {
      aiData = {};
    }

    final String dtcCode = aiData['dtc_code']?.toString() ?? predictedCodesList?.troubleCode ?? (isAr ? 'غير معروف' : 'Unknown');
    final String criticalLevel = aiData['critical_level']?.toString() ?? 'Medium';
    final String shortDesc = aiData['description']?.toString() ?? predictedCodesList?.prediction ?? (isAr ? 'جاري تحليل العطل...' : 'Analyzing fault...');
    final String longDesc = aiData['long_description']?.toString() ?? rawAiResponse;
    final String drivingAdvice = aiData['driving_advice']?.toString() ?? '';
    
    final List<dynamic> reasons = aiData['reason'] is List ? aiData['reason'] : [];
    final List<dynamic> repairs = aiData['repair'] is List ? aiData['repair'] : [];

    // Map critical level to color and localized text
    Color levelColor = kAccentColor;
    String levelLabel = isAr ? 'متوسط' : 'Medium';
    if (criticalLevel.toLowerCase().contains('high')) {
      levelColor = kDangerColor;
      levelLabel = isAr ? 'خطير (عالي)' : 'High';
    } else if (criticalLevel.toLowerCase().contains('low')) {
      levelColor = kSuccessColor;
      levelLabel = isAr ? 'بسيط (منخفض)' : 'Low';
    } else if (criticalLevel.toLowerCase().contains('medium')) {
      levelColor = const Color(0xFFF59E0B);
      levelLabel = isAr ? 'متوسط' : 'Medium';
    }

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: Text(
          isAr ? 'تقرير التشخيص الذكي' : 'AI Diagnostic Report',
          style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // 1. Header Card (DTC & Level)
              _buildHeaderCard(dtcCode, shortDesc, levelLabel, levelColor),

              // 1.5 AI Stats bar (confidence + estimated time)
              _buildStatsBar(isAr),

              // 2. Long Description
              if (longDesc.isNotEmpty && longDesc != '{}')
                _buildSectionCard(
                  isAr ? 'شرح العطل الميكانيكي' : 'Fault Description',
                  longDesc, Icons.info_outline, kAccentColor),

              // 2.5 Driving Advice
              if (drivingAdvice.isNotEmpty)
                _buildSectionCard(
                  isAr ? 'نصيحة القيادة' : 'Driving Advice',
                  drivingAdvice, Icons.drive_eta_rounded, const Color(0xFFEF4444)),

              // 3. Reasons
              if (reasons.isNotEmpty)
                _buildListCard(
                  isAr ? 'الأسباب المحتملة' : 'Possible Causes',
                  reasons, Icons.build_circle_outlined, const Color(0xFFF59E0B)),

              // 4. Repairs
              if (repairs.isNotEmpty)
                _buildListCard(
                  isAr ? 'خطوات الإصلاح المقترحة' : 'Suggested Repairs',
                  repairs, Icons.verified_outlined, kSuccessColor),

            ],
          ),
        ),
      ),

    );
  }

  Widget _buildStatsBar(bool isAr) {
    final confidence = predictedCodesList?.confidencePercent ?? '';
    final hrs        = predictedCodesList?.estimatedTimeRemaining;
    if (confidence.isEmpty && (hrs == null || hrs <= 0)) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kAccentSofter,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kAccentSoft),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (confidence.isNotEmpty) ...[
            _StatChip(
              icon: Icons.psychology_rounded,
              label: isAr ? 'ثقة الذكاء الاصطناعي' : 'AI Confidence',
              value: confidence,
              color: kAccentColor,
            ),
          ],
          if (confidence.isNotEmpty && hrs != null && hrs > 0)
            Container(width: 1, height: 40, color: kBorderColor),
          if (hrs != null && hrs > 0) ...[
            _StatChip(
              icon: Icons.timer_outlined,
              label: isAr ? 'وقت الفشل المتوقع' : 'Est. Time to Failure',
              value: '${hrs.toStringAsFixed(1)} ${isAr ? "ساعة" : "hrs"}',
              color: kWarningColor,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeaderCard(String code, String desc, String levelAr, Color levelColor) {

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kDividerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  "كود: $code",
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kPrimaryDarkColor),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: levelColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      levelAr,
                      style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: levelColor),
                    ),
                  ],
                ),
              )
            ],
          ),
          const SizedBox(height: 16),
          Text(
            desc,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: kPrimaryDarkColor, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(String title, String body, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kPrimaryDarkColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kSecondaryTextColor, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(String title, List<dynamic> items, IconData icon, Color iconColor) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kPrimaryDarkColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Icon(Icons.circle, size: 8, color: iconColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item.toString(),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: kSecondaryTextColor, height: 1.5),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ─── Stat Chip ─────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip({required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(value,
                style: TextStyle(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(
              color: kSecondaryTextColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            )),
      ],
    );
  }
}
