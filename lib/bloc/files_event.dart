import 'package:directus/directus.dart';

abstract class FilesEvent {}

class FilesLoadEvent extends FilesEvent {}

class FilesClearEvent extends FilesEvent {}

class FilesChangeOneEvent extends FilesEvent {
  final DirectusFile file;

  FilesChangeOneEvent({required this.file});
}

class FilesDeleteOneEvent extends FilesEvent {
  final String id;

  FilesDeleteOneEvent({required this.id});
}
