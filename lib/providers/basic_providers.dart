import 'package:flutter_riverpod/flutter_riverpod.dart';

final scaleProvider = StateProvider<double>((ref) => 1.0);
final jwtTokenProvider = StateProvider<String>((ref) => "");
final userNameProvider = StateProvider<String>((ref) => "");