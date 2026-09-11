import 'package:flutter/foundation.dart';

import '../models/support_ticket_model.dart';
import '../models/support_reply_model.dart';
import '../services/support_service.dart';

class SupportProvider extends ChangeNotifier {
  final SupportService _service;

  SupportProvider({
    SupportService? service,
  }) : _service = service ?? SupportService();

  // ============================================================
  // STATE
  // ============================================================

  List<SupportTicketModel> _tickets = [];

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isLoadingDetails = false;

  String? _errorMessage;

  SupportTicketModel? _selectedTicket;

  List<SupportReplyModel> _replies = [];

  // ============================================================
  // GETTERS
  // ============================================================

  List<SupportTicketModel> get tickets => _tickets;

  bool get isLoading => _isLoading;

  bool get isCreating => _isCreating;

  bool get isLoadingDetails => _isLoadingDetails;

  String? get errorMessage => _errorMessage;

  SupportTicketModel? get selectedTicket =>
      _selectedTicket;

  List<SupportReplyModel> get replies => _replies;

  // ============================================================
  // GET MY TICKETS
  // ============================================================

  Future<bool> loadTickets() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _tickets = await _service.getMyTickets();

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _isLoading = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CREATE TICKET
  // ============================================================

  Future<SupportTicketModel?> createTicket({
    required String subject,
    required String message,
    required String priority,
  }) async {
    _isCreating = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final ticket =
      await _service.createTicket(
        subject: subject,
        message: message,
        priority: priority,
      );

      _tickets.insert(0, ticket);

      return ticket;
    } catch (e) {
      _errorMessage = e.toString();

      return null;
    } finally {
      _isCreating = false;

      notifyListeners();
    }
  }

  // ============================================================
  // GET TICKET DETAILS
  // ============================================================

  Future<bool> loadTicketDetails(
      int ticketId,
      ) async {
    _isLoadingDetails = true;
    _errorMessage = null;

    notifyListeners();

    try {
      final result =
      await _service.getTicketById(
        ticketId,
      );

      _selectedTicket = result.ticket;
      _replies = result.replies;

      return true;
    } catch (e) {
      _errorMessage = e.toString();

      return false;
    } finally {
      _isLoadingDetails = false;

      notifyListeners();
    }
  }

  // ============================================================
  // CLEAR DETAILS
  // ============================================================

  void clearDetails() {
    _selectedTicket = null;
    _replies = [];
    _errorMessage = null;

    notifyListeners();
  }

  // ============================================================
  // CLEAR ERROR
  // ============================================================

  void clearError() {
    _errorMessage = null;

    notifyListeners();
  }
}