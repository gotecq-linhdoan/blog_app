import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blog_app/core/common/cubit/app_user/app_user_cubit.dart';
import 'package:flutter_blog_app/core/common/widget/loader.dart';
import 'package:flutter_blog_app/core/theme/app_pallete.dart';
import 'package:flutter_blog_app/core/util/delta_hex_color_transform.dart';
import 'package:flutter_blog_app/core/util/keyboard_action.dart';
import 'package:flutter_blog_app/core/util/pick_image.dart';
import 'package:flutter_blog_app/core/util/show_snackbar.dart';
import 'package:flutter_blog_app/features/presentation/blog_bloc/blog_bloc.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/widgets/blog_editor.dart';
import 'package:flutter_blog_app/features/ui/blog_ui/widgets/rich_text.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:keyboard_actions/keyboard_actions.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

class NewBlogPage extends StatefulWidget {
  const NewBlogPage({super.key});

  @override
  State<NewBlogPage> createState() => _NewBlogPageState();
}

class _NewBlogPageState extends State<NewBlogPage> {
  final titleController = TextEditingController();
  final QuillController _controller = QuillController.basic();
  final FocusNode _textNode = FocusNode();
  final formKey = GlobalKey<FormState>();

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
                final deltaJson = deltaHexColorToRGB(
                    deltaJson: _controller.document.toDelta().toJson());
                final converter = QuillDeltaToHtmlConverter(
                    List.castFrom(deltaJson),
                    ConverterOptions.forEmail()
                      ..converterOptions.inlineStylesFlag = true);
                context.read<BlogBloc>().add(
                      BlogUpload(
                          posterId: posterId,
                          title: titleController.text.trim(),
                          content: converter.convert(),
                          contentDelta: jsonEncode(deltaJson),
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
            config: defaultCustomKeyboardConfig(
              context,
              _controller,
              _textNode,
            ),
            autoScroll: true,
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
                                dashPattern: const [10, 8],
                                radius: const Radius.circular(10),
                                borderType: BorderType.RRect,
                                strokeCap: StrokeCap.round,
                                strokeWidth: 3,
                                child: const SizedBox(
                                  height: 150,
                                  width: double.infinity,
                                  child: Column(
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
                                  padding: const EdgeInsets.all(5.0).copyWith(
                                    left: 0,
                                    right: 10,
                                  ),
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
                                      side: BorderSide(
                                        color: selectedTopics.contains(e)
                                            ? AppPallete.gradient1
                                            : AppPallete.borderColor,
                                        width: 3,
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
                      QuillRichText(
                        controller: _controller,
                        textNode: _textNode,
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
