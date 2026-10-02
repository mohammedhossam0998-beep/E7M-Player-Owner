import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/support_provider.dart';
import 'package:e7m/shared/localization/app_translations.dart';

class OwnerSupportTicketDetailsScreen
    extends StatefulWidget {
  final int ticketId;

  const OwnerSupportTicketDetailsScreen({
    super.key,
    required this.ticketId,
  });

  @override
  State<OwnerSupportTicketDetailsScreen>
  createState() =>
      _OwnerSupportTicketDetailsScreenState();
}

class _OwnerSupportTicketDetailsScreenState
    extends State<
        OwnerSupportTicketDetailsScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        context
            .read<SupportProvider>()
            .loadTicketDetails(
          widget.ticketId,
        );
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
        title: Text(
          'Ticket Details'.tr,
          style: TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: provider.isLoadingDetails
          ? const Center(
        child:
        CircularProgressIndicator(),
      )
          : provider.errorMessage != null
          ? Center(
        child: Padding(
          padding:
          const EdgeInsets.all(
            24,
          ),
          child: Text(
            provider.errorMessage!,
            textAlign:
            TextAlign.center,
          ),
        ),
      )
          : provider.selectedTicket ==
          null
          ? Center(
        child: Text(
          'Ticket not found'.tr,
        ),
      )
          : _buildContent(
        context,
        provider,
      ),
    );
  }

  Widget _buildContent(
      BuildContext context,
      SupportProvider provider,
      ) {
    final ticket =
    provider.selectedTicket!;

    return RefreshIndicator(
      onRefresh: () =>
          provider.loadTicketDetails(
            widget.ticketId,
          ),
      child: ListView(
        padding:
        const EdgeInsets.all(20),
        children: [
          // ====================================================
          // TICKET
          // ====================================================

          Container(
            padding:
            const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  ticket.subject,
                  style: const TextStyle(
                    fontSize: 21,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xff1E1446),
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    _Badge(
                      text: _humanize(ticket.status),
                    ),
                    const SizedBox(width: 8),
                    _Badge(
                      text: _humanize(ticket.priority),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                Text(
                  ticket.message,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color:
                    Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ====================================================
          // REPLIES
          // ====================================================

          Text(
            'Replies'.tr,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xff1E1446),
            ),
          ),

          const SizedBox(height: 12),

          if (provider.replies.isEmpty)
            Container(
              padding:
              const EdgeInsets.all(20),
              decoration:
              BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
              child: Text(
                'No replies yet. Our support team will respond soon.'.tr,
                style: TextStyle(
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),

          ...provider.replies.map(
                (reply) => Container(
              margin:
              const EdgeInsets.only(
                bottom: 12,
              ),
              padding:
              const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(
                  18,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor:
                        Color(
                          0xffE8F6D8,
                        ),
                        child: Icon(
                          Icons
                              .support_agent,
                          size: 20,
                          color:
                          Color(
                            0xff7CC000,
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Support Team'.tr,
                        style: TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    reply.message,
                    style:
                    const TextStyle(
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;

  const _Badge({
    required this.text,
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
        color: const Color(
          0xff7CC000,
        ).withValues(
          alpha: 0.12,
        ),
        borderRadius:
        BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xff5C9900),
          fontWeight:
          FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

// Turns an API value like 'in_progress' into 'In Progress' and translates it.
String _humanize(String value) {
  if (value.isEmpty) return value;

  return value
      .replaceAll('_', ' ')
      .split(' ')
      .map((w) => w.isEmpty
      ? w
      : w[0].toUpperCase() + w.substring(1).toLowerCase())
      .join(' ')
      .tr;
}