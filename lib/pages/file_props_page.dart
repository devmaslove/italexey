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

  @override
  Widget build(BuildContext context) {
    final fileTitle = widget.file.title ?? '';
    //
    return Scaffold(
      appBar: AppBar(title: Text(fileTitle)),
      body: FilePropsPageContent(
        formKey: formKey,
        title: fileTitle,
        onTitleSaved: (value) => newTitle = value,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState != null &&
              formKey.currentState!.validate()) {
            formKey.currentState!.save();
            widget.file.title = newTitle;
            Navigator.of(context).pop(true);
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
  final String title;

  const FilePropsPageContent({
    super.key,
    required this.formKey,
    required this.onTitleSaved,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            InputTextForm(
              text: title,
              textInputAction: TextInputAction.next,
              hintText: 'A unique title',
              validator: (value) {
                if (value.isEmpty) return '*Поле не заполнено';
                return '';
              },
              onSaved: onTitleSaved,
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
  final TextInputAction? textInputAction;
  final String hintText;
  final String? text;

  const InputTextForm({
    Key? key,
    required this.onSaved,
    required this.hintText,
    this.validator,
    this.text,
    this.capitalization = true,
    this.onChanged,
    this.textInputAction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: text,
      autofocus: false,
      textInputAction: textInputAction,
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
