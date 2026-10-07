# acquisitionuniverse for Dart

Dart helpers for acquisition teams: a thesis brief builder, a composite score that puts independent owners first, ranking, and signal coverage. Works in Flutter apps, command line tools and servers. Pure Dart, no packages beyond the SDK.

```yaml
dependencies:
  acquisitionuniverse: ^1.0.0
```

## The idea

An [add-on acquisition radar](https://www.acquisitionuniverse.com/use-cases/add-on-acquisition-radar.php) is only useful if somebody opens it every week. A small internal app that shows the ranked list, the gaps and the brief keeps the radar alive. These functions are the logic for that app.

## Build a brief

```dart
import 'package:acquisitionuniverse/acquisitionuniverse.dart';

final brief = ThesisBrief(
  name: 'Managed IT, Texas',
  vertical: 'Managed IT services',
  regions: ['Texas'],
  employeesMin: 10,
  employeesMax: 50,
  exclusions: ['group-owned', 'resellers only'],
);

print(brief.validate());   // []
print(brief.toText());
```

The text output ends with a link for requesting a pilot, so the brief is ready to send as written.

## Rank companies

```dart
final ranked = rank(const [
  Company('A', mandateFit: 90, outreachSuitability: 80, transitionContext: 50),
  Company('B', mandateFit: 96, outreachSuitability: 90, transitionContext: 70, groupOwned: true),
]);

for (final entry in ranked) {
  print('${entry.key.id}: ${entry.value}');
}
```

Company B is group-owned, so its outreach component becomes zero and A leads.

Use a different balance with `Weights`:

```dart
rank(companies, const Weights(mandateFit: 0.6, outreachSuitability: 0.3, transitionContext: 0.1));
```

## Signal coverage

```dart
final result = signalCoverage({
  signals[0]: 'founder led',
  signals[2]: 'since 1988',
  signals[10]: null,
});
print('${result.visible} of ${result.checked}');
```

The return value is a record, so `result.visible` and `result.checked` are typed ints.

## Flutter widget idea

```dart
ListView(
  children: [
    for (final e in rank(companies))
      ListTile(title: Text(e.key.id), trailing: Text(e.value.toStringAsFixed(1))),
  ],
)
```

## Members

| Name | Type |
|---|---|
| `ThesisBrief` | class with `validate`, `toJson`, `toText` |
| `Company` | const class for scores |
| `Weights` | const class, defaults 0.7, 0.2, 0.1 |
| `composite`, `rank`, `signalCoverage` | functions |
| `signals` | list of 15 names |
| `pilotUrl` | string |

## Same publisher, different problems

If you work with web audiences, look at [cookieless targeting](https://www.cookielessaudiences.com/features/cookieless-targeting.php) data. If you handle CVs, a [resume to JSON](https://www.resumereaderapi.com/) service is available from the same company.

## FAQ

**Does it contact a server?** No.

**Dart version?** 3.0 or later, because of records.

**License?** MIT. info@alpha-quantum.com
