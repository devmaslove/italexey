import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:italexey/bloc/files_bloc.dart';
import 'package:italexey/bloc/files_event.dart';
import 'package:italexey/bloc/files_state.dart';
import 'package:italexey/pages/file_props_page.dart';
import 'package:italexey/resources/env.dart';

class FilesPage extends StatelessWidget {
  const FilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FilesBloc>(
      create: (_) => FilesBloc(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Файлы')),
        body: const FilesList(),
        floatingActionButton: const FilesActionButton(),
      ),
    );
  }
}

class FilesActionButton extends StatelessWidget {
  const FilesActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesBloc, FilesState>(
      builder: (context, state) {
        if (state is FilesEmptyState) {
          return const ActionButtonLoad();
        }
        if (state is FilesErrorState) {
          return const ActionButtonLoad();
        }
        if (state is FilesLoadedState) {
          return const ActionButtonClear();
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class ActionButtonLoad extends StatelessWidget {
  const ActionButtonLoad({super.key});

  @override
  Widget build(BuildContext context) {
    final filesBloc = context.read<FilesBloc>();
    return FloatingActionButton(
      onPressed: () => filesBloc.add(FilesLoadEvent()),
      tooltip: 'Загрузить список файлов',
      child: const Icon(Icons.cloud_download),
    );
  }
}

class ActionButtonClear extends StatelessWidget {
  const ActionButtonClear({super.key});

  @override
  Widget build(BuildContext context) {
    final filesBloc = context.read<FilesBloc>();
    return FloatingActionButton(
      onPressed: () => filesBloc.add(FilesClearEvent()),
      tooltip: 'Очистить список файлов',
      child: const Icon(Icons.clear_all),
    );
  }
}

class FilesList extends StatelessWidget {
  const FilesList({super.key});

  String getFileExt(final String? fileName) {
    if (fileName == null) return '';
    final fileNameParts = fileName.split('.');
    if (fileNameParts.length < 2) return '';
    return fileNameParts.last.toUpperCase();
  }

  String getFileSize(final int? fileSize) {
    if (fileSize == null || fileSize == 0) return '';
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1).replaceAll('.0', '')} kB';
    }
    final fileSizeMB = fileSize / (1024 * 1024);
    return '${fileSizeMB.toStringAsFixed(1).replaceAll('.0', '')} MB';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilesBloc, FilesState>(
      builder: (context, state) {
        if (state is FilesEmptyState) {
          return const Center(
            child: Text('Нет данных'),
          );
        }
        if (state is FilesErrorState) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Ошибка загрузки данных'),
                if (state.message.isNotEmpty) const SizedBox(height: 10),
                if (state.message.isNotEmpty)
                  Text(
                    state.message,
                    style: const TextStyle(
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          );
        }
        if (state is FilesLoadingState) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (state is FilesLoadedState) {
          debugPrint('Load files count = ${state.files.length}');
          return ListView.builder(
            itemCount: state.files.length,
            itemBuilder: (context, index) {
              final file = state.files.elementAt(index);
              final fileTitle = file.title ?? '';
              final fileExt = getFileExt(file.filenameDisk);
              final fileSize = getFileSize(file.filesize);
              final fileType = file.type ?? '';
              final isImage =
                  fileType.startsWith('image/') && fileType != 'image/svg+xml';
              final fileLink = file.downloadUrl(AppEnv.link) ?? '';
              final imageThumb =
                  '$fileLink?fit=cover&width=48&height=48&quality=50&format=jpg';
              // debugPrint('File: "$fileTitle" type = ${file.type}');
              // debugPrint(imageThumb);
              final fileIconWidget = Stack(
                children: [
                  const Icon(
                    Icons.insert_drive_file_outlined,
                    size: 48,
                    color: Colors.blue,
                  ),
                  Positioned(
                    width: 48,
                    top: 26,
                    child: Text(
                      fileExt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
              final imageThumbWidget = Image.network(
                imageThumb,
                width: 48,
                height: 48,
                errorBuilder: (_, __, ___) => fileIconWidget,
                headers: const {'Authorization': 'Bearer ${AppEnv.token}'},
              );
              return Card(
                child: ListTile(
                  leading: isImage ? imageThumbWidget : fileIconWidget,
                  title: Text(fileTitle),
                  subtitle: Text('$fileExt • $fileSize'),
                  onTap: () {
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute<bool>(
                        builder: (context) => FilePropsPage(file: file),
                      ),
                    ).then((change) {
                      if (change != null && change) {
                        final fileTitleNew = file.title ?? '';
                        debugPrint('changed file - $fileTitleNew');
                      }
                    });
                  },
                ),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
