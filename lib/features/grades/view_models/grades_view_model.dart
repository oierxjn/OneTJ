import 'package:onetj/app/presentation/base_view_model.dart';
import 'package:onetj/app/presentation/ui_event.dart';
import 'package:onetj/features/grades/application/grades_data_service.dart';
import 'package:onetj/features/grades/models/grades_view_data.dart';

class GradesViewModel extends BaseViewModel<UiEvent> {
  GradesViewModel({GradesDataService? dataService})
      : _dataService = dataService ?? GradesDataService();

  final GradesDataService _dataService;
  GradesViewData? _viewData;
  int _selectedTermIndex = 0;

  GradesViewData? get viewData => _viewData;
  int get selectedTermIndex => _selectedTermIndex;

  GradesTerm? get selectedTerm {
    final GradesViewData? data = _viewData;
    if (data == null || data.terms.isEmpty) {
      return null;
    }
    final int index = _selectedTermIndex.clamp(0, data.terms.length - 1);
    return data.terms[index];
  }

  Future<void> load() async {
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
    loading = true;
    notifyListeners();
    try {
      final data = await _dataService.refreshUndergraduateScore();
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
