part of 'create_cubit.dart';

enum CreateStatus { initial, submitting, success, failure }

class CreateState extends Equatable {
  const CreateState({@required this.postImage, @required this.caption, @required this.status, @required this.failure});
  final File postImage;
  final String caption;
  final CreateStatus status;
  final Failure failure;

  factory CreateState.initial() {
    return CreateState(
      postImage: null,
      caption: "",
      status: CreateStatus.initial,
      failure: const Failure(),
    );
  }

  @override
  List<Object> get props => [postImage, caption, status, failure];

  CreateState copyWith({File postImage, String caption, CreateStatus status, Failure failure}) {
    return new CreateState(
      postImage: postImage ?? this.postImage,
      caption: caption ?? this.caption,
      status: status ?? this.status,
      failure: failure ?? this.failure,
    );
  }
}
