import 'dart:convert';
import 'dart:io' as io show File;
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/extensions.dart' show isAndroid, isIOS, isWeb;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:path/path.dart' as path;
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

KeyboardActionsConfig defaultCustomKeyboardConfig(
  BuildContext context,
  QuillController controller,
  FocusNode textNode,
) {
  Future<String> saveImage(io.File file) async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final fileExt = path.extension(file.path);
    final newFileName = '${DateTime.now().toIso8601String()}$fileExt';
    final newPath = path.join(
      appDocDir.path,
      newFileName,
    );
    final copiedFile = await file.copy(newPath);
    return copiedFile.path;
  }

  Future<void> onImageInsertWithCropping(
    String image,
    QuillController controller,
    BuildContext context,
  ) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: image,
      aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9
      ],
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Cropper',
          toolbarColor: Colors.deepOrange,
          toolbarWidgetColor: Colors.white,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Cropper',
        ),
        WebUiSettings(
          context: context,
        ),
      ],
    );
    final newImage = croppedFile?.path;
    if (newImage == null) {
      return;
    }
    if (isWeb()) {
      controller.insertImageBlock(imageSource: newImage);
      return;
    }
    final newSavedImage = await saveImage(io.File(newImage));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  Future<void> onImageInsert(String image, QuillController controller) async {
    if (isWeb() || isHttpBasedUrl(image)) {
      controller.insertImageBlock(imageSource: image);
      return;
    }
    final newSavedImage = await saveImage(io.File(image));
    controller.insertImageBlock(imageSource: newSavedImage);
  }

  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
    nextFocus: true,
    keyboardBarColor: const Color.fromARGB(255, 0, 0, 0),
    actions: [
      KeyboardActionsItem(
          focusNode: textNode,
          displayArrows: false,
          toolbarAlignment: MainAxisAlignment.center,
          toolbarButtons: [
            (node) {
              return ListView(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                children: [
                  QuillToolbar.simple(
                    configurations: QuillSimpleToolbarConfigurations(
                      customButtons: [
                        QuillToolbarCustomButtonOptions(
                          icon: Icon(MdiIcons.at),
                          onPressed: () {
                            final currentJsonString = jsonEncode(
                                controller.document.toDelta().toJson());
                            int lastNewLine =
                                currentJsonString.lastIndexOf('\\n');
                            String newJsonString =
                                "${currentJsonString.substring(0, lastNewLine)}@${currentJsonString.substring(lastNewLine)}";
                            controller.document =
                                Document.fromJson(jsonDecode(newJsonString));
                            controller.moveCursorToEnd();
                          },
                        ),
                      ],
                      embedButtons: FlutterQuillEmbeds.toolbarButtons(
                        imageButtonOptions: QuillToolbarImageButtonOptions(
                          imageButtonConfigurations:
                              QuillToolbarImageConfigurations(
                            onImageInsertCallback:
                                isAndroid(supportWeb: false) ||
                                        isIOS(supportWeb: false) ||
                                        isWeb()
                                    ? (image, controller) =>
                                        onImageInsertWithCropping(
                                            image, controller, context)
                                    : onImageInsert,
                          ),
                        ),
                      ),
                      controller: controller,
                      showFontFamily: false,
                      showFontSize: false,
                      showStrikeThrough: false,
                      showBackgroundColorButton: false,
                      showInlineCode: false,
                      showColorButton: false,
                      showClearFormat: false,
                      showAlignmentButtons: false,
                      showLeftAlignment: false,
                      showCenterAlignment: false,
                      showRightAlignment: false,
                      showSearchButton: false,
                      showJustifyAlignment: false,
                      showHeaderStyle: false,
                      showListNumbers: false,
                      showListBullets: false,
                      showListCheck: false,
                      showQuote: false,
                      showDividers: false,
                      showIndent: false,
                      showCodeBlock: false,
                      showUndo: false,
                      showRedo: false,
                      showDirection: false,
                      showSubscript: false,
                      showSuperscript: false,
                      sharedConfigurations: const QuillSharedConfigurations(
                        locale: Locale('de'),
                      ),
                    ),
                  ),
                ],
              );
            }
          ]),
    ],
  );
}
