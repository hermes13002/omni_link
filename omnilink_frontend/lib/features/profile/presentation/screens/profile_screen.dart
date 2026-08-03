import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omnilink_frontend/features/device/presentation/bloc/device_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';

import '../../../../shared/widgets/omni_button.dart';
import '../../../../shared/widgets/omni_glass_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import 'package:omnilink_frontend/shared/widgets/omni_glass_dialog.dart';
import '../../../device/presentation/bloc/device_state.dart';
import '../../../timeline/presentation/bloc/timeline_bloc.dart';
import '../../../timeline/presentation/bloc/timeline_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 300.0,
                  pinned: true,
                  backgroundColor: colorScheme.surface,
                  elevation: 0,
                  leading: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: colorScheme.surfaceContainerHighest.withAlpha(150),
                      child: IconButton(
                        icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
                        onPressed: () => context.go('/'),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Background Gradient and Glass effect wrapped in ShaderMask
                        ShaderMask(
                          shaderCallback: (rect) {
                            return const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black, Colors.black, Colors.transparent],
                              stops: [0.0, 0.6, 1.0],
                            ).createShader(rect);
                          },
                          blendMode: BlendMode.dstIn,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              // Background Gradient
                              Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.primaryContainer.withAlpha(150),
                                      colorScheme.tertiaryContainer.withAlpha(50),
                                    ],
                                  ),
                                ),
                              ),
                              // Glass effect overlay
                              Positioned.fill(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: Container(color: Colors.transparent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Avatar and name
                        Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Hero(
                              tag: 'profile_avatar',
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: colorScheme.primary.withAlpha(150), width: 3),
                                  boxShadow: [
                                    BoxShadow(
                                      color: colorScheme.primary.withAlpha(100),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  child: Text(
                                    user.email[0].toUpperCase(),
                                    style: textTheme.displayLarge?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  user.displayName ?? 'No name provided',
                                  style: textTheme.headlineMedium?.copyWith(
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.edit_rounded, color: colorScheme.primary, size: 20),
                                  onPressed: () => _showEditNameDialog(context, user.displayName ?? ''),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.email,
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsDashboard(context),
                        const SizedBox(height: 32),
                        Text(
                          'Account Details',
                          style: textTheme.headlineMedium?.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.calendar_today_rounded,
                          label: 'Member Since',
                          value: '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.person_rounded,
                          label: 'Account ID',
                          value: user.id.length > 10 ? '${user.id.substring(0, 10)}...' : user.id,
                        ),
                        const SizedBox(height: 32),
                        _buildSettingsSection(context, user),
                        const SizedBox(height: 48),
                        OmniButton.outlined(
                          text: 'Logout',
                          icon: Icons.logout_rounded,
                          isFullWidth: true,
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                        const SizedBox(height: 24),
                        OmniButton.outlined(
                          text: 'Delete Account',
                          icon: Icons.delete_forever_rounded,
                          isFullWidth: true,
                          onPressed: () => _showDeleteAccountDialog(context),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        }
        return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildStatsDashboard(BuildContext context) {
    return OmniGlassContainer(
      padding: const EdgeInsets.all(20),
      borderRadius: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          GestureDetector(
            onTap: () => context.push('/settings'),
            behavior: HitTestBehavior.opaque,
            child: _buildStatColumn(
              context,
              icon: Icons.devices_rounded,
              label: 'Devices',
              blocBuilder: BlocBuilder<DeviceBloc, DeviceState>(
                builder: (context, state) {
                  if (state is DevicesLoaded) {
                    return Text(
                      '${state.devices.length}',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                    );
                  }
                  return Text('-', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24));
                },
              ),
            ),
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outlineVariant),
          _buildStatColumn(
            context,
            icon: Icons.content_paste_rounded,
            label: 'Clips',
            blocBuilder: BlocBuilder<TimelineBloc, TimelineState>(
              builder: (context, state) {
                if (state is TimelineLoaded) {
                  return Text(
                    '${state.cards.length}',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  );
                }
                return Text('-', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24));
              },
            ),
          ),
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outlineVariant),
          _buildStatColumn(
            context,
            icon: Icons.cloud_rounded,
            label: 'Storage',
            blocBuilder: BlocBuilder<TimelineBloc, TimelineState>(
              builder: (context, state) {
                if (state is TimelineLoaded) {
                  int totalBytes = state.cards.fold(0, (sum, card) => sum + (card.fileSizeBytes ?? 0));
                  String sizeStr = totalBytes > 1024 * 1024 
                    ? '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB' 
                    : '${(totalBytes / 1024).round()} KB';
                  if (totalBytes == 0) sizeStr = '0 KB';
                  return Text(
                    sizeStr,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24),
                  );
                }
                return Text('-', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 24));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(BuildContext context, {required IconData icon, required String label, required Widget blocBuilder}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        blocBuilder,
        const SizedBox(height: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(BuildContext context, {required IconData icon, required String label, required String value}) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 20),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, user) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings & Preferences',
          style: textTheme.headlineMedium?.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        OmniGlassContainer(
          borderRadius: 16,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              BlocBuilder<ThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: themeMode == ThemeMode.dark,
                    onChanged: (_) {
                      context.read<ThemeCubit>().toggleTheme();
                    },
                    secondary: Icon(
                      themeMode == ThemeMode.dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: colorScheme.primary,
                    ),
                  );
                },
              ),
              /*
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.password_rounded, color: colorScheme.primary),
                title: const Text('Change Password'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => _showChangePasswordDialog(context),
              ),
              */
            ],
          ),
        ),
      ],
    );
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => OmniGlassDialog(
        title: const Text('Edit Display Name'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'New Display Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<AuthBloc>().add(AuthUpdateProfileRequested(controller.text.trim()));
              }
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => OmniGlassDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPasswordController,
              decoration: const InputDecoration(hintText: 'Old Password'),
              obscureText: true,
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPasswordController,
              decoration: const InputDecoration(hintText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              if (oldPasswordController.text.isNotEmpty && newPasswordController.text.isNotEmpty) {
                context.read<AuthBloc>().add(AuthChangePasswordRequested(
                  oldPasswordController.text, 
                  newPasswordController.text
                ));
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password changed successfully')),
                );
              }
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => OmniGlassDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and cannot be undone. All your clips, tags, and devices will be permanently deleted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            onPressed: () {
              context.read<AuthBloc>().add(AuthDeleteAccountRequested());
              Navigator.pop(ctx);
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }
}
