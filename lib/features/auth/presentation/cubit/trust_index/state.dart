import 'package:equatable/equatable.dart';

class TrustIndexState extends Equatable {
  final double trustScore;
  final double rating;
  final int reviewCount;
  final List<TrustReview> reviews;
  final bool isLoading;
  final String? error;

  const TrustIndexState({
    this.trustScore = 0,
    this.rating = 0,
    this.reviewCount = 0,
    this.reviews = const [],
    this.isLoading = false,
    this.error,
  });

  TrustIndexState copyWith({
    double? trustScore,
    double? rating,
    int? reviewCount,
    List<TrustReview>? reviews,
    bool? isLoading,
    String? error,
    bool resetError = false,
  }) {
    return TrustIndexState(
      trustScore: trustScore ?? this.trustScore,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: resetError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
    trustScore,
    rating,
    reviewCount,
    reviews,
    isLoading,
    error,
  ];
}

class TrustReview extends Equatable {
  final String reviewerName;
  final double rating;
  final String propertyTitle;
  final String city;
  final String priceLabel;
  final String comment;
  final String? imageUrl;

  const TrustReview({
    required this.reviewerName,
    required this.rating,
    required this.propertyTitle,
    required this.city,
    required this.priceLabel,
    required this.comment,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    reviewerName,
    rating,
    propertyTitle,
    city,
    priceLabel,
    comment,
    imageUrl,
  ];
}
