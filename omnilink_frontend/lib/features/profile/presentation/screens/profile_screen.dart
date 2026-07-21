import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/widgets/omni_button.dart';
import '../../../../shared/widgets/omni_glass_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../device/presentation/bloc/device_bloc.dart';
import '../../../device/presentation/bloc/device_state.dart';
import '../../../timeline/presentation/bloc/timeline_bloc.dart';
import '../../../timeline/presentation/bloc/timeline_state.dart';
import '../../../../shared/utils/omni_toast.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          if (authState is AuthAuthenticated) {
            final user = authState.user;
            
            return CustomScrollView(
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
                        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
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
                                      colorScheme.primary.withAlpha(100),
                                      colorScheme.secondary.withAlpha(100),
                                      colorScheme.surface,
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
                            Text(
                              user.displayName ?? 'No name provided',
                              style: textTheme.headlineMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
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
                          icon: Icons.calendar_today,
                          label: 'Member Since',
                          value: '${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}',
                        ),
                        const SizedBox(height: 16),
                        _buildDetailItem(
                          context,
                          icon: Icons.security,
                          label: 'Account ID',
                          value: user.id.length > 10 ? '${user.id.substring(0, 10)}...' : user.id,
                        ),
                        const SizedBox(height: 48),
                        OmniButton.outlined(
                          text: 'Logout',
                          icon: Icons.logout,
                          isFullWidth: true,
                          onPressed: () {
                            context.read<AuthBloc>().add(AuthLogoutRequested());
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ],
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
          _buildStatColumn(
            context,
            icon: Icons.devices,
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
          Container(width: 1, height: 40, color: Theme.of(context).colorScheme.outlineVariant),
          _buildStatColumn(
            context,
            icon: Icons.content_paste,
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
            icon: Icons.storage,
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
}
