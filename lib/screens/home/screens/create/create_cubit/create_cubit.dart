import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/blocs/auth_bloc/auth_bloc.dart';
import 'package:cahubshot/models/models.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:meta/meta.dart';

part 'create_state.dart';

class CreateCubit extends Cubit<CreateState> {
  final PostRepository _postRepository;
  final StorageRepo _storageRepo;
  final AuthBloc _authBloc;
  CreateCubit({
    @required PostRepository postRepository,
    @required StorageRepo storageRepo,
    @required AuthBloc authBloc,
  })  : _postRepository = postRepository,
        _storageRepo = storageRepo,
        _authBloc = authBloc,
        super(CreateState.initial());

  void postImageChanged(File file) {
    emit(state.copyWith(postImage: file, status: CreateStatus.initial));
  }

  void captionChanged(String caption) {
    emit(state.copyWith(caption: caption, status: CreateStatus.initial));
  }

  void reset() {
    emit(CreateState.initial());
  }

  void submit() async {
    emit(state.copyWith(status: CreateStatus.submitting));
    try {
      final author = UserModel.empty.copyWith(id: _authBloc.state.user.uid);
      final postImageUrl = await _storageRepo.uploadPostImageAndGiveUrl(image: state.postImage);
      final caption = state.caption;
      final post = PostModel(
        caption: caption,
        imageUrl: postImageUrl,
        author: author,
        likes: 0,
        dateTime: DateTime.now(),
      );

      _postRepository.createPost(postModel: post);
      emit(state.copyWith(status: CreateStatus.success));
    } catch (err) {
      emit(
        state.copyWith(
          status: CreateStatus.failure,
          failure: const Failure(message: "There was an error creating the post"),
        ),
      );
    }
  }
}
