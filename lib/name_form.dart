import 'package:flutter/material.dart';

import 'user_data.dart';

class NameForm extends StatefulWidget {
  final UserData userData;

  NameForm(this.userData, {super.key});

  @override
  State<NameForm> createState() => _NameFormState();
}

class _NameFormState extends State<NameForm> {
  String? get displayName => widget.userData.username;
  late String? oldName = widget.userData.username;
  late final ctrl = TextEditingController(text: displayName ?? '');
  late bool _editing = displayName == null;
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
    oldName = widget.userData.username;
    if (ctrl.text == "") {
      showDialog(
        context: context,
        builder: (context) {
          return const AlertDialog(
            content: Text("Adventurer name can't be blank."),
          );
        },
      );
      setState(() {
        _isLoading = false;
      });
      return;
    } else {
      try {
        await updateUsername(
            widget.userData.ref, ctrl.text, oldName, widget.userData.uid);
      } catch (error) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text("That name is already taken."),
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
    }

    setState(() {
      widget.userData.username = ctrl.text;
      _editing = false;
      _isLoading = false;
    });
    //}
  }

  Widget build(BuildContext context) {
    late Widget iconButton;

    if (_isLoading) {
      iconButton = IconButton(
        iconSize: 46,
        icon: CircularProgressIndicator(),
        onPressed: () {},
      );
    } else {
      iconButton = IconButton(
        iconSize: 46,
        icon: Icon(_editing ? Icons.check : Icons.edit),

        onPressed: _editing ? _finishEditing : _onEdit,
        tooltip: _editing ? "Confirm" : "Edit name",

        //),
      );
    }

    if (!_editing) {
      return FittedBox(
        fit: BoxFit.none,
        alignment: Alignment.centerLeft,

        child: Row(
          children: [
            ConstrainedBox(
              constraints:
                  const BoxConstraints(maxWidth: 504.0, minWidth: 504.0),
              child: Text(
                displayName ?? 'Unknown',
                style: const TextStyle(
                  fontFamily: 'King',
                  fontSize: 50,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            iconButton,
          ],
        ),
        //),
      );
    }

    late Widget textField;

    textField = TextField(
      autofocus: true,
      controller: ctrl,
      style: const TextStyle(
        fontFamily: 'King',
        fontSize: 50,
      ),
      decoration: const InputDecoration(
        hintText: 'Name',
        isCollapsed: true,
        isDense: false,
        border: InputBorder.none,
      ),
      onSubmitted: (_) => _finishEditing(),
    );

    return FittedBox(
      fit: BoxFit.none,
      alignment: Alignment.centerLeft,
      child: Row(
        children: [
          ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 504.0),
              child: textField),
          iconButton,
        ],
      ),
    );
  }
}
