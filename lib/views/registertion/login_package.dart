import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sayartii/cubit/language_cubit.dart';
import 'package:sayartii/constants.dart';
import 'package:sayartii/utils/login_helper.dart';
import 'package:sayartii/views/nav_container.dart';
import 'package:sayartii/views/registertion/storeToken.dart';
import 'package:sayartii/views/registertion/apiData.dart';
import 'package:sayartii/l10n/app_localizations.dart';
import 'package:animate_do/animate_do.dart'; // Added animate_do

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isLogin = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  final _nameCtrl  = TextEditingController();
  final _carCtrl   = TextEditingController();
  final _yearCtrl  = TextEditingController();
  final _formKey   = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _nameCtrl.dispose();
    _carCtrl.dispose();
    _yearCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() { _isLogin = !_isLogin; _error = null; });
  }

  Future<void> _submit(AppLocalizations l) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_isLogin) {
        final res = await ApiService()
            .loginUser(_emailCtrl.text.trim(), _passCtrl.text, true);
        if (res.statusCode == 200) {
          await setAccessToken(res.data['token'] ?? 'demo_token');
          await Helper.saveUserLoggedInSharedPreference(true);
          if (mounted) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const NavContainer()));
          }
        } else {
          setState(() => _error = l.loginFailed);
        }
      } else {
        final res = await ApiService().signupUser(
          _emailCtrl.text.trim(), _passCtrl.text, _passCtrl.text,
          _nameCtrl.text.trim(), _carCtrl.text.trim(), _yearCtrl.text.trim(),
        );
        if (res.statusCode == 200) {
          setState(() { _isLogin = true; _error = null; });
          _showSuccess(l.accountCreated);
        } else {
          setState(() => _error = l.registrationFailed);
        }
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: kSuccessColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    // We add a unique key based on _isLogin to force the animations to replay when toggling!
    final formKeyUnique = ValueKey(_isLogin);

    return Scaffold(
      backgroundColor: kPrimaryBackGroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: BlocBuilder<LanguageCubit, Locale>(
                    builder: (ctx, loc) => GestureDetector(
                      onTap: () => ctx.read<LanguageCubit>().toggleLanguage(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: kAccentSofter,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: kAccentSoft),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded,
                                color: kAccentColor, size: 13),
                            const SizedBox(width: 5),
                            Text(
                              loc.languageCode == 'ar' ? 'EN' : 'AR',
                              style: const TextStyle(
                                  color: kAccentColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Logo with gradient ring ────────────────────────────
                ZoomIn(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: kAccentGradient,
                      boxShadow: [
                        BoxShadow(
                          color: kAccentColor.withValues(alpha: 0.3),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: kSurface,
                      ),
                      padding: const EdgeInsets.all(8),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/perfect_splash_icon_hq.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: const Text(
                    'SAYARTII',
                    style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w800,
                      color: kPrimaryDarkColor, letterSpacing: 4,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                FadeInDown(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    _isLogin ? l.welcomeBack : l.createAccountSub,
                    style: const TextStyle(color: kSecondaryTextColor, fontSize: 14),
                  ),
                ),

                const SizedBox(height: 36),

                // ─── Tab Toggle (pill style) ─────────────────────────────
                FadeInUp(
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    decoration: BoxDecoration(
                      color: kDividerColor,
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(color: kBorderColor),
                    ),
                    padding: const EdgeInsets.all(4),
                    child: Row(children: [
                      _Tab(label: l.loginTab,  active: _isLogin,  onTap: () { if (!_isLogin) _toggle(); }),
                      _Tab(label: l.signUpTab, active: !_isLogin, onTap: () { if (_isLogin)  _toggle(); }),
                    ]),
                  ),
                ),

                const SizedBox(height: 24),

                // ─── Fields Wrapped in Animation Keys ─────────────────────────────────────────────
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  child: Column(
                    key: formKeyUnique,
                    children: [
                      if (!_isLogin) ...[
                        FadeInUp(
                          delay: const Duration(milliseconds: 500),
                          child: _Field(ctrl: _nameCtrl, hint: l.fullName,
                              icon: Icons.person_outline_rounded,
                              validator: (v) => v!.isEmpty ? l.nameRequired : null),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 550),
                          child: _Field(ctrl: _carCtrl, hint: l.vehicleModel,
                              icon: Icons.directions_car_outlined,
                              validator: (v) => null),
                        ),
                        const SizedBox(height: 12),
                        FadeInUp(
                          delay: const Duration(milliseconds: 600),
                          child: _Field(ctrl: _yearCtrl, hint: l.modelYear,
                              icon: Icons.calendar_today_outlined,
                              keyboardType: TextInputType.number,
                              validator: (v) => null),
                        ),
                        const SizedBox(height: 12),
                      ],

                      FadeInUp(
                        delay: Duration(milliseconds: _isLogin ? 500 : 650),
                        child: _Field(
                          ctrl: _emailCtrl, hint: l.emailAddress,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) => v!.contains('@') ? null : l.enterValidEmail,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password
                      FadeInUp(
                        delay: Duration(milliseconds: _isLogin ? 600 : 700),
                        child: TextFormField(
                          controller: _passCtrl,
                          obscureText: _obscure,
                          validator: (v) => v!.length < 6 ? l.minSixChars : null,
                          style: const TextStyle(color: kPrimaryDarkColor, fontSize: 14),
                          decoration: InputDecoration(
                            hintText: l.password,
                            hintStyle: const TextStyle(color: kSubtleText),
                            prefixIcon: const Icon(Icons.lock_outline_rounded,
                                color: kSubtleText, size: 20),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscure = !_obscure),
                              icon: Icon(
                                _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: kSubtleText, size: 20,
                              ),
                            ),
                            filled: true, fillColor: kSurface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: kBorderColor)),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: kBorderColor)),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: kAccentColor, width: 2)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: kDangerColor)),
                          ),
                        ),
                      ),

                      if (_isLogin) ...[
                        const SizedBox(height: 4),
                        FadeInUp(
                          delay: const Duration(milliseconds: 700),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(l.forgotPassword,
                                  style: const TextStyle(
                                      color: kAccentColor, fontSize: 13,
                                      fontWeight: FontWeight.w600)),
                            ),
                          ),
                        ),
                      ] else const SizedBox(height: 16),
                    ],
                  ),
                ),

                // ─── Error ───────────────────────────────────────────────
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  ElasticIn(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: kDangerColor.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kDangerColor.withValues(alpha: 0.3)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.error_outline_rounded, color: kDangerColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!,
                            style: const TextStyle(color: kDangerColor, fontSize: 13))),
                      ]),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_error == null) const SizedBox(height: 24),

                // ─── Submit (pill shape + gradient) ──────────────────────
                FadeInUp(
                  delay: Duration(milliseconds: _isLogin ? 800 : 800),
                  child: SizedBox(
                    width: double.infinity, height: 54,
                    child: ElevatedButton(
                      onPressed: _loading ? null : () => _submit(l),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100)),
                        disabledBackgroundColor: kAccentSoft,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _loading ? null : kAccentGradient,
                          color: _loading ? kAccentSoft : null,
                          borderRadius: BorderRadius.circular(100),
                          boxShadow: _loading ? null : [
                            BoxShadow(
                              color: kAccentColor.withValues(alpha: 0.3),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          child: _loading
                              ? const SizedBox(height: 22, width: 22,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2.5, color: kAccentColor))
                              : Text(_isLogin ? l.loginBtn : l.createAccountBtn,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w700)),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                FadeInUp(
                  delay: Duration(milliseconds: _isLogin ? 900 : 900),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin ? l.noAccount : l.alreadyAccount,
                        style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
                      ),
                      GestureDetector(
                        onTap: _toggle,
                        child: Text(
                          _isLogin ? l.signUpTab : l.loginTab,
                          style: const TextStyle(
                            color: kAccentColor, fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Reusable text field ──────────────────────────────────────────────────────
class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  const _Field({required this.ctrl, required this.hint, required this.icon,
      this.keyboardType, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: kPrimaryDarkColor, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: kSubtleText),
        prefixIcon: Icon(icon, color: kSubtleText, size: 20),
        filled: true, fillColor: kSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kBorderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kAccentColor, width: 2)),
        errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kDangerColor)),
      ),
    );
  }
}

// ─── Tab button (pill style) ──────────────────────────────────────────────────
class _Tab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Tab({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: active ? kSurface : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
            boxShadow: active ? [BoxShadow(
              color: kAccentColor.withValues(alpha: 0.10),
              blurRadius: 12, offset: const Offset(0, 3),
            )] : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: active ? kAccentColor : kSubtleText,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}