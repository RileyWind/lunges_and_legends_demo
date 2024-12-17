import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'homepage.dart';
import 'user_data.dart';

class AvatarForm extends StatefulWidget {
  final UserData userData;
  final AppBarData appBarData;
  final Function _reload;
  const AvatarForm(this.userData, this.appBarData, this._reload, {super.key});
  @override
  State<AvatarForm> createState() => _AvatarFormState();
}

class _AvatarFormState extends State<AvatarForm> {
  Future<void> _onPick() async {
    widget.appBarData.backButton = 2;
    widget.appBarData.avatarEditor = true;
    widget._reload();
  }

  Widget build(BuildContext context) {
    late Widget iconButton;
    late Widget avatarImage;
    if (!listEquals(widget.userData.avatar, Uint8List(0))) {
      avatarImage = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 2),
          shape: BoxShape.circle,
        ),
        child: CircleAvatar(
          radius: 86,
          backgroundImage: Image.memory(widget.userData.avatar).image,
          backgroundColor: Colors.black87,
        ),
      );
    } else {
      //print("here");
      avatarImage = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87, width: 2),
          shape: BoxShape.circle,
        ),
        child: const CircleAvatar(
          radius: 86,
          backgroundColor: Colors.white,
          child: Icon(Icons.edit, size: 46, color: Colors.black87),
        ),
      );
    }
    iconButton = IconButton(
      iconSize: 46,
      icon: avatarImage,
      tooltip: "Edit avatar",
      onPressed: _onPick,
    );

    return FittedBox(
      fit: BoxFit.none,
      alignment: Alignment.center,
      child: iconButton,
    );
  }
}

class AvatarFormPopup extends StatefulWidget {
  final UserData userData;
  final AppBarData appBarData;
  final Function _reload;

  AvatarFormPopup(this.userData, this.appBarData, this._reload, {super.key});

  @override
  State<AvatarFormPopup> createState() => _AvatarFormPopupState();
}

class _AvatarFormPopupState extends State<AvatarFormPopup> {
  final ImagePicker imagePicker = ImagePicker();
  late Uint8List _image = widget.userData.avatar;
  late int _width;
  late int _height;
  final TransformationController controller = TransformationController();
  double offsetX = 0.0;
  double offsetY = 0.0;
  double scaleX = 0.0;
  double scaleY = 0.0;
  Uint8List finalImage = Uint8List(0);
  double initialZoom = 0.0;
  bool _resetSlider = false;
  bool _isLoading = false;
  final double size = 200.0;

  Future<void> _onPick() async {
    final imageXfile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (imageXfile == null) {
      return;
    }
    final Uint8List imageBytes = await imageXfile.readAsBytes();
    setState(() {
      _image = imageBytes;
      _resetSlider = true;
      controller.value = Matrix4.identity();
    });
  }

  Widget build(BuildContext context) {
    late Widget pickButton;
    if (!listEquals(_image, Uint8List(0))) {
      img.Image image = img.decodeImage(_image)!;
      _width = image.width;
      _height = image.height;
      var dimension = _width < _height ? _width : _height;
      initialZoom = 200 / dimension;
      controller.value.setEntry(0, 0, initialZoom);
      controller.value.setEntry(1, 1, initialZoom);
      controller.value.setEntry(2, 2, initialZoom);
    }
    pickButton = IconButton(
      iconSize: 46,
      icon: const Icon(Icons.image_outlined),
      tooltip: "Browse images",
      onPressed: _onPick,
    );

    print(MediaQuery.of(context).size.width);
    return ListView(
      children: [
        const SizedBox(
          height: 60.0,
        ),
        listEquals(_image, Uint8List(0))
            ? const SizedBox()
            : AvatarCropper(widget.userData, _image, _width, _height,
                controller, initialZoom, _resetSlider),
        const SizedBox(
          height: 20.0,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            listEquals(_image, Uint8List(0))
                ? const Text(
                    "Upload an image to use as your avatar!",
                    style: const TextStyle(fontSize: 18),
                  )
                : IconButton(
                    iconSize: 46,
                    tooltip: "Confirm",
                    onPressed: () async {
                      setState(() {
                        _isLoading = true;
                      });
                      Matrix4 matrix = controller.value;
                      offsetX = matrix.entry(0, 3);
                      offsetY = matrix.entry(1, 3);
                      scaleX = matrix.entry(0, 0);
                      scaleY = matrix.entry(1, 1);
                      double xOrg = -offsetX / scaleX;
                      double yOrg = -offsetY / scaleX;
                      double width = (200.0 / scaleX);
                      double height = (200.0 / scaleX);
                      img.Image originalImage = img.decodeImage(_image)!;
                      img.Image croppedImage = img.copyCrop(originalImage,
                          x: xOrg.toInt(),
                          y: yOrg.toInt(),
                          width: width.toInt(),
                          height: height.toInt());
                      img.Image resizedImage =
                          img.copyResize(croppedImage, width: 400, height: 400);
                      finalImage = img.encodeJpg(resizedImage, quality: 50);
                      widget.userData.avatar = finalImage;
                      await updateAvatar(widget.userData.uid, finalImage);
                      if (!widget.userData.achievements[2]) {
                        widget.userData.achievements[2] = true;
                        achievementPopup(context, 2);
                        updateAchievement(widget.userData.ref, 2);
                      }
                      widget.appBarData.avatarEditor = false;
                      _isLoading = false;
                      widget._reload();
                    },
                    icon: _isLoading
                        ? const CircularProgressIndicator()
                        : const Icon(Icons.check),
                  ),
            SizedBox(
              width: listEquals(_image, Uint8List(0)) ? 10.0 : 40.0,
            ),
            pickButton,
          ],
        ),
      ],
    );
  }
}

class AvatarCropper extends StatefulWidget {
  final UserData userData;
  final Uint8List _image;
  final int _width;
  final int _height;
  final double _initialZoom;
  bool _resetSlider;
  final TransformationController _controller;

  AvatarCropper(this.userData, this._image, this._width, this._height,
      this._controller, this._initialZoom, this._resetSlider,
      {super.key});

  @override
  State<AvatarCropper> createState() => _AvatarCropperState();
}

class _AvatarCropperState extends State<AvatarCropper> {
  double offsetX = 100.0;
  double offsetY = 100.0;
  double scaleX = 0.0;
  double scaleY = 0.0;
  double oldScale = 0.0;
  double _sliderValue = 0;

  Matrix4 _getZoomInfo(
      int width, int height, double size, double zoom, double scale) {
    var scaledOffsetX = 0.0;
    var scaledOffsetY = 0.0;
    scaledOffsetX = (scale + widget._initialZoom / 4.0) *
            (offsetX - 100.0) /
            (oldScale + widget._initialZoom / 4.0) +
        100.0;
    scaledOffsetY = (scale + widget._initialZoom / 4.0) *
            (offsetY - 100.0) /
            (oldScale + widget._initialZoom / 4.0) +
        100.0;

    if (scaledOffsetX < -width * zoom + 200)
      scaledOffsetX = -width * zoom + 200;
    if (scaledOffsetX > 0) scaledOffsetX = 0;
    if (scaledOffsetY < -height * zoom + 200)
      scaledOffsetY = -height * zoom + 200;
    if (scaledOffsetY > 0) scaledOffsetY = 0;
    offsetX = scaledOffsetX;
    offsetY = scaledOffsetY;
    var matrix = Matrix4.identity();
    matrix.setEntry(0, 0, zoom);
    matrix.setEntry(1, 1, zoom);
    matrix.setEntry(2, 2, zoom);
    matrix.setEntry(0, 3, scaledOffsetX);
    matrix.setEntry(1, 3, scaledOffsetY);
    return matrix;
  }

  @override
  Widget build(BuildContext context) {
    if (widget._resetSlider == true) {
      _sliderValue = 0.0;
      oldScale = 0.0;
      widget._resetSlider = false;
      print("slider reset");
    }
    print(widget._controller);
    widget._controller.value = _getZoomInfo(
        widget._width,
        widget._height,
        200.0,
        _sliderValue * (4.0 - widget._initialZoom) + widget._initialZoom,
        _sliderValue);
    return Column(
      children: [
        Center(
          child: SizedBox(
            width: 300.0,
            child: Slider(
              value: _sliderValue,
              onChanged: (value) {
                print("issue Slider");
                double sliderZoom =
                    value * (4.0 - widget._initialZoom) + widget._initialZoom;
                setState(() {
                  _sliderValue = value;
                  widget._controller.value = _getZoomInfo(
                      widget._width, widget._height, 200.0, sliderZoom, value);
                  oldScale = value;
                });
              },
            ),
          ),
        ),
        const SizedBox(
          height: 16.0,
        ),
        Center(
          child: Container(
            width: 200.0,
            height: 200.0,
            decoration: BoxDecoration(
              border: Border.all(
                  color: Colors.black87,
                  width: 2,
                  strokeAlign: BorderSide.strokeAlignOutside),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: ClipPath(
                clipper: CircleClipper(),
                clipBehavior: Clip.hardEdge,
                child: InteractiveViewer(
                  transformationController: widget._controller,
                  constrained: false,
                  panEnabled: true,
                  minScale: widget._initialZoom,
                  maxScale: 4.0,
                  onInteractionStart: (ScaleStartDetails details) {},
                  onInteractionUpdate: (ScaleUpdateDetails details) {
                    print("issue IV");
                    Matrix4 matrix = widget._controller.value;
                    offsetX = matrix.entry(0, 3);
                    offsetY = matrix.entry(1, 3);
                    scaleX = matrix.entry(0, 0);
                    scaleY = matrix.entry(1, 1);
                    oldScale = (scaleX - widget._initialZoom) /
                        (4.0 - widget._initialZoom);
                    if (oldScale < 0) oldScale = 0;
                    setState(() {
                      _sliderValue = oldScale;
                    });
                  },
                  onInteractionEnd: (ScaleEndDetails details) {},
                  child: Image.memory(
                    widget._image,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CircleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    print(size);
    return Path()
      ..addOval(Rect.fromCircle(
          center: Offset(size.width / 2, size.height / 2),
          radius: size.width / 2))
      ..fillType = PathFillType.evenOdd;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
