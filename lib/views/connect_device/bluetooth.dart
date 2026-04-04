import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    hide BluetoothState;
import 'package:sayartii/constants.dart';
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
  //final obd2 = Obd2Plugin();
  //List<BluetoothDevice>? devices;

  @override
  Widget build(BuildContext context) {
    var bloc = BlocProvider.of<BluetoothCubit>(context);

    return Column(
      children: [
        SizedBox(
          height: 3.h,
        ),
        BlocBuilder<BluetoothCubit, BluetoothState>(
          builder: (context, state) {
            return CustomButton(
              onPressed: () async {
                await bloc.bluetoothButton();
              },
              title: bloc.device != null
                  ? "Disconnect"
                  : "Search Bluetooth Devices",
              color: kPrimaryBlueColor,
              width: 70,
            );
          },
        ),
        SizedBox(
          height: 3.h,
        ),
        const Divider(
          color: Colors.black54,
          height: 0,
        ),
        SizedBox(
          height: 3.h,
        ),
        BlocConsumer<BluetoothCubit, BluetoothState>(
          listener: (context, state) {
            if (state is ShowBluetoothList) {
              showBluetoothList(context, state.devices);
            }
          },
          builder: (context, state) {
            if (state is WaitingForDevices) {
              return const CircularProgressIndicator();
            }
            if (state is BluetoothOn) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    bloc.device!.name!,
                    style:
                        TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
                  ),
                  const Text(
                    "Connected",
                    style: TextStyle(color: Colors.green),
                  )
                ],
              );
            } else {
              return const Text("Unconnected");
            }
          },
        )
      ],
    );
  }
}

Future<void> showBluetoothList(
    BuildContext context, List<BluetoothDevice> devices) async {
  // List<BluetoothDevice> devices = await obd2plugin.getPairedDevices;
  if (ModalRoute.of(context)?.isCurrent ?? false) {
    // Check if the current context is still mounted
    showModalBottomSheet(
        backgroundColor: kPrimaryBackGroundColor,
        context: context,
        builder: (builder) {
          return Container(
            padding: const EdgeInsets.only(top: 0),
            width: double.infinity,
            height: devices.length * 50,
            child: ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) {
                return SizedBox(
                  height: 50,
                  child: TextButton(
                    onPressed: () async {
                      DataCubit dataCubit = BlocProvider.of<DataCubit>(context);
                     PredictCodesCubit predictCodesCubit = BlocProvider.of<PredictCodesCubit>(context);
                      await BlocProvider.of<BluetoothCubit>(context)
                          .connectToDevice(index, dataCubit, predictCodesCubit);
                      Navigator.pop(builder);
                    },
                    child: Center(
                      child: Text(
                        devices[index].name.toString(),
                        style: const TextStyle(color: kPrimaryBlueColor),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        });
  }
}
