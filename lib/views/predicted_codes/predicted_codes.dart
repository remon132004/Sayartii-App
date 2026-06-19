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
    BlocProvider.of<PredictCodesCubit>(context).pageState();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        title: Text(
          AppLocalizations.of(context)!.predictedCodesTitle,
          style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: BlocBuilder<PredictCodesCubit, PredictCodesState>(
            builder: (context, state) {
              if (state is NoPrediction) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_outline, color: kAccentColor, size: 60),
                      const SizedBox(height: 16),
                      Text(
                        AppLocalizations.of(context)!.noIssuesDetected,
                        style: TextStyle(color: kSecondaryTextColor, fontSize: 13.sp),
                      ),
                    ],
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: predictedCodesList?.troubleCode != null ? 1 : 0,
                  itemBuilder: (context, index) {
                    return DtcCard(
                      title: predictedCodesList?.prediction ?? 'Unknown',
                      code: predictedCodesList?.troubleCode ?? 'None',
                      criticalLevel: "High",
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
              }
            },
          )),
    );
  }
}
