import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/omni_button.dart';
import '../../../../shared/widgets/omni_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/utils/omni_toast.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onRegisterPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthRegisterRequested(
              _emailController.text.trim(),
              _passwordController.text,
              _displayNameController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDesktop = MediaQuery.of(context).size.width >= 800;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.surface,
              colorScheme.primaryContainer.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              OmniToast.showError(context, state.message);
            }
          },
          child: isDesktop
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildForm(context, colorScheme, textTheme, isDesktop),
                    const SizedBox(width: 80),
                    _buildBranding(colorScheme, textTheme),
                  ],
                )
              : Center(
                  child: _buildForm(context, colorScheme, textTheme, isDesktop),
                ),
        ),
      ),
    );
  }

  Widget _buildBranding(ColorScheme colorScheme, TextTheme textTheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.all_inclusive_rounded, size: 80, color: colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          'OmniLink',
          style: textTheme.displayMedium?.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: -1.2,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 400,
          child: Text(
            'Your digital universe, seamlessly connected. Organize with tags, sync across devices, and share files instantly.',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForm(BuildContext context, ColorScheme colorScheme, TextTheme textTheme, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 450),
        decoration: isDesktop
            ? BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
                border: Border.all(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                ),
              )
            : null,
        padding: EdgeInsets.all(isDesktop ? 32.0 : 0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isDesktop) ...[
                Icon(Icons.all_inclusive_rounded, size: 64, color: colorScheme.primary),
                const SizedBox(height: 24),
                Text(
                  'OmniLink',
                  style: textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.2,
                    color: colorScheme.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Your digital universe, seamlessly connected.',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
              ],
                          Text(
                            isDesktop ? 'CREATE YOUR ACCOUNT' : 'Start building your timeline',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: isDesktop ? 1.2 : 0,
                            ),
                            textAlign: isDesktop ? TextAlign.left : TextAlign.center,
                          ),
                          const SizedBox(height: 32),
                          OmniTextField(
                            controller: _displayNameController,
                            labelText: 'Display Name',
                            prefixIcon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your display name';
                              }
                              if (!RegExp(r'^[a-zA-Z0-9 ]+$').hasMatch(value)) {
                                return 'Only letters, numbers, and spaces are allowed';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          OmniTextField(
                            controller: _emailController,
                            labelText: 'Email',
                            prefixIcon: Icons.email,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          OmniTextField(
                            controller: _passwordController,
                            labelText: 'Password',
                            prefixIcon: Icons.lock,
                            isPassword: true,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a password';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters long';
                              }
                              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*\d).+$').hasMatch(value)) {
                                return 'Password must contain at least one letter and one number';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              BlocBuilder<AuthBloc, AuthState>(
                                builder: (context, state) {
                                  return OmniButton.primary(
                                    text: 'Register',
                                    onPressed: _onRegisterPressed,
                                    isLoading: state is AuthLoading,
                                  );
                                },
                              ),
                            ],
                          ),
                          if (isDesktop) ...[
                            const SizedBox(height: 24),
                            Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "ALREADY HAVE AN ACCOUNT?",
                                        style: textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Log in to your dashboard.",
                                        style: textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                OmniButton.outlined(
                                  text: 'Log In',
                                  onPressed: () => context.go('/login'),
                                ),
                              ],
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            OmniButton.text(
                              text: 'Already have an account? Login',
                              onPressed: () => context.go('/login'),
                              isFullWidth: true,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
    );
  }
}
