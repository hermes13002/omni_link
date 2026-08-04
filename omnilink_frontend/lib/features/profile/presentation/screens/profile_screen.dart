import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:omnilink_frontend/features/device/presentation/bloc/device_bloc.dart';
import '../../../../core/theme/theme_cubit.dart';
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
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.go('/'),
        ),
        title: Text(
          'Profile & Settings',
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Minimal Header
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: colorScheme.primaryContainer,
                            child: Text(
                              user.email[0].toUpperCase(),
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.displayName ?? 'No name provided',
                                  style: textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit_rounded, color: colorScheme.primary),
                            onPressed: () => _showEditNameDialog(context, user.displayName ?? ''),
                            style: IconButton.styleFrom(
                              backgroundColor: colorScheme.primaryContainer.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Stats Dashboard
                      _buildStatsDashboard(context),
                      const SizedBox(height: 48),

                      // Group 1: Organization
                      _buildSectionTitle(context, 'Organization'),
                      const SizedBox(height: 12),
                      OmniGlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.label_rounded, color: colorScheme.primary),
                              title: const Text('Manage Tags'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push('/tags'),
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.devices_rounded, color: colorScheme.primary),
                              title: const Text('Linked Devices'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => context.push('/devices'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Group 2: Preferences
                      _buildSectionTitle(context, 'Preferences'),
                      const SizedBox(height: 12),
                      OmniGlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(vertical: 4),
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
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.lock_rounded, color: colorScheme.primary),
                              title: const Text('Change Password'),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () => _showChangePasswordDialog(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),

                      // Group 3: Danger Zone
                      OmniGlassContainer(
                        borderRadius: 16,
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(Icons.logout_rounded, color: colorScheme.onSurfaceVariant),
                              title: Text('Logout', style: TextStyle(color: colorScheme.onSurfaceVariant)),
                              onTap: () {
                                context.read<AuthBloc>().add(AuthLogoutRequested());
                              },
                            ),
                            const Divider(height: 1),
                            ListTile(
                              leading: Icon(Icons.delete_forever_rounded, color: colorScheme.error),
                              title: Text('Delete Account', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
                              onTap: () => _showDeleteAccountDialog(context),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
          letterSpacing: 1.2,
        ),
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
            onTap: () => context.push('/devices'),
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
