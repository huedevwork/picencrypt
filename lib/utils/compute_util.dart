import 'dart:async';
import 'dart:io';
import 'dart:isolate';

class _SingleParamIsolateWrapper<T, R> {
  final R singleParam;
  final T Function(R) processingFunction;
  final SendPort resultSendPort;

  _SingleParamIsolateWrapper({
    required this.singleParam,
    required this.processingFunction,
    required this.resultSendPort,
  });
}

class _ListParamIsolateWrapper<T, R> {
  final List<R> listParam;
  final T Function(R) processingFunction;
  final SendPort resultSendPort;
  final SendPort progressSendPort;

  _ListParamIsolateWrapper({
    required this.listParam,
    required this.processingFunction,
    required this.resultSendPort,
    required this.progressSendPort,
  });
}

class ComputeUtil {
  static List<Isolate> _activeIsolates = [];

  static void _singleParamEntryPoint<T, R>(
    _SingleParamIsolateWrapper<T, R> wrapper,
  ) {
    try {
      final result = wrapper.processingFunction(wrapper.singleParam);
      wrapper.resultSendPort.send({
        'type': 'success',
        'data': result,
      });
    } catch (e, s) {
      wrapper.resultSendPort.send({
        'type': 'error',
        'error': e.toString(),
        'stackTrace': s.toString(),
      });
    }
  }

  static Future<T> handle<T, R>({
    required R param,
    required T Function(R) processingFunction,
  }) async {
    final receivePort = ReceivePort();

    final isolateParam = _SingleParamIsolateWrapper<T, R>(
      singleParam: param,
      processingFunction: processingFunction,
      resultSendPort: receivePort.sendPort,
    );

    final isolate = await Isolate.spawn(
      _singleParamEntryPoint<T, R>,
      isolateParam,
    );
    _activeIsolates.add(isolate);

    final resultMap = await receivePort.first as Map<String, dynamic>;

    _activeIsolates.remove(isolate);

    isolate.kill(priority: Isolate.immediate);

    if (resultMap['type'] == 'error') {
      throw Exception('${resultMap['error']}\n${resultMap['stackTrace']}');
    }

    return resultMap['data'] as T;
  }

  static void _listParamEntryPoint<T, R>(
    _ListParamIsolateWrapper<T, R> wrapper,
  ) {
    List<T> results = [];
    int total = wrapper.listParam.length;
    try {
      for (int i = 0; i < total; i++) {
        var item = wrapper.listParam[i];
        results.add(wrapper.processingFunction(item));
        double progress = (i + 1) / total;
        wrapper.progressSendPort.send(progress);
      }
      wrapper.resultSendPort.send({
        'type': 'success',
        'data': results,
      });
    } catch (e, s) {
      wrapper.resultSendPort.send({
        'type': 'error',
        'error': e.toString(),
        'stackTrace': s.toString(),
      });
    }
  }

  static Future<List<T>> handleList<T, R>({
    int? isolateCount,
    required List<R> param,
    required T Function(R) processingFunction,
    Function(double)? progressCallback,
  }) async {
    int cpuCores = Platform.numberOfProcessors;
    isolateCount ??= 2;
    int upperBound = (cpuCores - 2).clamp(1, double.infinity).toInt();
    isolateCount = isolateCount.clamp(1, upperBound);

    int chunkSize = (param.length / isolateCount).ceil();
    List<List<R>> chunks = [];
    for (int i = 0; i < param.length; i += chunkSize) {
      int end = (i + chunkSize).clamp(0, param.length);
      chunks.add(param.sublist(i, end));
    }
    // debugPrint('chunks --> ${chunks.map((e) => e.length).toList()}');

    List<ReceivePort> receivePorts = [];
    List<ReceivePort> progressReceivePorts = [];
    _activeIsolates = [];
    List<int> totalItemsPerChunk = chunks.map((chunk) => chunk.length).toList();
    List<int> completedItemsPerChunk = List.filled(chunks.length, 0);

    for (var chunk in chunks) {
      final receivePort = ReceivePort();
      receivePorts.add(receivePort);

      final progressReceivePort = ReceivePort();
      progressReceivePorts.add(progressReceivePort);

      progressReceivePort.listen((progress) {
        if (progress is double) {
          int chunkIndex = progressReceivePorts.indexOf(progressReceivePort);
          int count = (progress * totalItemsPerChunk[chunkIndex]).round();
          completedItemsPerChunk[chunkIndex] = count;
          int totalCompleted = completedItemsPerChunk.reduce((a, b) => a + b);
          int totalItems = totalItemsPerChunk.reduce((a, b) => a + b);
          double overallProgress = totalCompleted / totalItems;
          progressCallback?.call(overallProgress);
        }
      });

      final isolateParam = _ListParamIsolateWrapper<T, R>(
        listParam: chunk,
        processingFunction: processingFunction,
        resultSendPort: receivePort.sendPort,
        progressSendPort: progressReceivePort.sendPort,
      );

      final isolate = await Isolate.spawn(
        _listParamEntryPoint<T, R>,
        isolateParam,
      );
      _activeIsolates.add(isolate);
    }

    List<List<T>> chunkResults = [];
    for (var receivePort in receivePorts) {
      final resultMap = await receivePort.first as Map<String, dynamic>;
      if (resultMap['type'] == 'error') {
        throw Exception('${resultMap['error']}\n${resultMap['stackTrace']}');
      }
      chunkResults.add(resultMap['data'] as List<T>);
    }

    for (var isolate in _activeIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }

    for (var receivePort in receivePorts) {
      receivePort.close();
    }

    for (var progressReceivePort in progressReceivePorts) {
      progressReceivePort.close();
    }

    List<T> finalResults = [];
    for (var chunkResult in chunkResults) {
      finalResults.addAll(chunkResult);
    }

    _activeIsolates.clear();
    return finalResults;
  }

  static void killAllIsolates() {
    for (var isolate in _activeIsolates) {
      isolate.kill(priority: Isolate.immediate);
    }
    _activeIsolates.clear();
  }
}
