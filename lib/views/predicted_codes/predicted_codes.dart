import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.predictedCodesTitle),
        centerTitle: true,
      ),
      body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
          child: BlocBuilder<PredictCodesCubit, PredictCodesState>(
            builder: (context, state) {
              if (state is NoPrediction) {
                debugPrint(state.toString());
                return Center(
                  child: Text(AppLocalizations.of(context)!.noIssuesDetected),
                );
              } else {
                return ListView.builder(
                  itemCount: predictedCodesList?.troubleCode != null ? 1 : 0,
                  itemBuilder: (context, index) {
                    return DtcCard(
                      title: predictedCodesList?.prediction ?? 'Unknown',
                      code: predictedCodesList?.troubleCode ?? 'None',
                      criticalLevel: "High", // Fallback since it's missing from the new model
                      icon: GestureDetector(
                        child: SizedBox(
                            width: 5.w,
                            child: const Icon(Icons.arrow_forward_ios_rounded)),
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
