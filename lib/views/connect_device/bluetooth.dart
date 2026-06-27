import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    hide BluetoothState;
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:sayartii/widgets/custom_button.dart';
import 'package:sizer/sizer.dart';

import '../home/cubit/data_cubit.dart';
import '../predicted_codes/cubit/predict_codes_cubit.dart';
import 'cubit/bluetooth_cubit.dart';

class Bluetooth extends StatefulWidget {
  const Bluetooth({super.key});

  @override
  State<Bluetooth> createState() => _BluetoothState();
}

class _BluetoothState extends State<Bluetooth> {


  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    var bloc = BlocProvider.of<BluetoothCubit>(context);

    return Column(
      children: [
        SizedBox(height: 3.h),
        BlocBuilder<BluetoothCubit, BluetoothState>(
          builder: (context, state) {
            return CustomButton(
              onPressed: () async {
                await bloc.bluetoothButton(context.read<DataCubit>());
              },
              title: bloc.device != null ? l.disconnect : l.searchBluetooth,
              color: kPrimaryBlueColor,
              width: 70,
            );
          },
        ),
        SizedBox(height: 3.h),
        const Divider(color: kBorderColor, height: 0),
        SizedBox(height: 3.h),
        BlocConsumer<BluetoothCubit, BluetoothState>(
          listener: (context, state) {
            if (state is ShowBluetoothList) {
              showBluetoothList(context, state.devices);
            }
            if (state is BluetoothError) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade800,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ));
            }
          },
          builder: (context, state) {
            if (state is WaitingForDevices || state is BluetoothConnecting) {
              return Column(
                children: [
                  CircularProgressIndicator(color: kAccentColor),
                  const SizedBox(height: 12),
                  Text(l.connecting,
                      style: TextStyle(
                          color: kSecondaryTextColor, fontSize: 12.sp)),
                ],
              );
            }
            if (state is BluetoothOn) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: glassDecoration(radius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      bloc.device!.name ?? 'Unknown Device',
                      style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: kPrimaryDarkColor),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        l.connected,
                        style: const TextStyle(
                            color: Colors.green,
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: glassDecoration(radius: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bluetooth_disabled,
                        color: kSecondaryTextColor, size: 18),
                    const SizedBox(width: 8),
                    Text(l.notConnected,
                        style: TextStyle(
                            color: kSecondaryTextColor, fontSize: 12.sp)),
                  ],
                ),
              );
            }
          },
        )
      ],
    );
  }
}

Future<void> showBluetoothList(
    BuildContext context, List<BluetoothDevice> devices) async {
  if (!(ModalRoute.of(context)?.isCurrent ?? false)) return;
  showModalBottomSheet(
    backgroundColor: kSurface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    context: context,
    builder: (sheetCtx) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: kBorderColor,
                  borderRadius: BorderRadius.circular(2),
                )),
            const SizedBox(height: 16),
            Builder(builder: (ctx) {
              final l = AppLocalizations.of(ctx);
              return Text(
                l?.searchBluetooth ?? 'Select Device',
                style: const TextStyle(
                  color: kPrimaryDarkColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              );
            }),
            const SizedBox(height: 8),
            const Divider(color: kBorderColor),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 320),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: devices.length,
                itemBuilder: (ctx, index) {
                  return ListTile(
                    leading: const Icon(Icons.bluetooth_rounded,
                        color: kAccentColor, size: 22),
                    title: Text(
                      devices[index].name ?? 'Unknown Device',
                      style: const TextStyle(
                          color: kPrimaryDarkColor,
                          fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      devices[index].address,
                      style: const TextStyle(
                          color: kSecondaryTextColor, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded,
                        color: kSecondaryTextColor),
                    onTap: () async {
                      // Capture cubits BEFORE the async gap
                      final btCubit = BlocProvider.of<BluetoothCubit>(ctx);
                      final dataCubit = BlocProvider.of<DataCubit>(ctx);
                      final predictCubit =
                          BlocProvider.of<PredictCodesCubit>(ctx);
                      Navigator.pop(sheetCtx);
                      await btCubit.connectToDevice(
                          index, dataCubit, predictCubit);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}
