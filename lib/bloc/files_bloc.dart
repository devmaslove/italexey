import 'package:directus/directus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:italexey/bloc/files_event.dart';
import 'package:italexey/bloc/files_state.dart';
import 'package:italexey/singleton/files_web_socket.dart';

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
        FilesWebSocket().setCallback(_onServerMessage);
      } on DirectusError catch (e) {
        emit(FilesErrorState(message: e.message));
      } catch (e) {
        emit(FilesErrorState(message: ''));
      }
    });
    on<FilesClearEvent>((event, emit) async {
      FilesWebSocket().setCallback(null);
      emit(FilesEmptyState());
    });
    on<FilesDeleteOneEvent>((event, emit) async {
      if (state is FilesLoadedState) {
        final filesOld = (state as FilesLoadedState).files;
        final files = filesOld.where((file) => file.id != event.id).toList();
        emit(FilesLoadedState(files: files));
      }
    });
    on<FilesChangeOneEvent>((event, emit) async {
      if (state is FilesLoadedState) {
        final filesOld = (state as FilesLoadedState).files;
        final index = filesOld.indexWhere((file) => file.id == event.file.id);
        if (index != -1) {
          final files = [...filesOld];
          files[index] = event.file;
          emit(FilesLoadedState(files: files));
        }
      }
    });
  }

  @override
  Future<void> close() {
    FilesWebSocket().setCallback(null);
    return super.close();
  }

  void _onServerMessage(String message) {
    debugPrint('server message $message');
    if (state is FilesLoadedState) {
      final filesCurrent = (state as FilesLoadedState).files;
      if (message.startsWith('delete ')) {
        final fileTitle = message.replaceAll('delete ', '');
        final index =
            filesCurrent.indexWhere((file) => file.title == fileTitle);
        if (index != -1) {
          add(FilesDeleteOneEvent(id: filesCurrent[index].id ?? ''));
        }
      }
    }
  }
}
