import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/common/widget/loader.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';
import 'package:flutter_blog_app/core/util/pick_image.dart';
import 'package:flutter_blog_app/core/util/show_snackbar.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/widgets/blog_editor.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keyboard_actions/keyboard_actions.dart';

class NewBlogPage extends StatefulWidget {
  const NewBlogPage({super.key});

  @override
  State<NewBlogPage> createState() => _NewBlogPageState();
}

class _NewBlogPageState extends State<NewBlogPage> {
  final titleController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  final FocusNode _nodeText1 = FocusNode();
  final formKey = GlobalKey<FormState>();

  KeyboardActionsConfig _buildConfig(BuildContext context) {
    return KeyboardActionsConfig(
      keyboardActionsPlatform: KeyboardActionsPlatform.ALL,
      nextFocus: true,
      keyboardBarColor: const Color.fromARGB(255, 0, 0, 0),
      actions: [
        KeyboardActionsItem(
            focusNode: _nodeText1,
            displayActionBar: true,
            displayArrows: false,
            toolbarAlignment: MainAxisAlignment.center,
            toolbarButtons: [
              (node) {
                return QuillToolbar.simple(
                  configurations: QuillSimpleToolbarConfigurations(
                    controller: _controller,
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
                    showJustifyAlignment: false,
                    showHeaderStyle: false,
                    showListNumbers: false,
                    showListBullets: false,
                    showListCheck: false,
                    showQuote: false,
                    showDividers: false,
                    showIndent: false,
                    showLink: false,
                    showUndo: false,
                    showRedo: false,
                    showDirection: false,
                    showSubscript: false,
                    showSuperscript: false,
                    sharedConfigurations: const QuillSharedConfigurations(
                      locale: Locale('de'),
                    ),
                  ),
                );
              }
            ]),
      ],
    );
  }

  File? image;
  List<String> selectedTopics = [];
  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    titleController.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              if (formKey.currentState!.validate() &&
                  selectedTopics.isNotEmpty &&
                  image != null) {
                final posterId =
                    (context.read<AppUserCubit>().state as AppUserLoggedIn)
                        .user
                        .id;
                context.read<BlogBloc>().add(
                      BlogUpload(
                          posterId: posterId,
                          title: titleController.text.trim(),
                          content:
                              _controller.plainTextEditingValue.text.trim(),
                          image: image!,
                          topics: selectedTopics),
                    );
              }
            },
            icon: const Icon(Icons.done_rounded),
          )
        ],
      ),
      body: BlocConsumer<BlogBloc, BlogState>(
        listener: (context, state) {
          if (state is BlogFailure) {
            showSnackBar(context, state.error);
          } else if (state is BlogUploadSuccess) {
            context.pushReplacement('/');
          }
        },
        builder: (context, state) {
          if (state is BlogLoading) {
            return const Loader();
          }
          return KeyboardActions(
            config: _buildConfig(context),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      image != null
                          ? GestureDetector(
                              onTap: selectImage,
                              child: SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(
                                      image!,
                                      fit: BoxFit.cover,
                                    ),
                                  )),
                            )
                          : GestureDetector(
                              onTap: selectImage,
                              child: DottedBorder(
                                color: AppPallete.borderColor,
                                dashPattern: const [10, 4],
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,
                                child: Container(
                                  height: 150,
                                  width: double.infinity,
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.folder_open,
                                        size: 40,
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        'Select your Image',
                                        style: TextStyle(fontSize: 15),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                      const SizedBox(
                        height: 15,
                      ),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            'Technology',
                            'Bussiness',
                            'Programming',
                            'Entertainment',
                          ]
                              .map(
                                (e) => Padding(
                                  padding: const EdgeInsets.all(5.0),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (selectedTopics.contains(e)) {
                                        selectedTopics.remove(e);
                                      } else {
                                        selectedTopics.add(e);
                                      }
                                      setState(() {});
                                    },
                                    child: Chip(
                                      label: Text(e),
                                      color: selectedTopics.contains(e)
                                          ? const MaterialStatePropertyAll(
                                              AppPallete.gradient1)
                                          : null,
                                      side: selectedTopics.contains(e)
                                          ? null
                                          : const BorderSide(
                                              color: AppPallete.borderColor,
                                            ),
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      BlogEditor(
                          controller: titleController, hintText: 'Blog Title'),
                      const SizedBox(
                        height: 15,
                      ),
                      Focus(
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
                              color: _nodeText1.hasFocus
                                  ? AppPallete.gradient2
                                  : AppPallete.borderColor,
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Stack(
                            children: [
                              QuillEditor.basic(
                                focusNode: _nodeText1,
                                configurations: QuillEditorConfigurations(
                                  controller: _controller,
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
                                  sharedConfigurations:
                                      const QuillSharedConfigurations(
                                    locale: Locale('de'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
