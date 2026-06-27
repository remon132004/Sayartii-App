import 'package:flutter/material.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/views/in_depth_check_view.dart';
import 'package:sayartii/views/live_data_view.dart';
import 'package:sayartii/views/trouble_scan/trouble_scan.dart';
import 'package:sizer/sizer.dart';
import 'predicted_codes/predicted_codes.dart';

class AppCenterView extends StatelessWidget {
  const AppCenterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final bool isAr = Localizations.localeOf(context).languageCode == 'ar';

    final tools = [
      _Tool(label: l.liveData,        icon: Icons.show_chart_rounded,    color: kAccentColor,              dest: const LiveData()),
      _Tool(label: l.predictedIssues, icon: Icons.query_stats_rounded,   color: const Color(0xFF7C3AED),   dest: const PredictedCodes()),
      _Tool(label: l.inDepthCheck,    icon: Icons.manage_search_rounded, color: const Color(0xFF059669),   dest: const InDepthCheckView()),
      _Tool(label: l.troubleScan,     icon: Icons.build_circle_outlined, color: const Color(0xFFD97706),   dest: const TroubleScan()),
    ];

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Car image ────────────────────────────────────
                    Container(
                      height: 20.h,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [kAccentSofter, kSurface],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: kBorderColor),
                        boxShadow: [
                          BoxShadow(
                            color: kAccentColor.withValues(alpha: 0.07),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset('assets/images/center_car.png',
                            fit: BoxFit.contain),
                      ),
                    ),

                    const SizedBox(height: 28),

                    Align(
                      alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        l.myTools,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w800,
                            color: kPrimaryDarkColor,
                            letterSpacing: -0.3),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ─── 2×2 grid ─────────────────────────────────────
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.25,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                      ),
                      itemCount: tools.length,
                      itemBuilder: (_, i) => _ToolTile(tool: tools[i]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Tool {
  final String label;
  final IconData icon;
  final Color color;
  final Widget dest;
  const _Tool({required this.label, required this.icon, required this.color, required this.dest});
}

class _ToolTile extends StatelessWidget {
  final _Tool tool;
  const _ToolTile({required this.tool});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => tool.dest)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [kSurface, tool.color.withValues(alpha: 0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: tool.color.withValues(alpha: 0.15)),
          boxShadow: [
            BoxShadow(
              color: tool.color.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: tool.color.withValues(alpha: 0.2)),
              ),
              child: Icon(tool.icon, color: tool.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              tool.label,
              style: const TextStyle(
                  fontSize: 12.5, fontWeight: FontWeight.w700,
                  color: kPrimaryDarkColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
