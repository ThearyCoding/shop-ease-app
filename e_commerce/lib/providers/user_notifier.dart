import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_model.dart';
import '../services/apis/user_api.dart';

class UserNotifier extends StateNotifier<User> {
  final UserApi _userApi;
  UserNotifier(this._userApi) : super(User.emptyJson());

  Future<void> fetchUser() async {
    final user = await _userApi.fetchUser();
    state = user ?? User.emptyJson();
  }
}

final userNotifierProvider = StateNotifierProvider<UserNotifier, User>((ref) {
  final api = ref.read(userApiProvider);
  return UserNotifier(api);
});
