import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../shared/widgets/omni_text_field.dart';
import '../../../../shared/widgets/omni_button.dart';
import '../../../../shared/widgets/omni_glass_container.dart';
import '../../../../shared/utils/omni_toast.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _secretKeyController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleAdminLogin() async {
    if (_emailController.text.isEmpty || 
        _passwordController.text.isEmpty || 
        _secretKeyController.text.isEmpty) {
      OmniToast.showError(context, 'All fields are required');
      return;
    }

    setState(() => _isLoading = true);

    context.read<AuthBloc>().add(AuthAdminLoginRequested(
      _emailController.text,
      _passwordController.text,
      _secretKeyController.text,
    ));
    
    // UI state loading is handled by BlocConsumer below
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _secretKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      body: Stack(
        children: [
          // Background subtle pattern or gradient could go here
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: 450,
                child: OmniGlassContainer(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 64,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Admin Portal',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Secure Access Only',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      OmniTextField(
                        controller: _emailController,
                        hintText: 'Admin Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      OmniTextField(
                        controller: _passwordController,
                        hintText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        isPassword: true,
                      ),
                      const SizedBox(height: 16),
                      OmniTextField(
                        controller: _secretKeyController,
                        hintText: 'Admin Secret Key',
                        prefixIcon: Icons.key_outlined,
                        isPassword: true,
                      ),
                      const SizedBox(height: 40),
                      BlocConsumer<AuthBloc, AuthState>(
                        listener: (context, state) {
                          if (state is AuthAuthenticated) {
                            context.go('/admin/dashboard');
                          } else if (state is AuthError) {
                            setState(() => _isLoading = false);
                            OmniToast.showError(context, state.message);
                          }
                        },
                        builder: (context, state) {
                          if (state is AuthLoading) {
                            _isLoading = true;
                          } else {
                            _isLoading = false;
                          }
                          return OmniButton(
                            text: 'Authenticate',
                            onPressed: _isLoading ? null : _handleAdminLogin,
                            isLoading: _isLoading,
                            icon: Icons.login_rounded,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
