import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/session/session_cubit.dart';

class RoleSelectionPage extends StatelessWidget {
  const RoleSelectionPage({super.key});

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
                      title: 'Banking System',
                      icon: Icons.account_balance_rounded,
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: 'Reset',
                      onPressed: () => context.read<SessionCubit>().reset(),
                      icon: Icon(Icons.restart_alt_rounded, color: cs.onSurface),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // Header
                Text(
                  'Choose your role',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select how you want to enter the system.\nYou can switch anytime.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.color
                        ?.withOpacity(0.7),
                    height: 1.35,
                  ),
                ),

                const SizedBox(height: 26),

                // Cards
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: _RoleCard(
                          title: 'Customer',
                          subtitle:
                          'View accounts, transactions, notifications, and support tickets.',
                          icon: Icons.person_rounded,
                          badge: 'Personal',
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.primary.withOpacity(0.16),
                              cs.surface.withOpacity(0.70),
                            ],

                          ),
                          onTap: () {
                            context.read<SessionCubit>().actAsCustomer();
                            context.go('/customer/home');
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _RoleCard(
                          title: 'Staff',
                          subtitle:
                          'Act as Teller or Manager to create accounts and approve transactions.',
                          icon: Icons.badge_rounded,
                          badge: 'Operations',
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              cs.secondary.withOpacity(0.14),
                              cs.secondary.withOpacity(0.25),
                            ],
                          ),
                          onTap: () {
                            context.read<SessionCubit>().actAsStaff();
                            context.go('/staff/dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Footer hint
                Row(
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 18, color: cs.onSurface.withOpacity(0.6)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No authentication needed for the demo. Access is simulated via role selection.',
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
        color: cs.surface.withOpacity(0.75),
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
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String badge;
  final Gradient gradient;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.badge,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_RoleCard> createState() => _RoleCardState();
}

class _RoleCardState extends State<_RoleCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AnimatedScale(
      scale: _pressed ? 0.985 : 1.0,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          child: Ink(
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: cs.onSurface.withOpacity(0.08)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 22,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _IconBubble(icon: widget.icon),
                      const Spacer(),
                      _Badge(text: widget.badge),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    widget.title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      color: cs.primary
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.subtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black,
                      height: 1.35,
                      fontWeight: FontWeight.bold

                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text(
                        'Continue',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: cs.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.arrow_forward_rounded,
                          size: 18, color: cs.primary),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final IconData icon;
  const _IconBubble({required this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.65),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Icon(icon, size: 26, color: cs.onSurface),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surface.withOpacity(0.75),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.onSurface.withOpacity(0.08)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 12,
          color: cs.onSurface.withOpacity(0.75),
        ),
      ),
    );
  }
}
