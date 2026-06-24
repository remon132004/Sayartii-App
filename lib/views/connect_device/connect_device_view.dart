import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/views/connect_device/bluetooth.dart';
import 'package:sayartii/views/connect_device/cubit/connect_device_cubit.dart';
import 'package:sayartii/views/connect_device/wifi.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/custon_choice_chip.dart';

class ConnectDeviceView extends StatefulWidget {
  const ConnectDeviceView({super.key});

  @override
  State<ConnectDeviceView> createState() => _ConnectDeviceViewState();
}

class _ConnectDeviceViewState extends State<ConnectDeviceView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      appBar: AppBar(
        backgroundColor: kPrimaryBackGroundColor,
        foregroundColor: kPrimaryDarkColor,
        elevation: 0,
        centerTitle: true,
        title: Text(
          AppLocalizations.of(context)!.connectivity,
          style: TextStyle(
            color: kPrimaryDarkColor,
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const CustomChoiceChip(),
                BlocBuilder<ConnectDeviceCubit, ConnectDeviceState>(
                  builder: (context, state) {
                    if (state is ConnectDeviceWifiState) {
                      return const WiFi();
                    } else {
                      return const Bluetooth();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
