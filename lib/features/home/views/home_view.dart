import 'package:flutter/material.dart';
import 'dart:async';

import 'package:onetj/features/home/view_models/home_view_model.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late final HomeViewModel _viewModel;
  StreamSubscription<String>? _infoSub;
  StreamSubscription<Object>? _errorSub;
  String? _studentInfo;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _viewModel = HomeViewModel();
    _infoSub = _viewModel.studentInfo.listen((data) {
      if (!mounted) return;
      setState(() {
        _studentInfo = data;
        _error = null;
        _loading = false;
      });
    });
    _errorSub = _viewModel.errors.listen((error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _loading = false;
      });
    });
    _viewModel.loadStudentInfo();
  }

  @override
  void dispose() {
    _infoSub?.cancel();
    _errorSub?.cancel();
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (_loading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (_error != null) {
      body = Center(
        child: Text('Failed to load student info: $_error'),
      );
    } else {
      final String data = _studentInfo ?? '';
      body = SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SelectableText(data.isEmpty ? 'No data' : data),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: body,
    );
  }
}
