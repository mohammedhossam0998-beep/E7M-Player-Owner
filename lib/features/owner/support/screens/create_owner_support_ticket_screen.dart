import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/support_provider.dart';

class CreateOwnerSupportTicketScreen
    extends StatefulWidget {
  const CreateOwnerSupportTicketScreen({
    super.key,
  });

  @override
  State<CreateOwnerSupportTicketScreen>
  createState() =>
      _CreateOwnerSupportTicketScreenState();
}

class _CreateOwnerSupportTicketScreenState
    extends State<CreateOwnerSupportTicketScreen> {
  final _formKey =
  GlobalKey<FormState>();

  final _subjectController =
  TextEditingController();

  final _messageController =
  TextEditingController();

  String _priority = 'medium';

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();

    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!
        .validate()) {
      return;
    }

    final provider =
    context.read<SupportProvider>();

    final ticket =
    await provider.createTicket(
      subject:
      _subjectController.text.trim(),
      message:
      _messageController.text.trim(),
      priority: _priority,
    );

    if (!mounted) return;

    if (ticket != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          backgroundColor:
          Color(0xff7CC000),
          content: Text(
            'Support ticket created successfully',
          ),
        ),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            provider.errorMessage ??
                'Failed to create ticket',
          ),
        ),
      );
    }
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
          'Create Support Ticket',
          style: TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Form(
        key: _formKey,
        child: ListView(
          padding:
          const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.support_agent,
              size: 65,
              color: Color(0xff7CC000),
            ),

            const SizedBox(height: 25),

            TextFormField(
              controller:
              _subjectController,
              textInputAction:
              TextInputAction.next,
              decoration:
              InputDecoration(
                labelText: 'Subject',
                hintText:
                'What do you need help with?',
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Subject is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller:
              _messageController,
              maxLines: 7,
              decoration:
              InputDecoration(
                labelText: 'Message',
                hintText:
                'Describe your problem...',
                alignLabelWithHint: true,
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Message is required';
                }

                return null;
              },
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<
                String>(
              initialValue: _priority,
              decoration:
              InputDecoration(
                labelText: 'Priority',
                filled: true,
                fillColor: Colors.white,
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    16,
                  ),
                  borderSide:
                  BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'low',
                  child: Text('Low'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium'),
                ),
                DropdownMenuItem(
                  value: 'high',
                  child: Text('High'),
                ),
              ],
              onChanged: provider.isCreating
                  ? null
                  : (value) {
                if (value != null) {
                  setState(() {
                    _priority =
                        value;
                  });
                }
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed:
                provider.isCreating
                    ? null
                    : _submit,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xff7CC000,
                  ),
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child:
                provider.isCreating
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child:
                  CircularProgressIndicator(
                    strokeWidth: 2,
                    color:
                    Colors.white,
                  ),
                )
                    : const Text(
                  'Submit Ticket',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}