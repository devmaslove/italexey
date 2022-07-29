import 'package:directus/directus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:italexey/bloc/files_event.dart';
import 'package:italexey/bloc/files_state.dart';

class FilesBloc extends Bloc<FilesEvent, FilesState> {
  FilesBloc() : super(FilesEmptyState()) {
    on<FilesLoadEvent>((event, emit) async {
      emit(FilesLoadingState());
      try {
        final files = await DirectusSingleton.instance.files.readMany(
          filters: Filters({
            'folder': Filter.isNull(),
          }),
          query: Query(
            limit: 250,
            sort: ['title'],
          ),
        );
        emit(FilesLoadedState(files: files.data));
      } on DirectusError catch (e) {
        emit(FilesErrorState(message: e.message));
      } catch (e) {
        emit(FilesErrorState(message: ''));
      }
    });
    on<FilesClearEvent>((event, emit) async {
      emit(FilesEmptyState());
    });
  }
}
