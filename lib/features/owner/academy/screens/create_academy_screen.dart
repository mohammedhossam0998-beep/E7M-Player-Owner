import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controller/academy_controller.dart';
import '../widgets/academy_form.dart';

class CreateAcademyScreen extends StatelessWidget {
  const CreateAcademyScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Academy',
        ),
        centerTitle: true,
      ),
      body: Consumer<AcademyController>(
        builder: (
            context,
            controller,
            child,
            ) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: AcademyForm(
              isLoading: controller.isCreating,
              submitLabel: 'Create Academy',
              onSubmit: ({
                required String name,
                required String phoneNumber,
                String? description,
                String? address,
                String? cityId,
                String? imageUrl,
                required String pitchId,
              }) async {
                final academy =
                await controller.createAcademy(
                  name: name,
                  phoneNumber: phoneNumber,
                  description: description,
                  address: address,
                  cityId: cityId,
                  imageUrl: imageUrl,
                  pitchId: pitchId,
                );

                if (!context.mounted) {
                  return;
                }

                if (academy != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Academy created successfully',
                      ),
                    ),
                  );

                  Navigator.pop(
                    context,
                    academy,
                  );
                } else if (
                controller.errorMessage != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    SnackBar(
                      content: Text(
                        controller.errorMessage!,
                      ),
                    ),
                  );
                }
              },
            ),
          );
        },
      ),
    );
  }
}