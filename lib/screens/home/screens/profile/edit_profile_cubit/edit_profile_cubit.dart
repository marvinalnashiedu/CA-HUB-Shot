import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:cahubshot/blocs/blocs.dart';
import 'package:cahubshot/models/failure_model.dart';
import 'package:cahubshot/repositories/repositories.dart';
import 'package:meta/meta.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UserRepo _userRepo;
  final StorageRepo _storageRepo;
  final ProfileBloc _profileBloc;
  EditProfileCubit(
      {UserRepo userRepo, StorageRepo storageRepo, ProfileBloc profileBloc})
      : _userRepo = userRepo,
        _storageRepo = storageRepo,
        _profileBloc = profileBloc,
        super(EditProfileState.initial()) {
    final user = _profileBloc.state.userModel;
    emit(
      state.copyWith(
        username: user.username,
        bio: user.bio,
      ),
    );
  }

  void profileImageChanged(File image) {
    emit(
      state.copyWith(profileImage: image, status: EditProfileStatus.initial),
    );
  }

  void usernameChanged(String username) {
    emit(
      state.copyWith(username: username, status: EditProfileStatus.initial),
    );
  }

  void bioChanged(String bio) {
    emit(
      state.copyWith(bio: bio, status: EditProfileStatus.initial),
    );
  }

  void submit() async {
    emit(state.copyWith(status: EditProfileStatus.submitting));
    try {
      final user = _profileBloc.state.userModel;
      var profileImageUrl = user.imageUrl;

      if (state.profileImage != null) {
        profileImageUrl = await _storageRepo.uploadProfileImageAndGiveUrl(
            url: profileImageUrl, image: state.profileImage);
      }

      final updatedUser = user.copyWith(
        username: state.username,
        bio: state.bio,
        imageUrl: profileImageUrl,
      );

      await _userRepo.updateUser(userModel: updatedUser);
      _profileBloc.add(ProfileLoadEvent(userId: user.id));
      emit(state.copyWith(status: EditProfileStatus.success));
    } catch (err) {
      emit(
        state.copyWith(
          status: EditProfileStatus.error,
          failure: const Failure(message: 'Your profile could not be updated.'),
        ),
      );
    }
  }
}
