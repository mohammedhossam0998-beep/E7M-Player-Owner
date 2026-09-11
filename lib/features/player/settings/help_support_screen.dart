import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:e7m/shared/localization/language_provider.dart';

import '../settings/presentation/providers/help_support_provider.dart';
import '../settings/models/help_support_model.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      context.read<HelpSupportProvider>().loadHelpSupport();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.watch<LanguageProvider>().translate;
    final provider = context.watch<HelpSupportProvider>();

    return Scaffold(
      backgroundColor: const Color(0xffF7F7F3),
      appBar: AppBar(
        backgroundColor: const Color(0xffF7F7F3),
        elevation: 0,
        title: Text(
          t('help_support'),
          style: const TextStyle(
            color: Color(0xff1E1446),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _buildBody(
        context,
        provider,
        t,
      ),
    );
  }

  Widget _buildBody(
      BuildContext context,
      HelpSupportProvider provider,
      String Function(String) t,
      ) {
    if (provider.isLoading && provider.data == null) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xff7CC000),
        ),
      );
    }

    if (provider.error != null && provider.data == null) {
      return _buildErrorState(
        context,
        provider,
        t,
      );
    }

    final data = provider.data;

    if (data == null) {
      return const Center(
        child: Text(
          'No support information available.',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      );
    }

    return RefreshIndicator(
      color: const Color(0xff7CC000),
      onRefresh: provider.loadHelpSupport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            _buildHeader(t),

            const SizedBox(height: 25),

            /// FAQ
            buildCard(
              Icons.help_outline,
              t('faq'),
              t('faq_desc'),
              context,
              onTap: () {
                _showFaq(
                  context,
                  data.faq,
                  t,
                );
              },
            ),

            /// LIVE CHAT
            buildCard(
              Icons.chat_outlined,
              t('live_chat'),
              t('live_chat_desc'),
              context,
              onTap: () {
                _showComingSoon(
                  context,
                  t('live_chat'),
                );
              },
            ),

            /// EMAIL
            buildCard(
              Icons.email_outlined,
              t('email_support'),
              data.email,
              context,
              onTap: () async {
                await _openEmail(
                  context,
                  data.email,
                  t,
                );
              },
            ),

            /// PHONE
            buildCard(
              Icons.phone_outlined,
              t('call_support'),
              data.phone,
              context,
              onTap: () async {
                await _callSupport(
                  context,
                  data.phone,
                  t,
                );
              },
            ),

            /// REPORT PROBLEM
            buildCard(
              Icons.bug_report_outlined,
              t('report_problem'),
              t('report_problem_desc'),
              context,
              onTap: () {
                _showReportProblem(
                  context,
                  t,
                );
              },
            ),

            /// RATE
            buildCard(
              Icons.star_outline,
              t('rate_e7gzly'),
              t('share_experience'),
              context,
              onTap: () {
                _showComingSoon(
                  context,
                  t('rate_e7gzly'),
                );
              },
            ),

            const SizedBox(height: 20),

            Text(
              "${t('version')} ${data.version}",
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
      String Function(String) t,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [
            Color(0xff1E1446),
            Color(0xff7CC000),
          ],
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.support_agent,
            color: Colors.white,
            size: 70,
          ),
          const SizedBox(height: 15),
          Text(
            t('how_can_we_help'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t('help_support_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context,
      HelpSupportProvider provider,
      String Function(String) t,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 55,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(
              t('help_support'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xff1E1446),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              t('try_again'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: provider.isLoading
                  ? null
                  : () {
                provider.loadHelpSupport();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff7CC000),
                foregroundColor: Colors.white,
              ),
              child: Text(
                t('retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCard(
      IconData icon,
      String title,
      String subtitle,
      BuildContext context, {
        required VoidCallback onTap,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 4,
        ),
        leading: CircleAvatar(
          backgroundColor:
          const Color(0xff7CC000).withOpacity(0.15),
          child: Icon(
            icon,
            color: const Color(0xff7CC000),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
        ),
        trailing: Icon(
          Directionality.of(context) == TextDirection.rtl
              ? Icons.arrow_back_ios
              : Icons.arrow_forward_ios,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Future<void> _openEmail(
      BuildContext context,
      String email,
      String Function(String) t,
      ) async {
    final uri = Uri(
      scheme: 'mailto',
      path: email,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showMessage(
          context,
          email,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          email,
        );
      }
    }
  }

  Future<void> _callSupport(
      BuildContext context,
      String phone,
      String Function(String) t,
      ) async {
    final cleanPhone = phone.replaceAll(
      RegExp(r'[^\d+]'),
      '',
    );

    final uri = Uri(
      scheme: 'tel',
      path: cleanPhone,
    );

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        _showMessage(
          context,
          phone,
        );
      }
    } catch (_) {
      if (context.mounted) {
        _showMessage(
          context,
          phone,
        );
      }
    }
  }

  void _showReportProblem(
      BuildContext context,
      String Function(String) t,
      ) {
    final subjectController = TextEditingController();
    final descriptionController = TextEditingController();

    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xffF7F7F3),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              16,
              20,
              16,
              MediaQuery.of(sheetContext).viewInsets.bottom + 24,
            ),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 45,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xff7CC000)
                                .withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bug_report_outlined,
                            color: Color(0xff7CC000),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            t('report_problem'),
                            style: const TextStyle(
                              color: Color(0xff1E1446),
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    TextFormField(
                      controller: subjectController,
                      maxLength: 255,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: t('subject'),
                        hintText: t('subject'),
                        prefixIcon: const Icon(
                          Icons.subject_outlined,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t('fill_all_fields');
                        }

                        if (value.trim().length > 255) {
                          return t('fill_all_fields');
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    TextFormField(
                      controller: descriptionController,
                      minLines: 5,
                      maxLines: 8,
                      textInputAction: TextInputAction.newline,
                      decoration: InputDecoration(
                        labelText: t('description'),
                        hintText: t('description'),
                        alignLabelWithHint: true,
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(bottom: 75),
                          child: Icon(
                            Icons.description_outlined,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return t('fill_all_fields');
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Consumer<HelpSupportProvider>(
                      builder: (
                          context,
                          provider,
                          child,
                          ) {
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: provider.isSubmittingReport
                                ? null
                                : () async {
                              if (!formKey.currentState!
                                  .validate()) {
                                return;
                              }

                              final success =
                              await context
                                  .read<HelpSupportProvider>()
                                  .submitReport(
                                subject:
                                subjectController.text
                                    .trim(),
                                description:
                                descriptionController.text
                                    .trim(),
                              );

                              if (!sheetContext.mounted) {
                                return;
                              }

                              if (success) {
                                Navigator.of(sheetContext).pop();

                                ScaffoldMessenger.of(context)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        t('report_submitted_successfully'),
                                      ),
                                      backgroundColor:
                                      const Color(0xff7CC000),
                                    ),
                                  );
                              } else {
                                ScaffoldMessenger.of(sheetContext)
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        provider.reportError ??
                                            t('report_submit_failed'),
                                      ),
                                      backgroundColor: Colors.redAccent,
                                    ),
                                  );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                              const Color(0xff7CC000),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                BorderRadius.circular(16),
                              ),
                            ),
                            child: provider.isSubmittingReport
                                ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                                : Text(
                              t('submit_report'),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showMessage(
      BuildContext context,
      String message,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );
  }

  void _showComingSoon(
      BuildContext context,
      String title,
      ) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(title),
        ),
      );
  }

  void _showFaq(
      BuildContext context,
      List<FaqItem> faq,
      String Function(String) t,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xffF7F7F3),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              20,
              16,
              24,
            ),
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.65,
              child: Column(
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Text(
                    t('faq'),
                    style: const TextStyle(
                      color: Color(0xff1E1446),
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Expanded(
                    child: faq.isEmpty
                        ? Center(
                      child: Text(
                        t('faq'),
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    )
                        : ListView.builder(
                      itemCount: faq.length,
                      itemBuilder: (context, index) {
                        final item = faq[index];

                        return Card(
                          elevation: 0,
                          margin: const EdgeInsets.only(
                            bottom: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(16),
                          ),
                          child: ExpansionTile(
                            title: Text(
                              item.question,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            childrenPadding:
                            const EdgeInsets.fromLTRB(
                              16,
                              0,
                              16,
                              16,
                            ),
                            children: [
                              Align(
                                alignment:
                                Alignment.centerLeft,
                                child: Text(
                                  item.answer,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}