import 'package:flutter/material.dart';
import 'package:rentverse/core/resources/data_state.dart';
import 'package:rentverse/core/utils/error_utils.dart';
import 'package:rentverse/core/services/service_locator.dart';
import 'package:rentverse/features/review/domain/usecase/submit_review_usecase.dart';
import 'package:rentverse/features/review/presentation/widget/property_reviews_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum ReviewOutcome { submitted, alreadyReviewed, cancelled, error }


Future<ReviewOutcome?> showReviewDialog(
  BuildContext context, {
  required String bookingId,
  required String propertyId,
}) async {

  return showModalBottomSheet<ReviewOutcome>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,

    builder: (ctx) =>
        _ReviewBottomSheetContent(bookingId: bookingId, propertyId: propertyId));
}


class _ReviewBottomSheetContent extends StatefulWidget {
  final String bookingId;
  final String propertyId;

  const _ReviewBottomSheetContent({
    required this.bookingId,
    required this.propertyId,
  });

  @override
  State<_ReviewBottomSheetContent> createState() =>
      _ReviewBottomSheetContentState();
}

class _ReviewBottomSheetContentState extends State<_ReviewBottomSheetContent> {

  late final ValueNotifier<int> _ratingNotifier;
  late final TextEditingController _commentController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _ratingNotifier = ValueNotifier<int>(5);
    _commentController = TextEditingController();
  }

  @override
  void dispose() {

    _ratingNotifier.dispose();
    _commentController.dispose();
    super.dispose();
  }


  String _getRatingLabel(int star) {
    switch (star) {
      case 1:
        return 'Terrible';
      case 2:
        return 'Bad';
      case 3:
        return 'Okay';
      case 4:
        return 'Good';
      case 5:
        return 'Amazing!';
      default:
        return 'Rate your stay';
    }
  }

  Future<void> _submitReview() async {
    setState(() => _isSubmitting = true);
    try {
      final usecase = sl<SubmitReviewUseCase>();
      final params = SubmitReviewParams(
        bookingId: widget.bookingId,
        rating: _ratingNotifier.value,
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim());

      final result = await usecase.call(param: params);

      if (!mounted) return;

      if (result is DataSuccess<void>) {
        Navigator.of(context).pop(ReviewOutcome.submitted);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Review submitted successfully!'),
            backgroundColor: Colors.green));
      } else if (result is DataFailed) {
        final dioErr = result.error;
        final statusCode = dioErr?.response?.statusCode;
        final msg = resolveApiErrorMessage(dioErr, fallback: 'Unknown error');


        if (statusCode == 409) {
          Navigator.of(context).pop(ReviewOutcome.alreadyReviewed);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Anda sudah review, tidak bisa 2 kali'),
              backgroundColor: Colors.orange));
        } else {
          final already = msg.toLowerCase().contains('already reviewed');
          if (already) {
            Navigator.of(context).pop(ReviewOutcome.alreadyReviewed);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('You have already reviewed this booking'),
                backgroundColor: Colors.orange));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed: $msg'),
                backgroundColor: Colors.red));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.only(
        bottom: bottomPadding,
        left: 20,
        right: 20,
        top: 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),


            const Text(
              'How was your experience?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text(
              'Your feedback helps us improve',
              style: TextStyle(color: Colors.grey, fontSize: 14)),
            const SizedBox(height: 24),


            ValueListenableBuilder<int>(
              valueListenable: _ratingNotifier,
              builder: (_, value, __) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        return GestureDetector(
                          onTap: () => _ratingNotifier.value = starIndex,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Icon(
                              starIndex <= value
                                  ? LucideIcons.star
                                  : LucideIcons.star,
                              color: starIndex <= value
                                  ? Colors.amber.shade400
                                  : Colors.grey.shade300,
                              size: 42)));
                      })),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Text(
                        _getRatingLabel(value),
                        key: ValueKey<int>(value),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade700)))]);
              }),
            const SizedBox(height: 24),


            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share more details about your stay... (optional)',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.amber)),
                contentPadding: const EdgeInsets.all(16))),
            const SizedBox(height: 24),


            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12))),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                    : const Text(
                        'Submit Review',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold)))),
            const SizedBox(height: 24)])));
  }
}


Future<void> showReviewsBottomSheet(BuildContext context, String propertyId) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return SafeArea(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(ctx).size.height * 0.8),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
          padding: const EdgeInsets.all(16),
          child: PropertyReviewsWidget(propertyId: propertyId)));
    });
}
