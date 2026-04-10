import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../logic/auth_controller.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();
  bool isSignUp = false;
  bool otpStepTwo = false;
  String otpEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Card(
            margin: const EdgeInsets.all(24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'OpenMouse',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Apple-inspirierter Login mit Supabase'),
                  const SizedBox(height: 24),
                  if (!otpStepTwo) ...[
                    CupertinoTextField(
                      controller: _emailController,
                      placeholder: 'E-Mail',
                    ),
                    const SizedBox(height: 12),
                    if (!otpMode)
                      CupertinoTextField(
                        controller: _passwordController,
                        placeholder: 'Passwort',
                        obscureText: true,
                      ),
                    const SizedBox(height: 16),
                    if (otpMode)
                      CupertinoButton.filled(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                otpEmail = _emailController.text.trim();
                                await auth.sendOtp(otpEmail);
                                if (auth.error == null && mounted) {
                                  setState(() => otpStepTwo = true);
                                }
                              },
                        child: const Text('Code senden'),
                      )
                    else
                      CupertinoButton.filled(
                        onPressed: auth.isLoading
                            ? null
                            : () async {
                                if (isSignUp) {
                                  await auth.signUp(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                } else {
                                  await auth.signIn(
                                    _emailController.text.trim(),
                                    _passwordController.text.trim(),
                                  );
                                }
                              },
                        child: Text(isSignUp ? 'Registrieren' : 'Einloggen'),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        TextButton(
                          onPressed: () => setState(() {
                            isSignUp = !isSignUp;
                            otpMode = false;
                          }),
                          child: Text(
                            isSignUp
                                ? 'Zum Login wechseln'
                                : 'Neuen Account erstellen',
                          ),
                        ),
                        TextButton(
                          onPressed: () => setState(() {
                            otpMode = !otpMode;
                            isSignUp = false;
                          }),
                          child: const Text('Passwort vergessen (OTP)'),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text('Code wurde gesendet an: $otpEmail'),
                    const SizedBox(height: 12),
                    CupertinoTextField(
                      controller: _otpController,
                      placeholder: 'OTP Code',
                    ),
                    const SizedBox(height: 16),
                    CupertinoButton.filled(
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              await auth.verifyOtp(
                                otpEmail,
                                _otpController.text.trim(),
                              );
                            },
                      child: const Text('Einloggen'),
                    ),
                    TextButton(
                      onPressed: () => setState(() {
                        otpStepTwo = false;
                        _otpController.clear();
                      }),
                      child: const Text('Zurück'),
                    ),
                  ],
                  if (auth.error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      auth.error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool otpMode = false;
}
