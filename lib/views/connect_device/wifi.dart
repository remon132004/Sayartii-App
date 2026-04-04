import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../constants.dart';
import '../../services/socket.dart';
import '../../utils/validators.dart';
import '../../widgets/custom_button.dart';
import '../home/cubit/data_cubit.dart';

class WiFi extends StatefulWidget {
  const WiFi({super.key});

  @override
  State<WiFi> createState() => _WiFiState();
}

class _WiFiState extends State<WiFi> {
 final _formKey = GlobalKey<FormState>();
  String ipAddress = "";
  String port = "";
  final ipController = TextEditingController();
  final portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTextFieldValue();
  }

  _loadTextFieldValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ipController.text = prefs.getString('ipValue') ?? '';
    portController.text = prefs.getString('portValue') ?? '';
  }

  _saveTextFieldValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('ipValue', ipController.text);
    prefs.setString('portValue', portController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          text("IP address"),
          textField(
            controller: ipController,
            validator: validateIpAddress,
            onsaved: (value) {
              ipAddress = value!;
            },
          ),
          text("Port"),
          textField(
            controller: portController,
            validator: validatePort,
            onsaved: (value) {
              port = value!;
            },
          ),
          SizedBox(
            height: 20.h,
          ),
          CustomButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _saveTextFieldValue();
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return FutureBuilder<Socket>(
                      future:
                          connectToServer(ip: ipController.text, port: int.parse(portController.text)),
                      builder: (BuildContext context,
                          AsyncSnapshot<Socket> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const AlertDialog(
                            content: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return AlertDialog(
                            content: Text('Error: ${snapshot.error}'),
                          );
                        } else {
                          DataCubit dataCubit = BlocProvider.of<DataCubit>(context);

                          reciveData(dataCubit);
                          
                          return const AlertDialog(
                            content: Text('Connected to the server'),
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
            title: "Connect",
            color: kPrimaryBlueColor,
            width: 90,
          ),
        ],
      ),
    );
  }

   Widget text(String lable) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          lable,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp),
        ),
      ),
    );
  }

    Widget textField(
      {required String? Function(String?)? validator,
      required Function(String?)? onsaved,
      required TextEditingController controller}) {
    return TextFormField(
      validator: validator,
      controller: controller,
      onChanged: onsaved,
      keyboardType: TextInputType.number,
      cursorColor: kPrimaryBlueColor,
      decoration: const InputDecoration(
          focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
        color: kPrimaryBlueColor,
      ))),
    );
  }
}