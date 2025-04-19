import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/material.dart';

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
  static void _singleParamEntryPoint<T, R>(
    _SingleParamIsolateWrapper<T, R> wrapper,
  ) {
    final result = wrapper.processingFunction(wrapper.singleParam);
    wrapper.resultSendPort.send(result);
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

    await Isolate.spawn(_singleParamEntryPoint<T, R>, isolateParam);
    final result = await receivePort.first;
    return result as T;
  }

  static void _listParamEntryPoint<T, R>(
    _ListParamIsolateWrapper<T, R> wrapper,
  ) {
    List<T> results = [];
    int total = wrapper.listParam.length;
    for (int i = 0; i < total; i++) {
      var item = wrapper.listParam[i];
      results.add(wrapper.processingFunction(item));
      double progress = (i + 1) / total;
      wrapper.progressSendPort.send(progress);
    }
    wrapper.resultSendPort.send(results);
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
    debugPrint('chunks --> ${chunks.map((e) => e.length).toList()}');

    List<ReceivePort> receivePorts = [];
    List<ReceivePort> progressReceivePorts = [];
    List<Isolate> isolates = [];
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
          completedItemsPerChunk[chunkIndex] = (progress * totalItemsPerChunk[chunkIndex]).round();
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
      isolates.add(isolate);
    }

    List<List<T>> chunkResults = [];
    for (var receivePort in receivePorts) {
      try {
        final result = await receivePort.first as List<T>;
        chunkResults.add(result);
      } catch (e) {
        debugPrint('Error receiving result from isolate: $e');
      }
    }

    for (var isolate in isolates) {
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

    return finalResults;
  }
}
