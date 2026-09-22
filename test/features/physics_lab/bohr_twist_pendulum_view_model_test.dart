import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/view_models/bohr_twist_pendulum_view_model.dart';

void main() {
  group('BohrTwistPendulumViewModel', () {
    test('starts with default preset values and a complete result', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      expect(
          viewModel.periodText, BohrTwistPendulumViewModel.defaultPeriodText);
      expect(
        viewModel.periodTableText,
        BohrTwistPendulumViewModel.defaultPeriodTableText,
      );
      expect(
        viewModel.amplitudeTableText,
        BohrTwistPendulumViewModel.defaultAmplitudeTableText,
      );
      expect(viewModel.hasAnyInput, isTrue);

      final result = viewModel.result;
      expect(result.hasCompleteResult, isTrue);
      expect(result.averagePeriod, closeTo(1.5626, 1e-9));
      expect(result.logMethodBeta, closeTo(0.0689775, 1e-4));
      expect(result.graphicalBeta, closeTo(0.0688465, 1e-4));

      viewModel.dispose();
    });

    test('averages the third column of the period table', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel
          .updatePeriodTableText('1 100 1.5000\n2 101 1.6000\n3 102 1.7000');

      expect(viewModel.result.averagePeriod, closeTo(1.6, 1e-9));

      viewModel.dispose();
    });

    test('falls back to the single period when the period table is empty', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.updatePeriodTableText('');
      viewModel.updatePeriodText('1.5700');

      final result = viewModel.result;
      expect(result.averagePeriod, closeTo(1.57, 1e-9));
      expect(result.logMethodBeta, isNotNull);
      expect(result.graphicalBeta, isNotNull);

      viewModel.dispose();
    });

    test('ignores trailing tokens that do not form a full row', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.updatePeriodTableText(
        '1 100 1.5000\n2 101 1.6000\n3 102',
      );

      expect(viewModel.result.averagePeriod, closeTo(1.55, 1e-9));

      viewModel.dispose();
    });

    test('returns an incomplete result when inputs are empty', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.clearAll();

      final result = viewModel.result;
      expect(result.averagePeriod, isNull);
      expect(result.logMethodBeta, isNull);
      expect(result.graphicalBeta, isNull);
      expect(result.hasCompleteResult, isFalse);
      expect(viewModel.hasAnyInput, isFalse);

      viewModel.dispose();
    });

    test('returns an incomplete result when the period is invalid', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.updatePeriodTableText('');
      viewModel.updatePeriodText('abc');

      final result = viewModel.result;
      expect(result.averagePeriod, isNull);
      expect(result.logMethodBeta, isNull);
      expect(result.graphicalBeta, isNull);

      viewModel.dispose();
    });

    test('returns an incomplete result when the amplitude table is invalid',
        () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.updateAmplitudeTableText('abc def ghi');

      final result = viewModel.result;
      expect(result.averagePeriod, isNotNull);
      expect(result.logMethodBeta, isNull);
      expect(result.graphicalBeta, isNull);
      expect(result.hasCompleteResult, isFalse);

      viewModel.dispose();
    });

    test('updates input fields', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.updatePeriodText('1.6');
      viewModel.updatePeriodTableText('1 1 1.5');
      viewModel.updateAmplitudeTableText('1 100 50');

      expect(viewModel.periodText, '1.6');
      expect(viewModel.periodTableText, '1 1 1.5');
      expect(viewModel.amplitudeTableText, '1 100 50');

      viewModel.dispose();
    });

    test('clearAll resets all fields to empty', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.clearAll();

      expect(viewModel.periodText, isEmpty);
      expect(viewModel.periodTableText, isEmpty);
      expect(viewModel.amplitudeTableText, isEmpty);

      viewModel.dispose();
    });

    test('applyDefaultPreset restores the preset values', () {
      final BohrTwistPendulumViewModel viewModel = BohrTwistPendulumViewModel();

      viewModel.clearAll();
      viewModel.applyDefaultPreset();

      expect(
          viewModel.periodText, BohrTwistPendulumViewModel.defaultPeriodText);
      expect(
        viewModel.periodTableText,
        BohrTwistPendulumViewModel.defaultPeriodTableText,
      );
      expect(
        viewModel.amplitudeTableText,
        BohrTwistPendulumViewModel.defaultAmplitudeTableText,
      );

      viewModel.dispose();
    });
  });
}
