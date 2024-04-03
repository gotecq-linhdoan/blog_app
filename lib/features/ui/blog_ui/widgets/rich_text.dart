import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';
import 'package:flutter_blog_app/foundation/model/blog_model/fake_user.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/intl.dart' as intl;

class QuillRichText extends StatefulWidget {
  final QuillController controller;
  final FocusNode textNode;
  const QuillRichText({
    super.key,
    required this.controller,
    required this.textNode,
  });

  @override
  State<QuillRichText> createState() => _QuillRichTextState();
}

class _QuillRichTextState extends State<QuillRichText> {
  bool _isEditorLTR = true;
  String? _taggingCharector = '#';
  OverlayEntry? _hashTagOverlayEntry;
  int? lastHashTagIndex = -1;
  ValueNotifier<List<AtMentionSearchResponseBean>> atMentionSearchList =
      ValueNotifier([]);

  final _tempAtMentionList = [
    AtMentionSearchResponseBean(
        firstName: 'Tom', userName: 'tom123', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Jeck', userName: 'jack', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Mical', userName: 'mical_mishra', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Obama', userName: 'obama_fans', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Putin', userName: 'putin', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Modi', userName: 'modi', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Targen', userName: 'targen', id: '80935823948569'),
    AtMentionSearchResponseBean(
        firstName: 'Tommy', userName: 'tomi_', id: '80935823948569'),
  ];

  Future<void> _getAtMentionSearchList(String? query) async {
    /// you can call api here to get the list
    try {
      atMentionSearchList.value = _tempAtMentionList;
    } catch (e) {
      print('Exception in _getAtMentionSearchList : $e');
    }
  }

  void _refreshScreen() {
    if (mounted) {
      setState(() {});
    }
  }

  void _checkEditorTextDirection(String text) {
    try {
      var _isRTL = intl.Bidi.detectRtlDirectionality(text);
      var style = widget.controller.getSelectionStyle();
      var attribute = style.attributes[Attribute.align.key];
      // print(attribute);
      if (_isEditorLTR) {
        if (_isEditorLTR != !_isRTL) {
          if (_isRTL) {
            _isEditorLTR = false;
            widget.controller
                .formatSelection(Attribute.clone(Attribute.align, null));
            widget.controller.formatSelection(Attribute.rightAlignment);
            _refreshScreen();
          } else {
            var validCharacters = RegExp(r'^[a-zA-Z]+$');
            if (validCharacters.hasMatch(text)) {
              _isEditorLTR = true;
              widget.controller
                  .formatSelection(Attribute.clone(Attribute.align, null));
              widget.controller.formatSelection(Attribute.leftAlignment);
              _refreshScreen();
            }
          }
        } else {
          if (attribute == null && _isRTL) {
            _isEditorLTR = false;
            widget.controller
                .formatSelection(Attribute.clone(Attribute.align, null));
            widget.controller.formatSelection(Attribute.rightAlignment);
            _refreshScreen();
          } else if (attribute == Attribute.rightAlignment && !_isRTL) {
            var validCharacters = RegExp(r'^[a-zA-Z]+$');
            if (validCharacters.hasMatch(text)) {
              _isEditorLTR = true;
              widget.controller!
                  .formatSelection(Attribute.clone(Attribute.align, null));
              widget.controller!.formatSelection(Attribute.leftAlignment);
              _refreshScreen();
            }
          }
        }
      }
    } catch (e) {
      print('Exception in _checkEditorTextDirection : $e');
    }
  }

  void _advanceTextFocusListener() {
    if (!widget.textNode.hasPrimaryFocus) {
      if (_hashTagOverlayEntry != null) {
        if (_hashTagOverlayEntry!.mounted) {
          _removeOverLay();
        }
      }
    }
  }

  void editorListener() {
    try {
      final index = widget.controller.selection.baseOffset;
      var value = widget.controller.plainTextEditingValue.text;
      if (value.trim().isNotEmpty) {
        var newString = value.substring(index - 1, index);

        if (newString != ' ' && newString != '\n') {
          _checkEditorTextDirection(newString);
        }
        if (newString == '\n') {
          _isEditorLTR = true;
        }

        if (newString == '@') {
          _taggingCharector = '@';
          if (_hashTagOverlayEntry == null &&
              !(_hashTagOverlayEntry?.mounted ?? false)) {
            lastHashTagIndex = widget.controller.selection.baseOffset;
            _hashTagOverlayEntry = _createHashTagOverlayEntry();
            Overlay.of(context).insert(_hashTagOverlayEntry!);
          }
        }

        if ((newString == ' ' || newString == '\n') &&
            _hashTagOverlayEntry != null &&
            _hashTagOverlayEntry!.mounted) {
          _removeOverLay();
          if (lastHashTagIndex != -1 && index > lastHashTagIndex!) {
            var newWord = value.substring(lastHashTagIndex!, index);
            _onTapOverLaySuggestionItem(newWord.trim());
          }
        }
        if (lastHashTagIndex != -1 &&
            _hashTagOverlayEntry != null &&
            (_hashTagOverlayEntry?.mounted ?? false)) {
          var newWord = value
              .substring(lastHashTagIndex!, value.length)
              .replaceAll('\n', '');

          if (_taggingCharector == '@') {
            _getAtMentionSearchList(newWord.toLowerCase());
          }
        }
      }
    } catch (e) {
      print('Exception in catching last charector : $e');
    }
  }

  void _removeOverLay() {
    try {
      if (_hashTagOverlayEntry != null && _hashTagOverlayEntry!.mounted) {
        _hashTagOverlayEntry!.remove();
        _hashTagOverlayEntry = null;
        atMentionSearchList.value = <AtMentionSearchResponseBean>[];
      }
    } catch (e) {
      print('Exception in removing overlay :$e');
    }
  }

  void _onTapOverLaySuggestionItem(String value, {String? userId}) {
    var _lastHashTagIndex = lastHashTagIndex;
    widget.controller!.replaceText(
        _lastHashTagIndex!,
        widget.controller!.selection.extentOffset - _lastHashTagIndex,
        value,
        null);
    widget.controller!.updateSelection(
        TextSelection(
            baseOffset: _lastHashTagIndex - 1,
            extentOffset: widget.controller!.selection.extentOffset +
                (value.length -
                    (widget.controller!.selection.extentOffset -
                        _lastHashTagIndex))),
        ChangeSource.local);
    if (_taggingCharector == '#') {
      /// You can add your own web site
      widget.controller.formatSelection(
          LinkAttribute('https://www.google.com/search?q=$value'));
    } else {
      /// You can add your own web site
      widget.controller.formatSelection(
          LinkAttribute('https://www.google.com/search?q=$userId'));
    }
    Future.delayed(Duration.zero).then((value) {
      widget.controller.moveCursorToEnd();
    });
    lastHashTagIndex = -1;
    widget.controller!.document
        .insert(widget.controller!.selection.extentOffset, ' ');
    Future.delayed(Duration(seconds: 1)).then((value) => _removeOverLay());
    atMentionSearchList.value = <AtMentionSearchResponseBean>[];
  }

  OverlayEntry _createHashTagOverlayEntry() {
    return OverlayEntry(
        builder: (context) => Positioned(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              width: MediaQuery.of(context).size.width,
              child: Material(
                elevation: 4.0,
                child: Container(
                  constraints:
                      const BoxConstraints(maxHeight: 150, minHeight: 50),
                  child: ValueListenableBuilder(
                    valueListenable: atMentionSearchList,
                    builder: (BuildContext context,
                        List<AtMentionSearchResponseBean> value,
                        Widget? child) {
                      return ListView.builder(
                        padding: EdgeInsets.zero,
                        itemCount: value.length,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          var data = value[index];
                          return GestureDetector(
                            onTap: () {
                              _onTapOverLaySuggestionItem(data.userName!,
                                  userId: data.userName);
                            },
                            child: ListTile(
                              leading: CachedNetworkImage(
                                imageUrl: data.pictureLink ?? '',
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  height: 30,
                                  width: 30,
                                  decoration: BoxDecoration(
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                      shape: BoxShape.circle),
                                ),
                                placeholder: (context, url) => Container(
                                  height: 30,
                                  width: 30,
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      shape: BoxShape.circle),
                                  width: 30,
                                  height: 30,
                                  child: const Icon(
                                    Icons.image_outlined,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              title: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data.firstName!,
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(
                                    height: 3,
                                  ),
                                  Text(
                                    '@${data.userName}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ));
  }

  @override
  void dispose() {
    super.dispose();
    void _advanceTextFocusListener() {
      if (!widget.textNode.hasPrimaryFocus) {
        if (_hashTagOverlayEntry != null) {
          if (_hashTagOverlayEntry!.mounted) {
            _removeOverLay();
          }
        }
      }
      widget.controller.removeListener(editorListener);
      widget.textNode.removeListener(_advanceTextFocusListener);
    }
  }

  @override
  void initState() {
    widget.controller.addListener(editorListener);
    widget.textNode.addListener(_advanceTextFocusListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      child: Focus(
        onFocusChange: (hasFocus) {
          if (!hasFocus) {
            setState(() {});
          } else {
            setState(() {});
          }
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: widget.textNode.hasFocus
                  ? AppPallete.gradient2
                  : AppPallete.borderColor,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Stack(
            children: [
              QuillEditor.basic(
                focusNode: widget.textNode,
                configurations: QuillEditorConfigurations(
                  controller: widget.controller,
                  customStyles: const DefaultStyles(
                    placeHolder: DefaultListBlockStyle(
                        TextStyle(
                          fontSize: 16.2,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                        VerticalSpacing(0, 0),
                        VerticalSpacing(0, 0),
                        null,
                        null),
                  ),
                  placeholder: 'Blog Content',
                  readOnly: false,
                  padding: const EdgeInsets.all(25),
                  keyboardAppearance: Brightness.dark,
                  minHeight: 200,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
