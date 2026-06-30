import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/initialize_car_data.dart';
import 'package:sayartii/views/connect_device/cubit/bluetooth_cubit.dart';
import 'package:sayartii/views/trouble_scan/cubit/trouble_scan_cubit.dart';
import 'package:sayartii/views/trouble_scan/dtc_details.dart';
import 'package:sayartii/widgets/custom_rec_buttom.dart';
import 'package:sizer/sizer.dart';
import 'package:sayartii/l10n/app_localizations.dart';

class TroubleScan extends StatefulWidget {
  const TroubleScan({super.key});
  @override
  State<TroubleScan> createState() => _TroubleScanState();
}

class _TroubleScanState extends State<TroubleScan> {
  bool buttonNav = false;
  bool buttonColor = false;

  @override
  Widget build(BuildContext context) {
    var troubleBloc = BlocProvider.of<TroubleScanCubit>(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        BlocProvider.of<BluetoothCubit>(context).send = true;
        BlocProvider.of<BluetoothCubit>(context).sendParameterRequiest(paramJSON);
        dtcCodes = [];
        BlocProvider.of<TroubleScanCubit>(context).initialState();
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kSurface,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.troubleScanningTitle,
          style: TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: kBorderColor),
        ),
        leading: BackButton(
          color: kPrimaryDarkColor,
          onPressed: () {
            BlocProvider.of<BluetoothCubit>(context).send = true;
            BlocProvider.of<BluetoothCubit>(context).sendParameterRequiest(paramJSON);
            dtcCodes = [];
            BlocProvider.of<TroubleScanCubit>(context).initialState();
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            // ─── Engine Icon ──────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Image.asset("assets/images/pngegg.png"),
            ),

            const SizedBox(height: 16),

            // ─── Scan Button ──────────────────────────────────────
            BlocConsumer<TroubleScanCubit, TroubleScanState>(
              listener: (context, state) {
                if (state is DtcResultPos || state is DtcResultNeg) {
                  buttonNav = true;
                }
              },
              builder: (context, state) {
                Color outerColor = state is DtcResultPos
                    ? const Color(0xffFF5C00)
                    : kAccentDark;
                Color inerColor = state is DtcResultPos
                    ? const Color(0xffFFD600)
                    : kAccentColor;

                // Live data loop pause/resume is handled in onTap, BackButton, and PopScope handlers
                // to avoid mutating state or launching background loops during the build phase.

                return CustomRecButton(
                  onTap: () {
                    // Validation: Must be connected to the car first!
                    if (BlocProvider.of<BluetoothCubit>(context).device == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            AppLocalizations.of(context)!.localeName == 'ar' 
                            ? 'يرجى الاتصال بالسيارة أولاً عبر البلوتوث لفحص الأعطال.' 
                            : 'Please connect to the car via Bluetooth to scan for DTCs.'
                          ),
                          backgroundColor: kDangerColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                        )
                      );
                      return;
                    }

                    if (buttonNav) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DtcDetailsScreen()));
                    } else {
                      final btCubit = BlocProvider.of<BluetoothCubit>(context);
                      btCubit.send = false;
                      dtcCodes = []; // Clear before new scan

                      Future.delayed(const Duration(milliseconds: 2000), () async {
                        // Send all 3 DTC commands (mode 03, 07, 0A)
                        await btCubit.sendDtcRequiest(dtcJSON);
                        // Extra wait for OBD2 response callbacks to populate dtcCodes
                        await Future.delayed(const Duration(milliseconds: 3000));
                        final isAr = AppLocalizations.of(context)!.localeName == 'ar';
                        troubleBloc.buttonPressed(isAr: isAr);
                        // Resume live data
                        btCubit.send = true;
                        btCubit.sendParameterRequiest(paramJSON);
                      });
                    }
                  },
                  outerColor: outerColor,
                  inerColor: inerColor,
                  child: Center(
                    child: state is RequistDtc
                        ? SizedBox(
                            height: 3.h,
                            child: Image.asset("assets/images/frogcarspin.gif"))
                        : state is DtcResultPos
                            ? Text(
                                AppLocalizations.of(context)!
                                    .dtcDetected(dtcCodes.length),
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12.sp,
                                  color: Colors.white,
                                ),
                              )
                            : state is DtcResultNeg
                                ? Text(
                                    AppLocalizations.of(context)!.noDtcDetected,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    AppLocalizations.of(context)!.scanDtcCodes,
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                  ),
                );
              },
            ),

            SizedBox(height: 4.h),

            // ─── Clear Button ─────────────────────────────────────
            GestureDetector(
              onTap: () {
                dtcCodes = [];
                BlocProvider.of<TroubleScanCubit>(context).dtcDetailsList = [];
                BlocProvider.of<TroubleScanCubit>(context).initialState();
                setState(() {
                  buttonNav = false;
                  buttonColor = false;
                });
              },
              child: Container(
                width: double.maxFinite,
                decoration: BoxDecoration(
                  color: kSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kAccentColor.withValues(alpha: 0.5), width: 1.5),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    AppLocalizations.of(context)!.clearDtcCodes,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                      color: kAccentColor,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
