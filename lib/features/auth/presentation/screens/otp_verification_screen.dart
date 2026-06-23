// FILE: lib/features/auth/presentation/screens/otp_verification_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_sizes.dart';
import '../providers/auth_provider.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  final String email;

  const OtpVerificationScreen({super.key, required this.email});

  @override
  ConsumerState<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      try {
        final code = _codeController.text.trim();
        await ref.read(authStateProvider.notifier).verifyOtpCode(
              email: widget.email,
              token: code,
            );
        // The router redirect guard will automatically navigate to /conversations on auth status change!
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Verification failed: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.p24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: AppSizes.p24),
                Text(
                  'Enter Code',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: AppSizes.p8),
                Text(
                  'We sent a 6-digit code to:\n${widget.email}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: AppSizes.p32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 24, letterSpacing: 8, fontWeight: FontWeight.bold),
                  decoration: const InputDecoration(
                    labelText: '6-Digit Code',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(AppSizes.r12)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the code';
                    }
                    if (value.length < 6) {
                      return 'Code must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSizes.p24),
                ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: AppSizes.p16),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppSizes.r12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Text(
                          'Verify & Login',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
