import 'package:chewie/chewie.dart';
import 'package:directus/directus.dart';
import 'package:flutter/material.dart';
import 'package:italexey/models/file_page_model.dart';
import 'package:italexey/resources/env.dart';
import 'package:video_player/video_player.dart';

class FilePropsPage extends StatefulWidget {
  final DirectusFile file;

  const FilePropsPage({super.key, required this.file});

  @override
  State<FilePropsPage> createState() => _FilePropsPageState();
}

class _FilePropsPageState extends State<FilePropsPage> {
  final formKey = GlobalKey<FormState>();
  String newTitle = '';
  String newDescription = '';

  @override
  Widget build(BuildContext context) {
    const maxHeight = 200;
    int previewHeight = widget.file.height ?? 0;
    int previewWidth = widget.file.width ?? 0;
    final fileTitle = widget.file.getFileTitle();
    final fileExt = widget.file.getFileExt();
    String url = widget.file.fileUrl();
    FilePreviewType previewType = FilePreviewType.other;
    if (widget.file.isImage) {
      if (previewHeight > maxHeight) {
        final ratio = widget.file.getImageRatio();
        previewHeight = maxHeight;
        previewWidth = (maxHeight * ratio).ceil();
      }
      previewType = FilePreviewType.image;
      url = widget.file.thumbnailUrl(
        fit: DirectusThumbnailFit.cover,
        width: previewWidth,
        height: previewHeight,
        quality: 80,
        format: DirectusThumbnailFormat.jpg,
      );
    } else if (widget.file.isVideo) {
      previewType = FilePreviewType.video;
    }
    final fileDescription = widget.file.getFileDescription();
    //
    return Scaffold(
      appBar: AppBar(
        title: Text(fileTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Удалть файл',
            onPressed: () {
              String id = widget.file.id ?? '';
              DirectusSingleton.instance.files.deleteOne(id).then((_) {
                Navigator.of(context).pop('Delete');
              });
              // handle the press
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: FilePropsPageContent(
          formKey: formKey,
          title: fileTitle,
          description: fileDescription,
          onTitleSaved: (value) => newTitle = value,
          onDescriptionSaved: (value) => newDescription = value,
          previewFileExt: fileExt,
          previewUrl: url,
          previewHeight: maxHeight,
          previewType: previewType,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            formKey.currentState!.save();

            String id = widget.file.id ?? '';
            // не хватило функционала в пакете Directus
            // запостил пул-реквест
            // ну а пока будет с варнингом
            DirectusSingleton.instance.files.handler
                .updateOne(
              data: DirectusFile(title: newTitle, description: newDescription),
              id: id,
            )
                .then((_) {
              widget.file.title = newTitle;
              widget.file.description = newDescription;
              Navigator.of(context).pop('Save');
            });
          }
        },
        tooltip: 'Сохранить',
        child: const Icon(Icons.save),
      ),
    );
  }
}

class FilePropsPageContent extends StatelessWidget {
  final Key formKey;
  final void Function(String value) onTitleSaved;
  final void Function(String value) onDescriptionSaved;
  final String title;
  final String description;
  final int previewHeight;
  final String previewUrl;
  final String previewFileExt;
  final FilePreviewType previewType;

  const FilePropsPageContent({
    super.key,
    required this.formKey,
    required this.onTitleSaved,
    required this.onDescriptionSaved,
    required this.title,
    required this.description,
    required this.previewHeight,
    required this.previewUrl,
    required this.previewFileExt,
    required this.previewType,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FilePreview(
              height: previewHeight,
              ext: previewFileExt,
              downloadLink: previewUrl,
              type: previewType,
            ),
            const SizedBox(height: 16),
            const Text('*Title'),
            const SizedBox(height: 8),
            InputTextForm(
              text: title,
              hintText: 'A unique title',
              capitalization: false,
              multiline: false,
              validator: (value) {
                if (value.isEmpty) return '*Поле не заполнено';
                return '';
              },
              onSaved: onTitleSaved,
            ),
            const SizedBox(height: 16),
            const Text('Description'),
            const SizedBox(height: 8),
            InputTextForm(
              text: description,
              hintText: 'An optional description',
              capitalization: true,
              multiline: true,
              onSaved: onDescriptionSaved,
            ),
          ],
        ),
      ),
    );
  }
}

class InputTextForm extends StatelessWidget {
  final void Function(String value) onSaved;
  final void Function(String value)? onChanged;
  final String Function(String value)? validator;
  final bool capitalization;
  final String hintText;
  final String? text;
  final bool multiline;

  const InputTextForm({
    Key? key,
    required this.onSaved,
    required this.hintText,
    this.validator,
    this.text,
    required this.capitalization,
    required this.multiline,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: text,
      autofocus: false,
      keyboardType: multiline ? TextInputType.multiline : null,
      maxLines: multiline ? null : 1,
      minLines: multiline ? 3 : null,
      textCapitalization: capitalization
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      decoration: InputDecoration(
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.black45,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 12,
          height: 14 / 12,
          color: Colors.red,
          fontWeight: FontWeight.w500,
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          gapPadding: 0,
          borderSide: const BorderSide(
            color: Colors.red,
          ),
        ),
        hintStyle: const TextStyle(
          color: Colors.grey,
        ),
        hintText: hintText,
      ),
      validator: (value) {
        if (validator == null) return null;
        final result = validator!(value ?? '');
        if (result.isEmpty) return null;
        return result;
      },
      onSaved: (value) => onSaved(value ?? ''),
      onChanged: (value) => onChanged?.call(value),
    );
  }
}

enum FilePreviewType {
  image,
  video,
  other,
}

class FilePreview extends StatefulWidget {
  final String ext;
  final String downloadLink;
  final int height;
  final FilePreviewType type;

  const FilePreview({
    super.key,
    required this.ext,
    required this.downloadLink,
    required this.height,
    required this.type,
  });

  @override
  State<FilePreview> createState() => _FilePreviewState();
}

class _FilePreviewState extends State<FilePreview> {
  bool showVideo = false;
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    String videoLink = widget.downloadLink;
    // в вебе не поддерживают httpHeaders
    // по этому прокидываем access_token в ссылку
    final videoLinkWithAccessToken = videoLink.contains('?')
        ? '$videoLink&access_token=${AppEnv.token}'
        : '$videoLink?access_token=${AppEnv.token}';
    // debugPrint('download video = $videoLinkWithAccessToken');
    videoPlayerController = VideoPlayerController.network(
      videoLinkWithAccessToken,
    );
    if (widget.type == FilePreviewType.video) {
      videoPlayerController.initialize().then((value) {
        setState(() => showVideo = true);
      });
    }
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
    );
  }

  @override
  void dispose() {
    chewieController.dispose();
    videoPlayerController.dispose();
    super.dispose();
  }

  Widget get fileIconWidget => Stack(
        children: [
          const Icon(
            Icons.insert_drive_file_outlined,
            size: 64,
            color: Colors.blue,
          ),
          Positioned(
            width: 64,
            top: 36,
            child: Text(
              widget.ext,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );

  Widget get imageThumbWidget => Image.network(
        widget.downloadLink,
        fit: BoxFit.fitHeight,
        height: widget.height.toDouble(),
        errorBuilder: (_, __, ___) => Center(child: fileIconWidget),
        headers: const {'Authorization': 'Bearer ${AppEnv.token}'},
      );

  Widget get playerWidget => Chewie(
        controller: chewieController,
      );

  Widget getPreviewWidget() {
    if (widget.type == FilePreviewType.image) return imageThumbWidget;
    if (showVideo != false) return playerWidget;
    return fileIconWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height.toDouble(),
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.black12,
        borderRadius: BorderRadius.circular(6),
      ),
      child: getPreviewWidget(),
    );
  }
}
