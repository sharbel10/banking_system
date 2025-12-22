import 'package:banking_system/core/di/injection.dart';
import 'package:banking_system/features/customer/patterns/facade/customer_facade_mock.dart';
import 'package:banking_system/features/customer/presentation/bloc/support/support_bloc.dart';
import 'package:banking_system/features/customer/presentation/bloc/support/support_event.dart';
import 'package:banking_system/features/customer/presentation/bloc/support/support_state.dart';
import 'package:banking_system/features/customer/presentation/widgets/support_ticket_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/session/session_cubit.dart';

class ContactSupportPage extends StatefulWidget {
  const ContactSupportPage({super.key});

  @override
  State<ContactSupportPage> createState() => _ContactSupportPageState();
}

class _ContactSupportPageState extends State<ContactSupportPage> {
  final _formKey = GlobalKey<FormState>();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = context.read<SessionCubit>().state;
    final customerId = 'demo-customer'; // read from sessionState in real app

    final facade = sl<CustomerFacadeMock>();
    ;

    return BlocProvider<SupportBloc>(
      create: (_) {
        final bloc = SupportBloc(facade: facade);
        bloc.add(LoadTickets(customerId));
        return bloc;
      },
      child: _ContactSupportView(
        formKey: _formKey,
        subjectCtrl: _subjectCtrl,
        messageCtrl: _messageCtrl,
        customerId: customerId,
      ),
    );
  }
}

class _ContactSupportView extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final String customerId;

  const _ContactSupportView({
    required this.formKey,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Contact Support')),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      Text(
                        'Create support ticket',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: subjectCtrl,
                        decoration: const InputDecoration(labelText: 'Subject'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Subject is required'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: messageCtrl,
                        decoration: const InputDecoration(labelText: 'Message'),
                        minLines: 3,
                        maxLines: 6,
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'Message is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                if (!formKey.currentState!.validate()) return;
                                context.read<SupportBloc>().add(
                                  CreateTicket(
                                    customerId: customerId,
                                    subject: subjectCtrl.text.trim(),
                                    message: messageCtrl.text.trim(),
                                  ),
                                );
                                subjectCtrl.clear();
                                messageCtrl.clear();
                              },
                              child: const Text('Create Ticket'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<SupportBloc, SupportState>(
                builder: (context, state) {
                  if (state is SupportLoading)
                    return const Center(child: CircularProgressIndicator());
                  if (state is SupportError)
                    return Center(
                      child: Text(
                        'Error: ${state.message}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    );
                  if (state is SupportLoaded) {
                    final tickets = state.tickets;
                    if (tickets.isEmpty)
                      return Center(
                        child: Text(
                          'No tickets',
                          style: TextStyle(
                            color: cs.onSurface.withOpacity(0.6),
                          ),
                        ),
                      );
                    return ListView.separated(
                      itemCount: tickets.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 8),
                      itemBuilder: (context, i) {
                        final t = tickets[i];
                        return SupportTicketTile(
                          ticket: t,
                          onClose: () => context.read<SupportBloc>().add(
                            UpdateTicketStatus(t.id, 'Closed'),
                          ),
                          onTap: () {
                            /* show details */
                          },
                        );
                      },
                    );
                  }
                  if (state is SupportProcessing)
                    return Center(child: Text(state.message));
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
