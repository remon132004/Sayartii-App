import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/predicted_codes/cubit/predict_codes_cubit.dart';
import 'package:sayartii/views/predicted_codes/predicted_code_description.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/dtc_card.dart';

class PredictedCodes extends StatefulWidget {
  const PredictedCodes({super.key});

  @override
  State<PredictedCodes> createState() => _PredictedCodesState();
}

class _PredictedCodesState extends State<PredictedCodes> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) BlocProvider.of<PredictCodesCubit>(context).pageState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: Text(
          l.predictedCodesTitle,
          style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
        child: BlocBuilder<PredictCodesCubit, PredictCodesState>(
          builder: (context, state) {

            // ── Loading ────────────────────────────────────────────────────────
            if (state is PredictCodesLoading) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: kAccentColor),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'جاري تحليل بيانات السيارة…' : 'Analyzing car data…',
                      style: TextStyle(color: kSecondaryTextColor, fontSize: 13.sp),
                    ),
                  ],
                ),
              );
            }

            // ── Error ──────────────────────────────────────────────────────────
            if (state is PredictCodesError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: kDangerColor.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.wifi_off_rounded,
                            color: kDangerColor, size: 34),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        isAr ? 'تعذّر الوصول للذكاء الاصطناعي' : 'AI Server Unavailable',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                          color: kPrimaryDarkColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isAr
                            ? 'تأكد من تشغيل خادم الـ AI والاتصال بالإنترنت، ثم حاول مجدداً.'
                            : 'Make sure the AI server is running and you have internet access.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: kSecondaryTextColor, fontSize: 13, height: 1.5),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () =>
                            BlocProvider.of<PredictCodesCubit>(context).pageState(),
                        icon: const Icon(Icons.refresh_rounded, size: 18),
                        label: Text(isAr ? 'إعادة المحاولة' : 'Try Again'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kAccentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 28, vertical: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(100)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            // ── No Problem ─────────────────────────────────────────────────────
            if (state is NoPrediction) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 80, height: 80,
                      decoration: BoxDecoration(
                        color: kSuccessColor.withValues(alpha: 0.08),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline_rounded,
                          color: kSuccessColor, size: 40),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAr ? 'لا توجد أعطال مكتشفة' : 'No Issues Detected',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: kPrimaryDarkColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'سيارتك في حالة جيدة! سيارتي تراقب بياناتها باستمرار.'
                          : 'Your car is in good shape! Sayartii is continuously monitoring it.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: kSecondaryTextColor, fontSize: 13, height: 1.5),
                    ),
                  ],
                ),
              );
            }

            // ── Problem Detected ───────────────────────────────────────────────
            final conf = predictedCodesList?.confidencePercent ?? '';
            final hrs  = predictedCodesList?.estimatedTimeRemaining;
            final subtitle = [
              if (conf.isNotEmpty) '🎯 $conf confidence',
              if (hrs != null && hrs > 0) '⏱ ${hrs.toStringAsFixed(1)} hrs to failure',
            ].join('  ·  ');

            return ListView.builder(
              itemCount: predictedCodesList?.troubleCode != null ? 1 : 0,
              itemBuilder: (context, index) {
                return DtcCard(
                  title: predictedCodesList?.prediction ?? 'Unknown',
                  code: predictedCodesList?.troubleCode ?? 'None',
                  criticalLevel: subtitle.isNotEmpty ? subtitle : 'High',
                  icon: GestureDetector(
                    child: SizedBox(
                        width: 5.w,
                        child: const Icon(Icons.arrow_forward_ios_rounded,
                            color: kAccentColor)),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const PredictedCodeDescription(),
                          ));
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
