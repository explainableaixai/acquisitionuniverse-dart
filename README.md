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

<!--expanded-->
## A pipeline tool in Flutter

Not every deal team wants a spreadsheet. Some want a small internal app: a list on the left, the evidence on the right, a button to mark a company as called. Flutter is good at that kind of tool, and Dart is a pleasant language for the logic behind it. This package supplies the logic for the screen that matters most, the ranked list, and leaves the rest to your design.

The package depends on nothing but the Dart SDK. It never opens a socket. That keeps it safe to use in an app that handles confidential target names, and it keeps the tests instant.

## A ranked list widget

The simplest useful screen is a list ordered by composite score with the three components visible. Compute the ranking once, outside the build method, and feed the result to a list view.

```dart
class RankedList extends StatelessWidget {
  const RankedList(this.companies, {super.key});
  final List<Company> companies;

  @override
  Widget build(BuildContext context) {
    final ranked = rank(companies);
    return ListView.separated(
      itemCount: ranked.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final c = ranked[i].key;
        return ListTile(
          title: Text(c.id),
          subtitle: Text('fit ${c.mandateFit}  suitability ${c.groupOwned ? 0 : c.outreachSuitability}  context ${c.transitionContext}'),
          trailing: Text(ranked[i].value.toStringAsFixed(1)),
        );
      },
    );
  }
}
```

Showing the suitability as zero for a group owned company, as the example does, teaches users the rule without a manual.

## Letting people move the weights

A slider for each weight turns the list into a conversation. Keep the three sliders in state, normalize them so they add to one, and re-rank on every change. Partners learn quickly which companies hold their place under any reasonable weighting and which ones are artefacts of one setting. The first group is your real shortlist.

Store the chosen weights with the project. A shortlist without the weights that produced it cannot be reproduced.

## Records make the code short

The package uses Dart 3 records for coverage results, so you can destructure them directly:

```dart
final (:visible, :checked) = signalCoverage({
  signals[0]: 'family associated',
  signals[3]: 'service company',
  signals[10]: null,
});
print('$visible of $checked signals visible');
```

Record syntax keeps the call sites tidy, and the compiler checks the field names.

## Evidence first

The most valuable thing about a screened list is the evidence, a quoted sentence and a source page for each claim. Design your screen so the quote is never more than one tap away. A reviewer who can read the sentence that made a company look like a family business trusts the ranking more than one who sees only a score. The package does not store evidence, because your file does. It only helps you order and measure.

## The brief screen

A brief builder screen is a form with eight fields. Validate as the user types, using `validate()`, and show the problems in plain language. Offer a button that copies `toText()` to the clipboard, or opens an email draft. The text ends with the link for requesting a pilot, so a brief written in your app is ready to send to a screening team without editing.

## Offline and private by default

Because nothing in the package uses the network, an app built on it works on a plane. Keep screened files on the device in encrypted storage and sync them only to systems your organisation controls. Target lists are among the most sensitive documents a deal team has. A tool that does not need a server for its logic is a tool you can lock down.

## Further context

The [add-on acquisition radar](https://www.acquisitionuniverse.com/use-cases/add-on-acquisition-radar.php) describes the standing map of eligible companies that tools like this one are built to display. Teams in advertising can look at [cookieless targeting data](https://www.cookielessaudiences.com/features/cookieless-targeting.php) to see how coded attributes describe pages without tracking people, and teams in hiring can read about [resume to JSON conversion](https://www.resumereaderapi.com/) for candidate records.

<!--extra-->
## Vertical signals in a Flutter form

Beyond the fifteen common signals, a screening adds signals that suit your vertical. For automation and controls integrators they include a UL 508A panel shop listing, named PLC platform partnerships, SCADA and HMI scope, in-house panel fabrication and hazardous area experience. For calibration labs they include ISO/IEC 17025 accreditation, a published accreditation scope and the number of accredited disciplines. Model them as a list of name and value pairs on each company, and render them below the common signals in your app. Because the package counts only the fifteen it knows, a vertical signal never inflates the coverage ratio, and you can show a second ratio for the extras.

A closing thought for app builders: the best target list tool is the one the team opens every week. Keep startup fast, keep the first screen focused on the top ten and keep a visible note of when the data was last refreshed. Tools that look current get used, and tools that look stale get abandoned, whatever their features.

<!--further-->
## Further reading and practical notes

The [Dart language site](https://dart.dev/) documents records, patterns, null safety and the Flutter integration used above. For a clear account of how searchers think about sourcing, the [Stanford search fund research pages](https://www.gsb.stanford.edu/faculty-research/centers-initiatives/ces/research/search-funds) are a useful companion.

Some practical notes on building the tool. Keep the list screen fast by ranking once and caching the sorted result until a weight or a record changes. Keep the evidence screen simple: the signal name, the value, the quoted sentence and a link to the source page. Resist the urge to add charts early. A well ordered list with evidence beside each name does more for a deal team than a dashboard of aggregates.

Think about who will use the app. Partners open it for two minutes between meetings, so the first screen should show the top ten and the reason each one is there. Analysts live in it, so they want filters, notes and an export. Callers want a clean list with phone numbers and the one sentence that makes the first call easier. Design three views from the same data, and each audience will treat the app as its own.

Also decide early how the app handles confidentiality. Lists of targets are sensitive. Use device encryption, avoid screenshots of real names in shared channels and keep the data on systems your organisation controls. The package supports that approach, because it never sends anything over a network.

## Common questions

**Does it work on web, mobile and desktop?** Yes, it is pure Dart.

**Is there state management built in?** No. Use the approach you already use.

**Can I extend the signals?** Add your own names and keep a separate count. The package counts only the fifteen it knows.

## Release notes

Version 1.0.0 is the first release. It includes the brief, the composite, the ranking and the coverage function, with tests for each.

## FAQ

**Does it contact a server?** No.

**Dart version?** 3.0 or later, because of records.

**License?** MIT. info@alpha-quantum.com
