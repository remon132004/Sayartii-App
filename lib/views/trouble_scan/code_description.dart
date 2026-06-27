import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/models/dtc_code_model.dart';
import 'package:sayartii/widgets/dtc_card.dart';

class CodeDescription extends StatelessWidget {
  const CodeDescription({super.key, required this.codeDesc});
  final DtcCodeModel codeDesc;

  @override
  Widget build(BuildContext context) {
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        backgroundColor: kPrimaryBackGroundColor,
        appBar: AppBar(
          backgroundColor: kPrimaryBackGroundColor,
          foregroundColor: kPrimaryDarkColor,
          title: Text(
            isAr ? 'تقرير العطل' : 'Fault Report',
            style: const TextStyle(
                color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header card (code + critical level badge) ────────────────
              DtcCard(
                code: codeDesc.dtcCode ?? 'N/A',
                title: codeDesc.description ?? 'N/A',
                criticalLevel: isAr
                    ? _levelLabel(codeDesc.criticalLevel, isAr: true)
                    : _levelLabel(codeDesc.criticalLevel, isAr: false),
              ),

              const SizedBox(height: 8),

              // ── Long description ─────────────────────────────────────────
              if ((codeDesc.longDescription ?? '').isNotEmpty)
                _SectionCard(
                  title: isAr ? 'شرح العطل الميكانيكي' : 'Fault Description',
                  icon: Icons.info_outline,
                  iconColor: kAccentColor,
                  child: Text(
                    codeDesc.longDescription!,
                    style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                ),

              // ── Driving advice ───────────────────────────────────────────
              if ((codeDesc.drivingAdvice ?? '').isNotEmpty)
                _SectionCard(
                  title: isAr ? 'نصيحة القيادة' : 'Driving Advice',
                  icon: Icons.drive_eta_rounded,
                  iconColor: kDangerColor,
                  child: Text(
                    codeDesc.drivingAdvice!,
                    style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                ),

              // ── Reasons list ─────────────────────────────────────────────
              if ((codeDesc.reasonList ?? []).isNotEmpty)
                _SectionCard(
                  title: isAr ? 'الأسباب المحتملة' : 'Possible Causes',
                  icon: Icons.build_circle_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  child: _BulletList(
                      items: codeDesc.reasonList!,
                      color: const Color(0xFFF59E0B)),
                )
              else if ((codeDesc.reason).isNotEmpty)
                // Legacy fallback (comma-separated string)
                _SectionCard(
                  title: isAr ? 'الأسباب المحتملة' : 'Possible Causes',
                  icon: Icons.build_circle_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  child: Text(
                    codeDesc.reason,
                    style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                ),

              // ── Repair steps list ────────────────────────────────────────
              if ((codeDesc.repairList ?? []).isNotEmpty)
                _SectionCard(
                  title: isAr ? 'خطوات الإصلاح المقترحة' : 'Suggested Repairs',
                  icon: Icons.verified_outlined,
                  iconColor: kSuccessColor,
                  child: _BulletList(
                      items: codeDesc.repairList!, color: kSuccessColor),
                )
              else if ((codeDesc.repair).isNotEmpty)
                _SectionCard(
                  title: isAr ? 'خطوات الإصلاح المقترحة' : 'Suggested Repairs',
                  icon: Icons.verified_outlined,
                  iconColor: kSuccessColor,
                  child: Text(
                    codeDesc.repair,
                    style: const TextStyle(
                        fontSize: 13,
                        color: kSecondaryTextColor,
                        height: 1.6,
                        fontWeight: FontWeight.w500),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _levelLabel(String? level, {required bool isAr}) {
    final l = (level ?? '').toLowerCase();
    if (l.contains('high')) return isAr ? 'خطير' : 'High';
    if (l.contains('low'))  return isAr ? 'بسيط' : 'Low';
    return isAr ? 'متوسط' : 'Medium';
  }
}

// ─── Reusable Section Card ────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: kAccentColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: kPrimaryDarkColor),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

// ─── Bullet List ──────────────────────────────────────────────────────────────
class _BulletList extends StatelessWidget {
  final List<String> items;
  final Color color;
  const _BulletList({required this.items, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 5.5),
                      child: Icon(Icons.circle, size: 7, color: color),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                            fontSize: 13,
                            color: kSecondaryTextColor,
                            height: 1.5,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
