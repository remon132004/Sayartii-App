import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/initialize_car_data.dart';

class PredictedCodeDescription extends StatelessWidget {
  const PredictedCodeDescription({super.key});

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    // ── Parse the AI Response ──────────────────────────────────────────────────
    final rawAiResponse = predictedCodesList?.openAiResponse;
    Map<String, dynamic> aiData = {};
    try {
      if (rawAiResponse is Map) {
        aiData = Map<String, dynamic>.from(rawAiResponse);
      } else if (rawAiResponse is String && rawAiResponse.isNotEmpty && rawAiResponse != '{}') {
        aiData = jsonDecode(rawAiResponse) as Map<String, dynamic>;
      }
    } catch (_) {
      aiData = {};
    }

    // ── Helpers: pick Arabic or English field ──────────────────────────────────
    String pick(String key) {
      final arKey = '${key}_ar';
      final enKey = '${key}_en';
      // New bilingual format
      if (aiData.containsKey(arKey) || aiData.containsKey(enKey)) {
        return isAr
            ? (aiData[arKey]?.toString() ?? aiData[enKey]?.toString() ?? '')
            : (aiData[enKey]?.toString() ?? aiData[arKey]?.toString() ?? '');
      }
      // Legacy single-language format (backward-compatible)
      return aiData[key]?.toString() ?? '';
    }

    List<dynamic> pickList(String key) {
      final arKey = '${key}_ar';
      final enKey = '${key}_en';
      if (aiData.containsKey(arKey) || aiData.containsKey(enKey)) {
        final chosen = isAr ? aiData[arKey] : aiData[enKey];
        if (chosen is List) return chosen;
        final other = isAr ? aiData[enKey] : aiData[arKey];
        if (other is List) return other;
        return [];
      }
      // Legacy
      return aiData[key] is List ? aiData[key] as List : [];
    }

    // ── Field values ───────────────────────────────────────────────────────────
    final String dtcCode = aiData['dtc_code']?.toString()
        ?? predictedCodesList?.troubleCode
        ?? (isAr ? 'غير معروف' : 'Unknown');

    final String criticalLevel = aiData['critical_level']?.toString() ?? 'Medium';

    final String shortDesc = pick('description').isNotEmpty
        ? pick('description')
        : (predictedCodesList?.prediction ?? (isAr ? 'جاري تحليل العطل...' : 'Analyzing fault...'));

    final String longDesc    = pick('long_description');
    final String drivingAdvice = pick('driving_advice');
    final List<dynamic> reasons = pickList('reason');
    final List<dynamic> repairs = pickList('repair');

    // ── Critical level → color + label ────────────────────────────────────────
    Color levelColor = kAccentColor;
    String levelLabel = isAr ? 'متوسط' : 'Medium';
    if (criticalLevel.toLowerCase().contains('high')) {
      levelColor = kDangerColor;
      levelLabel = isAr ? 'خطير' : 'High';
    } else if (criticalLevel.toLowerCase().contains('low')) {
      levelColor = kSuccessColor;
      levelLabel = isAr ? 'بسيط' : 'Low';
    } else {
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
          style: const TextStyle(
              color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
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
              // 1. Header Card (DTC code & critical level)
              _buildHeaderCard(dtcCode, shortDesc, levelLabel, levelColor, isAr),

              // 2. AI Confidence + Est. time stats bar
              _buildStatsBar(isAr),

              // 3. Fault description (long)
              if (longDesc.isNotEmpty)
                _buildSectionCard(
                  isAr ? 'شرح العطل الميكانيكي' : 'Fault Description',
                  longDesc,
                  Icons.info_outline,
                  kAccentColor,
                ),

              // 4. Driving advice
              if (drivingAdvice.isNotEmpty)
                _buildSectionCard(
                  isAr ? 'نصيحة القيادة' : 'Driving Advice',
                  drivingAdvice,
                  Icons.drive_eta_rounded,
                  const Color(0xFFEF4444),
                ),

              // 5. Possible causes
              if (reasons.isNotEmpty)
                _buildListCard(
                  isAr ? 'الأسباب المحتملة' : 'Possible Causes',
                  reasons,
                  Icons.build_circle_outlined,
                  const Color(0xFFF59E0B),
                ),

              // 6. Suggested repairs
              if (repairs.isNotEmpty)
                _buildListCard(
                  isAr ? 'خطوات الإصلاح المقترحة' : 'Suggested Repairs',
                  repairs,
                  Icons.verified_outlined,
                  kSuccessColor,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Stats Bar ────────────────────────────────────────────────────────────────
  Widget _buildStatsBar(bool isAr) {
    final confidence = predictedCodesList?.confidencePercent ?? '';
    final hrs = predictedCodesList?.estimatedTimeRemaining;
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

  // ── Header Card ──────────────────────────────────────────────────────────────
  Widget _buildHeaderCard(
      String code, String desc, String levelLabel, Color levelColor, bool isAr) {
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
          // DTC badge  +  level badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // DTC code
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kDividerColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isAr ? 'كود: $code' : 'Code: $code',
                  style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      color: kPrimaryDarkColor),
                ),
              ),
              // Critical level
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: levelColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: levelColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      levelLabel,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: levelColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Short description
          Text(
            desc,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: kPrimaryDarkColor,
                height: 1.4),
          ),
        ],
      ),
    );
  }

  // ── Section Card (text body) ─────────────────────────────────────────────────
  Widget _buildSectionCard(
    String title,
    String body,
    IconData icon,
    Color iconColor,
  ) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: kPrimaryDarkColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: kSecondaryTextColor,
                height: 1.6),
          ),
        ],
      ),
    );
  }

  // ── List Card (bullet points) ────────────────────────────────────────────────
  Widget _buildListCard(
    String title,
    List<dynamic> items,
    IconData icon,
    Color iconColor,
  ) {
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
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: kPrimaryDarkColor),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bullet items
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
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: kSecondaryTextColor,
                            height: 1.5),
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

// ─── Stat Chip ────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatChip(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

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
