import 'package:flutter_test/flutter_test.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/application/diffraction_grating_draft_service.dart';
import 'package:onetj/features/physics_lab/features/diffraction_grating/view_models/diffraction_grating_view_model.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/application/franck_hertz_draft_service.dart';
import 'package:onetj/features/physics_lab/features/franck_hertz/view_models/franck_hertz_view_model.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/application/bohr_twist_pendulum_draft_service.dart';
import 'package:onetj/features/physics_lab/features/bohr_twist_pendulum/view_models/bohr_twist_pendulum_view_model.dart';
import 'package:onetj/features/physics_lab/features/michelson/application/michelson_draft_service.dart';
import 'package:onetj/features/physics_lab/features/michelson/view_models/michelson_interferometer_view_model.dart';
import 'package:onetj/repo/physics_lab_draft_repository.dart';

void main() {
  late InMemoryPhysicsLabDraftStorage storage;
  late MichelsonDraftService michelsonService;
  late DiffractionGratingDraftService diffractionService;
  late FranckHertzDraftService franckHertzService;
  late BohrTwistPendulumDraftService bohrTwistPendulumService;

  setUp(() {
    storage = InMemoryPhysicsLabDraftStorage();
    final PhysicsLabDraftRepository repository =
        PhysicsLabDraftRepository(storage: storage);
    michelsonService = MichelsonDraftService(repository: repository);
    diffractionService = DiffractionGratingDraftService(repository: repository);
    franckHertzService = FranckHertzDraftService(repository: repository);
    bohrTwistPendulumService =
        BohrTwistPendulumDraftService(repository: repository);
  });

  test('MichelsonInterferometerViewModel persists and restores its draft',
      () async {
    final MichelsonInterferometerViewModel first =
        MichelsonInterferometerViewModel(draftService: michelsonService);
    first.updatePositionText(0, '1.0');
    first.updatePositionText(1, '2.0');
    await pumpEventQueue();

    final MichelsonInterferometerViewModel second =
        MichelsonInterferometerViewModel(draftService: michelsonService);
    await second.load();

    expect(second.positionTexts[0], '1.0');
    expect(second.positionTexts[1], '2.0');
    expect(second.positionTexts[2], isEmpty);

    first.dispose();
    second.dispose();
  });

  test('DiffractionGratingViewModel persists and restores its draft', () async {
    final DiffractionGratingViewModel first =
        DiffractionGratingViewModel(draftService: diffractionService);
    first.updateCalibrationReferenceText('546.07');
    first.updateCalibrationReading(0, 0, '159 03');
    first.updateReferenceWavelengthText(0, '435.84');
    await pumpEventQueue();

    final DiffractionGratingViewModel second =
        DiffractionGratingViewModel(draftService: diffractionService);
    await second.load();

    expect(second.calibrationReferenceText, '546.07');
    expect(second.calibrationTexts[0][0], '159 03');
    expect(second.referenceWavelengthTexts[0], '435.84');

    first.dispose();
    second.dispose();
  });

  test('FranckHertzViewModel persists and restores its draft', () async {
    final FranckHertzViewModel first =
        FranckHertzViewModel(draftService: franckHertzService);
    first.updateVfText('2.5');
    first.updateRowVg2kText(0, '12.0');
    first.updateRowIpText(0, '0.32');
    first.addRow();
    await pumpEventQueue();

    final FranckHertzViewModel second =
        FranckHertzViewModel(draftService: franckHertzService);
    await second.load();

    expect(second.metadata.vfText, '2.5');
    expect(second.rows, hasLength(FranckHertzViewModel.defaultRowCount + 1));
    expect(second.rows[0].vg2kText, '12.0');
    expect(second.rows[0].ipText, '0.32');

    first.dispose();
    second.dispose();
  });

  test('BohrTwistPendulumViewModel persists and restores its draft', () async {
    final BohrTwistPendulumViewModel first = BohrTwistPendulumViewModel(
      draftService: bohrTwistPendulumService,
    );
    first.updatePeriodText('1.6');
    first.updatePeriodTableText('1 100 1.5');
    first.updateAmplitudeTableText('1 100 50');
    await pumpEventQueue();

    final BohrTwistPendulumViewModel second = BohrTwistPendulumViewModel(
      draftService: bohrTwistPendulumService,
    );
    await second.load();

    expect(second.periodText, '1.6');
    expect(second.periodTableText, '1 100 1.5');
    expect(second.amplitudeTableText, '1 100 50');

    first.dispose();
    second.dispose();
  });
}
