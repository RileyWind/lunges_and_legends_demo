import 'package:flutter/material.dart';

import 'user_data.dart';

class BioForm extends StatefulWidget {
  final UserData userData;

  const BioForm(this.userData, {super.key});

  @override
  State<BioForm> createState() => _BioFormState();
}

class _BioFormState extends State<BioForm> {
  String? get displayBio => widget.userData.bio;
  late final ctrl = TextEditingController(text: displayBio ?? '');
  late bool _editing = displayBio == null;
  bool _isLoading = false;

  void _onEdit() {
    setState(() {
      _editing = true;
    });
  }

  Future<void> _finishEditing() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await updateBio(widget.userData.ref, ctrl.text);
    } catch (error) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text("Unable to update bio."),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
              ),
            ],
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }
    setState(() {
      widget.userData.bio = ctrl.text;
      _editing = false;
      _isLoading = false;
    });
  }

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //final l = FirebaseUILocalizations.labelsOf(context);
    //final isCupertino = CupertinoUserInterfaceLevel.maybeOf(context) != null;
    final isCupertino = false;

    late Widget iconButton;

    if (_isLoading) {
      iconButton = IconButton(
        iconSize: 46,
        icon: const CircularProgressIndicator(),
        onPressed: () {},
      );
    } else {
      iconButton = IconButton(
        iconSize: 46,
        icon: Icon(_editing ? Icons.check : Icons.edit),
        onPressed: _editing ? _finishEditing : _onEdit,
        tooltip: _editing ? "Confirm" : "Edit bio",
      );
    }

    if (!_editing) {
      return FittedBox(
        fit: BoxFit.none,
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            iconButton,
            ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 422.0, minWidth: 422.0, maxHeight: 896.0),
              child: Text(
                displayBio ?? 'Unknown',
                style: const TextStyle(
                  fontFamily: 'King',
                  fontSize: 36.0,
                ),
              ),
            ),
          ],
        ),
      );
    }

    late Widget textField;

    if (isCupertino) {
    } else {
      textField = TextField(
        autofocus: true,
        controller: ctrl,
        style: const TextStyle(
          fontFamily: 'King',
          fontSize: 36.0,
        ),
        decoration: const InputDecoration(
          hintText: 'Tell us about yourself.',
          isCollapsed: true,
          isDense: false,
          border: InputBorder.none,
        ),
        minLines: 1,
        maxLines: 16,
        onSubmitted: (_) => _finishEditing(),
      );
    }

    return FittedBox(
      fit: BoxFit.none,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          iconButton,
          ConstrainedBox(
              constraints: const BoxConstraints(
                  maxWidth: 422.0, minWidth: 422.0, maxHeight: 896.0),
              child: textField),
        ],
      ),
    );
  }
}
