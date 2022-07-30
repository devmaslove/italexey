import 'package:directus/directus.dart';
import 'package:flutter/material.dart';

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
    final fileTitle = widget.file.title ?? '';
    final fileDescription = widget.file.description ?? '';
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
      body: FilePropsPageContent(
        formKey: formKey,
        title: fileTitle,
        description: fileDescription,
        onTitleSaved: (value) => newTitle = value,
        onDescriptionSaved: (value) => newDescription = value,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            formKey.currentState!.save();

            String id = widget.file.id ?? '';
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

  const FilePropsPageContent({
    super.key,
    required this.formKey,
    required this.onTitleSaved,
    required this.onDescriptionSaved,
    required this.title,
    required this.description,
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
