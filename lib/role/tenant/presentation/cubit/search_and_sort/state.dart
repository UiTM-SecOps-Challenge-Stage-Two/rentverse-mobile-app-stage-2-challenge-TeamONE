import 'package:equatable/equatable.dart';

class SearchAndSortState extends Equatable {
  final String query;
  final String selectedType;

  const SearchAndSortState({this.query = '', this.selectedType = 'All'});

  SearchAndSortState copyWith({String? query, String? selectedType}) {
    return SearchAndSortState(
      query: query ?? this.query,
      selectedType: selectedType ?? this.selectedType,
    );
  }

  @override
  List<Object?> get props => [query, selectedType];
}
