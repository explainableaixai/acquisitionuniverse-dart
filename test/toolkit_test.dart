import 'package:acquisitionuniverse/acquisitionuniverse.dart';
import 'package:test/test.dart';

void main() {
  test('15 signals', () => expect(signals.length, 15));

  test('group-owned zeroes outreach', () {
    expect(composite(const Company('a', mandateFit: 100, outreachSuitability: 100, transitionContext: 100)), 100);
    expect(composite(const Company('a', mandateFit: 100, outreachSuitability: 100, groupOwned: true)), 70);
  });

  test('rank, coverage and brief', () {
    final r = rank(const [Company('a', mandateFit: 50), Company('b', mandateFit: 90, outreachSuitability: 50)]);
    expect(r.first.key.id, 'b');
    expect(signalCoverage({signals[0]: 'x', signals[1]: null}), (visible: 1, checked: 2));
    final brief = ThesisBrief(vertical: 'Water', regions: ['US']);
    expect(brief.validate().length, 1);
    expect(brief.toText(), contains('free-pilot.php'));
  });
}
