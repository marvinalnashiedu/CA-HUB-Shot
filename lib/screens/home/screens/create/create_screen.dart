import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cahubshot/helpers/helpers.dart';
import 'package:cahubshot/widgets/error_dialog.dart';
import 'package:cahubshot/widgets/loading_dialog.dart';
import 'package:image_cropper/image_cropper.dart';

import 'create_cubit/create_cubit.dart';

class CreateScreen extends StatelessWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Create Post", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.blueAccent,
        ),
        body: BlocConsumer<CreateCubit, CreateState>(
          listener: (context, createPostState) {
            if (createPostState.status == CreateStatus.success) {
              Navigator.of(context, rootNavigator: true).pop();
              _formKey.currentState.reset();
              context.read<CreateCubit>().reset();

              BotToast.showText(text: "Post Created Successfully");
            } else if (createPostState.status == CreateStatus.submitting) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => LoadingDialog(
                  loadingMessage: 'Creating Post',
                ),
              );
            } else if (createPostState.status == CreateStatus.failure) {
              Navigator.of(context, rootNavigator: true).pop();
              BotToast.showText(text: createPostState.failure.message);

              showDialog(
                context: context,
                builder: (context) => ErrorDialog(
                  message: createPostState.failure.message,
                ),
              );
            }
          },
          builder: (context, createPostState) {
            return SingleChildScrollView(
              child: GestureDetector(
                onTap: () => _selectPostImage(context),
                child: Column(
                  children: [
                    if (createPostState.status == CreateStatus.submitting) LinearProgressIndicator(),
                    Container(
                      height: MediaQuery.of(context).size.height / 2,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: createPostState.postImage != null
                          ? Container(
                              child: Image.file(
                                createPostState.postImage,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: 120,
                            ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(24),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              decoration: InputDecoration(hintText: "caption"),
                              onChanged: (value) {
                                context.read<CreateCubit>().captionChanged(value);
                              },
                              validator: (value) {
                                return value.trim().isEmpty ? 'The caption must not be empty' : null;
                              },
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context).primaryColor,
                                elevation: 1.0,
                              ),
                              onPressed: () => _submitForm(
                                context,
                                createPostState.postImage,
                                createPostState.status == CreateStatus.submitting,
                              ),
                              child: Text(
                                'Create Post',
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _selectPostImage(BuildContext context) async {
    final pickedFile = await ImageHelper.pickImageFromGallery(
      context: context,
      cropStyle: CropStyle.rectangle,
      title: 'Post Image',
    );
    if (pickedFile != null) {
      context.read<CreateCubit>().postImageChanged(pickedFile);
    }
  }

  void _submitForm(BuildContext context, File postImage, bool isSubmitting) async {
    if (_formKey.currentState.validate() && postImage != null && !isSubmitting) {
      context.read<CreateCubit>().submit();
    }
  }
}
