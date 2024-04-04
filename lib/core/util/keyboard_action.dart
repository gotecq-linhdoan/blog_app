import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

KeyboardActionsConfig defaultCustomKeyboardConfig(
    BuildContext context, QuillController controller, FocusNode textNode) {
  return KeyboardActionsConfig(
    keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
    nextFocus: true,
    keyboardBarColor: const Color.fromARGB(255, 0, 0, 0),
    actions: [
      KeyboardActionsItem(
          focusNode: textNode,
          displayActionBar: true,
          displayArrows: false,
          toolbarAlignment: MainAxisAlignment.center,
          toolbarButtons: [
            (node) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    QuillToolbar.simple(
                      configurations: QuillSimpleToolbarConfigurations(
                        customButtons: [
                          QuillToolbarCustomButtonOptions(
                              icon: Icon(MdiIcons.at),
                              onPressed: () {
                                final currentJson =
                                    controller.document.toDelta().toJson();
                                currentJson.add({'insert': '@ \n'});
                                controller.document =
                                    Document.fromJson(currentJson);
                              }),
                        ],
                        controller: controller,
                        showFontFamily: false,
                        showFontSize: false,
                        showStrikeThrough: false,
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
                        showQuote: true,
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
                ),
              );
            }
          ]),
    ],
  );
}
