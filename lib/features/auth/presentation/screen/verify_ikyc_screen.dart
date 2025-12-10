import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rentverse/common/colors/custom_color.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/auth/presentation/screen/camera_screen.dart';
import 'package:rentverse/features/auth/presentation/pages/profile_pages.dart';
import 'package:rentverse/features/kyc/presentation/cubit/verify_ikyc_cubit.dart';
import 'package:rentverse/features/kyc/presentation/cubit/verify_ikyc_state.dart';

class VerifyIKycScreen extends StatelessWidget {
  const VerifyIKycScreen({super.key});

  Future<void> _pickImage(BuildContext context, {required bool isKtp}) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path == null) return;
    final file = File(path);

    final cubit = context.read<VerifyIKycCubit>();
    if (isKtp) {
      cubit.setKtpImage(file);
    } else {
      cubit.setSelfieImage(file);
    }
  }

  Future<void> _openCameraForSelfie(BuildContext context) async {
    final file = await Navigator.of(
      context,
    ).push<File?>(MaterialPageRoute(builder: (_) => const CameraScreen()));
    if (file != null && context.mounted) {
      context.read<VerifyIKycCubit>().setSelfieImage(file);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => VerifyIKycCubit(sl()),
      child: BlocConsumer<VerifyIKycCubit, VerifyIKycState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
          if (state.successMessage != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.successMessage!)));
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Verify iKYC'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(body: const ProfilePage()),
                    ),
                  );
                },
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _StepHeader(step: state.step),
                    const SizedBox(height: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildStepContent(context, state),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildBottomAction(context, state),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStepContent(BuildContext context, VerifyIKycState state) {
    switch (state.step) {
      case VerifyIKycStep.ktp:
        return _UploadCard(
          title: 'Upload ID',
          description:
              'Upload your ID card photo clearly, make sure the text is readable.',
          file: state.ktpImage,
          onPick: () => _pickImage(context, isKtp: true),
        );
      case VerifyIKycStep.selfie:
        return _UploadCard(
          title: 'Take a Selfie',
          description:
              'Use the front camera, make sure your face and the ID card are both visible.',
          file: state.selfieImage,
          onPick: () => _openCameraForSelfie(context),
        );
      case VerifyIKycStep.review:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'Review documents',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _PreviewTile(
                label: 'ID',
                file: state.ktpImage,
                onTap: () => _pickImage(context, isKtp: true),
              ),
              const SizedBox(height: 12),
              _PreviewTile(
                label: 'Selfie',
                file: state.selfieImage,
                onTap: () => _pickImage(context, isKtp: false),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Make sure photos are clear and not blurry. If everything looks correct, submit for verification.',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      case VerifyIKycStep.success:
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: appSecondaryColor, size: 64),
            const SizedBox(height: 12),
            Text(
              state.successMessage ?? 'KYC successfully submitted',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        );
    }
  }

  Widget _buildBottomAction(BuildContext context, VerifyIKycState state) {
    final cubit = context.read<VerifyIKycCubit>();

    if (state.step == VerifyIKycStep.success) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: appSecondaryColor,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => Scaffold(body: const ProfilePage()),
              ),
            );
          },
          child: const Text(
            'Back to Profile',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      );
    }

    return Row(
      children: [
        if (state.step == VerifyIKycStep.selfie ||
            state.step == VerifyIKycStep.review)
          Expanded(
            child: TextButton(
              onPressed: state.isSubmitting
                  ? null
                  : () => cubit.goToStep(
                      state.step == VerifyIKycStep.selfie
                          ? VerifyIKycStep.ktp
                          : VerifyIKycStep.selfie,
                    ),
              child: const Text('Kembali'),
            ),
          ),
        if (state.step != VerifyIKycStep.ktp) const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: appSecondaryColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: state.isSubmitting
                ? null
                : () {
                    if (state.step == VerifyIKycStep.ktp) {
                      if (state.ktpImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please choose an ID photo first'),
                          ),
                        );
                        return;
                      }
                      cubit.goToStep(VerifyIKycStep.selfie);
                    } else if (state.step == VerifyIKycStep.selfie) {
                      if (state.selfieImage == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please choose a selfie first'),
                          ),
                        );
                        return;
                      }
                      cubit.goToStep(VerifyIKycStep.review);
                    } else {
                      cubit.submit();
                    }
                  },
            child: state.isSubmitting
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Text(
                    _buttonLabel(state),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  String _buttonLabel(VerifyIKycState state) {
    switch (state.step) {
      case VerifyIKycStep.ktp:
        return state.ktpImage == null ? 'Choose ID' : 'Continue';
      case VerifyIKycStep.selfie:
        return state.selfieImage == null ? 'Choose Selfie' : 'Continue';
      case VerifyIKycStep.review:
        return 'Submit Verification';
      case VerifyIKycStep.success:
        return 'Done';
    }
  }
}

class _StepHeader extends StatelessWidget {
  const _StepHeader({required this.step});

  final VerifyIKycStep step;

  int get _currentIndex {
    switch (step) {
      case VerifyIKycStep.ktp:
        return 0;
      case VerifyIKycStep.selfie:
        return 1;
      case VerifyIKycStep.review:
        return 2;
      case VerifyIKycStep.success:
        return 3;
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = ['KTP', 'Selfie', 'Review'];
    return Row(
      children: steps.asMap().entries.map((entry) {
        final idx = entry.key;
        final label = entry.value;
        final active = idx <= _currentIndex;
        return Expanded(
          child: Column(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: active ? appSecondaryColor : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.black : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _UploadCard extends StatelessWidget {
  const _UploadCard({
    required this.title,
    required this.description,
    required this.onPick,
    this.file,
  });

  final String title;
  final String description;
  final VoidCallback onPick;
  final File? file;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(description),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onPick,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400, width: 1.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 40,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text('Tap to choose photo'),
                    ],
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      file!,
                      height: 220,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({required this.label, required this.file, this.onTap});

  final String label;
  final File? file;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(10),
              ),
              child: file == null
                  ? const Icon(Icons.photo_outlined, color: Colors.grey)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(file!, fit: BoxFit.cover),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(
                    file?.path.split('/').last ?? 'No file selected',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, color: appSecondaryColor),
          ],
        ),
      ),
    );
  }
}
