import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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
  String ipAddress = '';
  String port = '';
  final ipController = TextEditingController();
  final portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTextFieldValue();
  }

  @override
  void dispose() {
    ipController.dispose();
    portController.dispose();
    super.dispose();
  }

  Future<void> _loadTextFieldValue() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      ipController.text = prefs.getString('ipValue') ?? '';
      portController.text = prefs.getString('portValue') ?? '';
    }
  }

  Future<void> _saveTextFieldValue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('ipValue', ipController.text.trim());
    await prefs.setString('portValue', portController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAr = Localizations.localeOf(context).languageCode == 'ar';

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          fieldLabel('IP Address'),
          _inputField(
            controller: ipController,
            hint: '192.168.0.10',
            icon: Icons.wifi_rounded,
            validator: validateIpAddress,
            onSaved: (v) => ipAddress = v ?? '',
          ),
          const SizedBox(height: 8),
          fieldLabel('Port'),
          _inputField(
            controller: portController,
            hint: '35000',
            icon: Icons.settings_ethernet_rounded,
            validator: validatePort,
            onSaved: (v) => port = v ?? '',
          ),
          SizedBox(height: 20.h),
          CustomButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                await _saveTextFieldValue();
                if (!mounted) return;
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext ctx) {
                    return FutureBuilder<Socket>(
                      future: connectToServer(
                        ip: ipController.text.trim(),
                        port: int.parse(portController.text.trim()),
                      ),
                      builder: (ctx2, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return AlertDialog(
                            backgroundColor: kSurface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            content: const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(color: kAccentColor),
                                  SizedBox(height: 16),
                                  Text('Connecting…',
                                      style: TextStyle(color: kSecondaryTextColor)),
                                ],
                              ),
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return AlertDialog(
                            backgroundColor: kSurface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Row(
                              children: [
                                Icon(Icons.error_outline_rounded, color: kDangerColor),
                                SizedBox(width: 8),
                                Text('Connection Failed',
                                    style: TextStyle(color: kDangerColor, fontSize: 16)),
                              ],
                            ),
                            content: Text('${snapshot.error}',
                                style: const TextStyle(color: kSecondaryTextColor)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx2),
                                child: const Text('OK', style: TextStyle(color: kAccentColor)),
                              ),
                            ],
                          );
                        } else {
                          final dataCubit = BlocProvider.of<DataCubit>(ctx2);
                          reciveData(dataCubit);
                          return AlertDialog(
                            backgroundColor: kSurface,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            title: const Row(
                              children: [
                                Icon(Icons.check_circle_rounded, color: kSuccessColor),
                                SizedBox(width: 8),
                                Text('Connected!',
                                    style: TextStyle(color: kSuccessColor, fontSize: 16)),
                              ],
                            ),
                            content: const Text('WiFi OBD2 connection established.',
                                style: TextStyle(color: kSecondaryTextColor)),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx2),
                                child: const Text('Done', style: TextStyle(color: kAccentColor)),
                              ),
                            ],
                          );
                        }
                      },
                    );
                  },
                );
              }
            },
            title: isAr ? 'اتصال' : 'Connect',
            color: kPrimaryBlueColor,
            width: 90,
          ),
        ],
      ),
    );
  }

  Widget fieldLabel(String label) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                color: kSecondaryTextColor,
                letterSpacing: 0.5)),
      );

  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?)? validator,
    required Function(String?)? onSaved,
  }) {
    return TextFormField(
      validator: validator,
      controller: controller,
      onSaved: onSaved,
      onChanged: onSaved,
      keyboardType: TextInputType.number,
      cursorColor: kAccentColor,
      style: const TextStyle(color: kPrimaryDarkColor, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: kSubtleText.withValues(alpha: 0.6), fontSize: 13),
        prefixIcon: Icon(icon, color: kAccentColor, size: 18),
        filled: true,
        fillColor: kAccentSofter,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kBorderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: kBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kAccentColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: kDangerColor),
        ),
      ),
    );
  }
}
