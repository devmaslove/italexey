import 'package:directus/directus.dart';

abstract class FilesState {}

class FilesEmptyState extends FilesState {}

class FilesErrorState extends FilesState {
  final String message;

  FilesErrorState({required this.message});
}

class FilesLoadingState extends FilesState {}

class FilesLoadedState extends FilesState {
  final List<DirectusFile> files;

  FilesLoadedState({required this.files});
}
