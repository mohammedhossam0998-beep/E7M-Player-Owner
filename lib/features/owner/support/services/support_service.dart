import 'package:e7m/core/network/api_client.dart';

import '../models/support_ticket_model.dart';
import '../models/support_reply_model.dart';

class SupportService {
  final ApiClient _apiClient;

  SupportService({
    ApiClient? apiClient,
  }) : _apiClient = apiClient ?? ApiClient();

  // ============================================================
  // CREATE SUPPORT TICKET
  // POST /api/support/tickets
  // ============================================================

  Future<SupportTicketModel> createTicket({
    required String subject,
    required String message,
    required String priority,
  }) async {
    try {
      final response = await _apiClient.post(
        '/support/tickets',
        {
          'subject': subject,
          'message': message,
          'priority': priority,
        },
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid create ticket response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to create support ticket',
        );
      }

      final ticketData = response['ticket'];

      if (ticketData is! Map) {
        throw Exception(
          'Invalid ticket data',
        );
      }

      return SupportTicketModel.fromJson(
        Map<String, dynamic>.from(ticketData),
      );
    } catch (e) {
      print(
        '❌ CREATE SUPPORT TICKET SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET MY SUPPORT TICKETS
  // GET /api/support/tickets
  // ============================================================

  Future<List<SupportTicketModel>> getMyTickets() async {
    try {
      final response = await _apiClient.get(
        '/support/tickets',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid support tickets response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to get support tickets',
        );
      }

      final ticketsData = response['tickets'];

      if (ticketsData is! List) {
        return [];
      }

      return ticketsData
          .map(
            (ticket) => SupportTicketModel.fromJson(
          Map<String, dynamic>.from(ticket),
        ),
      )
          .toList();
    } catch (e) {
      print(
        '❌ GET SUPPORT TICKETS SERVICE ERROR: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // GET SINGLE SUPPORT TICKET
  // GET /api/support/tickets/:id
  // ============================================================

  Future<SupportTicketDetails> getTicketById(
      int ticketId,
      ) async {
    try {
      final response = await _apiClient.get(
        '/support/tickets/$ticketId',
      );

      if (response is! Map<String, dynamic>) {
        throw Exception(
          'Invalid support ticket details response',
        );
      }

      if (response['success'] != true) {
        throw Exception(
          response['message']?.toString() ??
              'Failed to get support ticket',
        );
      }

      final ticketData = response['ticket'];

      if (ticketData is! Map) {
        throw Exception(
          'Invalid ticket data',
        );
      }

      final repliesData = response['replies'];

      final replies = repliesData is List
          ? repliesData
          .map(
            (reply) =>
            SupportReplyModel.fromJson(
              Map<String, dynamic>.from(reply),
            ),
      )
          .toList()
          : <SupportReplyModel>[];

      return SupportTicketDetails(
        ticket: SupportTicketModel.fromJson(
          Map<String, dynamic>.from(ticketData),
        ),
        replies: replies,
      );
    } catch (e) {
      print(
        '❌ GET SUPPORT TICKET DETAILS ERROR: $e',
      );

      rethrow;
    }
  }
}

// ============================================================
// SUPPORT TICKET DETAILS
// ============================================================

class SupportTicketDetails {
  final SupportTicketModel ticket;
  final List<SupportReplyModel> replies;

  const SupportTicketDetails({
    required this.ticket,
    required this.replies,
  });
}