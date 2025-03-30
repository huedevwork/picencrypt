import 'dart:async';
import 'dart:io';

import 'package:isolate/isolate.dart';

class ComputeUtil {
  static final ComputeUtil _instance = ComputeUtil._internal();
  LoadBalancer? _lb;

  ComputeUtil._internal();

  static Future<T> handle<T, R>({
    int? size,
    required R params,
    required T Function(R) entryLogic,
  }) async {
    int cpuCores = Platform.numberOfProcessors;
    size ??= 1;
    int upperBound = (cpuCores - 2).clamp(1, double.infinity).toInt();
    size = size.clamp(1, upperBound);
    _instance._lb ??= await LoadBalancer.create(size, IsolateRunner.spawn);
    T result = await _instance._lb!.run<T, R>(entryLogic, params);
    return result;
  }
}
