import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/session/session_cubit.dart';
import '../../../../../core/session/session_state.dart';

class StaffDashboardPage extends StatelessWidget {
  const StaffDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primary.withOpacity(0.10),
              cs.primary.withOpacity(0.04),
              cs.background,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top bar
                Row(
                  children: [
                    _BrandPill(
                      title: 'Staff Dashboard',
                      icon: Icons.admin_panel_settings_rounded,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Back',
                      onPressed: () {
                        context.read<SessionCubit>().reset();
                        context.go('/role');
                      },
                      icon: Icon(Icons.logout_rounded, color: cs.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Header
                Text(
                  'Choose staff mode',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Switch between Teller and Manager modes.\nThis simulates role-based access.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: cs.onSurface.withOpacity(0.72),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 22),

                // Mode selector
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cs.surface.withOpacity(0.78),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: cs.onSurface.withOpacity(0.08)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.tune_rounded, color: cs.primary),
                          const SizedBox(width: 10),
                          Text(
                            'Act as',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            'Toggle',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: cs.onSurface.withOpacity(0.60),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      BlocBuilder<SessionCubit, SessionState>(
                        builder: (context, state) {
                          final isTeller = state.staffMode == StaffMode.teller;
                          final isManager = state.staffMode == StaffMode.manager;

                          return Column(
                            children: [
                              _ModeTile(
                                title: 'Teller',
                                subtitle:
                                'Open accounts, create transactions, search customers.',
                                icon: Icons.badge_rounded,
                                selected: isTeller,
                                accent: cs.primary,
                                onTap: () => context
                                    .read<SessionCubit>()
                                    .setStaffMode(StaffMode.teller),
                              ),
                              const SizedBox(height: 10),
                              _ModeTile(
                                title: 'Manager',
                                subtitle:
                                'Approve large transactions, generate reports, view audit logs.',
                                icon: Icons.verified_user_rounded,
                                selected: isManager,
                                accent: cs.secondary,
                                onTap: () => context
                                    .read<SessionCubit>()
                                    .setStaffMode(StaffMode.manager),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action buttons
                BlocBuilder<SessionCubit, SessionState>(
                  builder: (context, state) {
                    final canContinue = state.staffMode != null;

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton.icon(
                            onPressed: canContinue
                                ? () {
                              if (state.staffMode == StaffMode.teller) {
                                context.go('/staff/teller');
                              } else {
                                context.go('/staff/manager');
                              }
                            }
                                : null,
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text(
                              'Continue',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<SessionCubit>().reset();
                              context.go('/role');
                            },
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: const Text(
                              'Switch Role',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const Spacer(),

                // Footer hint
                Row(
                  children: [
                    Icon(Icons.security_rounded,
                        size: 18, color: cs.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Access control is simulated (no auth). Mode selection controls available screens.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: cs.onSurface.withOpacity(0.65),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BrandPill extends StatelessWidget {
  final String title;
  final IconData icon;

  const _BrandPill({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: cs.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  const _ModeTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected
                ? accent.withOpacity(0.10)
                : cs.surface.withOpacity(0.55),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? accent.withOpacity(0.35)
                  : cs.onSurface.withOpacity(0.08),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: selected
                      ? accent.withOpacity(0.14)
                      : cs.surface.withOpacity(0.75),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: cs.onSurface.withOpacity(0.08),
                  ),
                ),
                child: Icon(icon, color: selected ? accent : cs.onSurface),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (selected) _SelectedChip(color: accent),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onSurface.withOpacity(0.70),
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                selected ? Icons.check_circle_rounded : Icons.circle_outlined,
                color: selected ? accent : cs.onSurface.withOpacity(0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedChip extends StatelessWidget {
  final Color color;
  const _SelectedChip({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        'Selected',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }
}
