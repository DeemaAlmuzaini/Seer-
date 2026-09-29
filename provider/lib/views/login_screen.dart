import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';

import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../theme/app_colors.dart';
import 'provider_registration_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.authService});
  final AuthService? authService;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late final _authService = widget.authService ?? AuthService();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _logIn() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _authService.logIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
    } on AuthException catch (error) {
      _showMessage(error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage('اكتب بريدك الإلكتروني أولاً.');
      return;
    }
    try {
      await _authService.sendPasswordResetEmail(email);
      _showMessage('تم إرسال رابط إعادة تعيين كلمة المرور.');
    } on AuthException catch (error) {
      _showMessage(error.message);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_outlined,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'سير لمزودي الخدمة',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  'سجّل دخول ${AppConfig.roleLabel}',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'سجّل الدخول لمتابعة طلبات الخدمة الخاصة بك.',
                  style: TextStyle(fontSize: 12, color: AppColors.secondaryText),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    if (email.isEmpty) return 'أدخل البريد الإلكتروني';
                    if (!email.contains('@') || !email.contains('.')) {
                      return 'صيغة البريد الإلكتروني غير صحيحة';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textDirection: TextDirection.ltr,
                  decoration: InputDecoration(
                    labelText: 'كلمة المرور',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'أدخل كلمة المرور';
                    }
                    if (value.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: const Text('نسيت كلمة المرور؟'),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _loading ? null : _logIn,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: Colors.white,
                          ),
                        )
                      : const Text('تسجيل الدخول'),
                ),
                const SizedBox(height: 12),
                Center(
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          color: AppColors.secondaryText, fontSize: 12),
                      children: [
                        const TextSpan(text: 'مزود خدمة جديد؟ '),
                        TextSpan(
                          text: 'سجّل الآن',
                          style: const TextStyle(
                            color: AppColors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          recognizer: (TapGestureRecognizer()
                            ..onTap = _loading
                                ? null
                                : () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            ProviderRegistrationScreen(
                                          authService: _authService,
                                        ),
                                      ),
                                    )),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
