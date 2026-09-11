import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/academy_model.dart';
import '../controller/academy_controller.dart';
import '../widgets/academy_form.dart';

class EditAcademyScreen extends StatelessWidget {
  final AcademyModel academy;

  const EditAcademyScreen({
    super.key,
    required this.academy,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Academy',
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
              initialName: academy.name,
              initialPhoneNumber:
              academy.phoneNumber,
              initialDescription:
              academy.description,
              initialAddress:
              academy.address,
              initialCityId:
              academy.cityId,
              initialImageUrl:
              academy.imageUrl,
              initialPitchId:
              academy.pitchId,
              isLoading:
              controller.isUpdating,
              submitLabel:
              'Save Changes',
              onSubmit: ({
                required String name,
                required String phoneNumber,
                String? description,
                String? address,
                String? cityId,
                String? imageUrl,
                required String pitchId,
              }) async {
                final updatedAcademy =
                await controller.updateAcademy(
                  academyId: academy.id,
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

                if (updatedAcademy != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Academy updated successfully',
                      ),
                    ),
                  );

                  Navigator.pop(
                    context,
                    updatedAcademy,
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