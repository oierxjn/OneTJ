import 'package:onetj/app/presentation/session_aware_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/models/grades_view_data.dart';

class GradesViewModel extends SessionAwareViewModel<UiEvent> {
  GradesViewModel({
    required GradesDataService dataService,
    required super.sessionController,
  }) : _dataService = dataService;

  final GradesDataService _dataService;
  GradesViewData? _viewData;
  int _selectedTermIndex = 0;

  GradesViewData? get viewData => _viewData;
  int get selectedTermIndex => _selectedTermIndex;

  @override
  void clearPersonalData() {
    _viewData = null;
    _selectedTermIndex = 0;
  }

  GradesTerm? get selectedTerm {
    final GradesViewData? data = _viewData;
    if (data == null || data.terms.isEmpty) {
      return null;
    }
    final int index = _selectedTermIndex.clamp(0, data.terms.length - 1);
    return data.terms[index];
  }

  @override
  Future<void> load() async {
    if (isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      await _dataService.warmUpCache();
    } catch (error) {
      emit(
        ShowSnackBarEvent(message: 'Failed to warm cache: $error'),
      );
    }
    try {
      final data = await _dataService.getUndergraduateScore();
      if (isGuest) {
        return;
      }
      _viewData = GradesViewData.fromScoreData(data);
      _selectedTermIndex = 0;
    } catch (error) {
      emit(
        ShowSnackBarEvent(
            message: 'Failed to load grades: ${error.toString()}'),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (isGuest) {
      return;
    }
    loading = true;
    notifyListeners();
    try {
      final data = await _dataService.refreshUndergraduateScore();
      if (isGuest) {
        return;
      }
      _viewData = GradesViewData.fromScoreData(data);
      _selectedTermIndex = 0;
    } catch (error) {
      emit(
        ShowSnackBarEvent(
            message: 'Failed to refresh grades: ${error.toString()}'),
      );
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  void selectTerm(int index) {
    _selectedTermIndex = index;
    notifyListeners();
  }
}