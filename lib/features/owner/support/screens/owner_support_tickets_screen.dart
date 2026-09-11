import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/support_provider.dart';
import 'create_owner_support_ticket_screen.dart';
import 'owner_support_ticket_details_screen.dart';

class OwnerSupportTicketsScreen
    extends StatefulWidget {
  const OwnerSupportTicketsScreen({
    super.key,
  });

  @override
  State<OwnerSupportTicketsScreen> createState() =>
      _OwnerSupportTicketsScreenState();
}

class _OwnerSupportTicketsScreenState
    extends State<OwnerSupportTicketsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        context
            .read<SupportProvider>()
            .loadTickets();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider =
    context.watch<SupportProvider>();

    return Scaffold(
      backgroundColor:
      const Color(0xffF7F8FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Support',
          style: TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        const Color(0xff7CC000),
        onPressed: () async {
          final created =
          await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) =>
              const CreateOwnerSupportTicketScreen(),
            ),
          );

          if (created == true && mounted) {
            context
                .read<SupportProvider>()
                .loadTickets();
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () =>
            provider.loadTickets(),

        child: provider.isLoading
            ? const Center(
          child:
          CircularProgressIndicator(),
        )
            : provider.errorMessage != null
            ? _buildError(
          context,
          provider,
        )
            : provider.tickets.isEmpty
            ? _buildEmpty()
            : ListView.builder(
          padding:
          const EdgeInsets.all(16),
          itemCount:
          provider.tickets.length,
          itemBuilder:
              (context, index) {
            final ticket =
            provider.tickets[index];

            return _TicketCard(
              ticket: ticket,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        OwnerSupportTicketDetailsScreen(
                          ticketId:
                          ticket.id,
                        ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return ListView(
      physics:
      const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 130),
        Icon(
          Icons.support_agent,
          size: 70,
          color: Color(0xff7CC000),
        ),
        SizedBox(height: 20),
        Center(
          child: Text(
            'No support tickets',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),
        ),
        SizedBox(height: 8),
        Center(
          child: Text(
            'Create a ticket if you need help.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(
      BuildContext context,
      SupportProvider provider,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
          MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
              color: Colors.red,
            ),
            const SizedBox(height: 15),
            Text(
              provider.errorMessage ??
                  'Failed to load support tickets',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            ElevatedButton(
              onPressed:
              provider.loadTickets,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TICKET CARD
// ============================================================

class _TicketCard extends StatelessWidget {
  final dynamic ticket;
  final VoidCallback onTap;

  const _TicketCard({
    required this.ticket,
    required this.onTap,
  });

  Color _statusColor() {
    switch (ticket.status) {
      case 'open':
        return Colors.blue;
      case 'in_progress':
        return Colors.orange;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Color _priorityColor() {
    switch (ticket.priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
      const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius:
        BorderRadius.circular(18),
      ),
      child: InkWell(
        borderRadius:
        BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding:
          const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      ticket.subject,
                      style:
                      const TextStyle(
                        fontSize: 17,
                        fontWeight:
                        FontWeight.bold,
                        color:
                        Color(0xff1E1446),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons
                        .arrow_forward_ios,
                    size: 16,
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Text(
                ticket.message,
                maxLines: 2,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  color:
                  Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Badge(
                    text: ticket.status,
                    color: _statusColor(),
                  ),
                  _Badge(
                    text: ticket.priority,
                    color: _priorityColor(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}