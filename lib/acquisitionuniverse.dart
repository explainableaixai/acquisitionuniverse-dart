// Local toolkit for acquisition target screening. No network calls.

const pilotUrl = 'https://www.acquisitionuniverse.com/free-pilot.php';

/// The 15 common signals, each recorded with a verbatim quote and a source URL, or "not visible".
const signals = <String>[
  'Founder or family association',
  'Visible leadership bench depth',
  'Operating history and continued independence',
  'Strategic fit to thesis',
  'Geographic and branch footprint',
  'Service-led vs product-led model',
  'Recurring-offering indicators',
  'Vertical specialization and end-market exposure',
  'Acquisition-program or roll-up readiness',
  'Management professionalization',
  'Hiring posture and functional investment',
  'Website and news activity trajectory',
  'Partner and channel ecosystem position',
  'Compliance and regulated-market readiness',
  'Digital-commercial maturity',
];

class Weights {
  const Weights({this.mandateFit = 0.7, this.outreachSuitability = 0.2, this.transitionContext = 0.1});
  final double mandateFit;
  final double outreachSuitability;
  final double transitionContext;
}

class ThesisBrief {
  ThesisBrief({
    this.name = 'Untitled thesis',
    this.vertical = '',
    this.subverticals = const [],
    this.regions = const [],
    this.employeesMin,
    this.employeesMax,
    this.mustHave = const [],
    this.exclusions = const [],
    this.notes = '',
  });

  final String name;
  final String vertical;
  final List<String> subverticals;
  final List<String> regions;
  final int? employeesMin;
  final int? employeesMax;
  final List<String> mustHave;
  final List<String> exclusions;
  final String notes;

  /// Problems that would make the brief ambiguous to a screening team.
  List<String> validate() => [
        if (vertical.isEmpty) 'vertical is empty',
        if (regions.isEmpty) 'no regions listed',
        if (employeesMin != null && employeesMax != null && employeesMin! > employeesMax!)
          'employeesMin is above employeesMax',
        if (exclusions.isEmpty) 'no exclusions listed, group-owned companies are the usual first one',
      ];

  Map<String, dynamic> toJson() => {
        'name': name,
        'vertical': vertical,
        'subverticals': subverticals,
        'regions': regions,
        'employees': {'min': employeesMin, 'max': employeesMax},
        'must_have': mustHave,
        'exclusions': exclusions,
        'notes': notes,
      };

  /// Plain text brief, ready to paste into a pilot request.
  String toText() {
    String list(List<String> v, String sep, String empty) => v.isEmpty ? empty : v.join(sep);
    final size = employeesMin == null && employeesMax == null
        ? 'not specified'
        : '${employeesMin ?? '?'} to ${employeesMax ?? '?'} employees';
    return [
      'Thesis: $name',
      'Vertical: $vertical',
      'Subverticals: ${list(subverticals, ', ', 'all')}',
      'Regions: ${list(regions, ', ', 'not specified')}',
      'Size: $size',
      'Must have: ${list(mustHave, '; ', 'none')}',
      'Exclude: ${list(exclusions, '; ', 'none')}',
      if (notes.isNotEmpty) 'Notes: $notes',
      '',
      'Request a pilot: $pilotUrl',
    ].join('\n');
  }
}

class Company {
  const Company(this.id,
      {this.mandateFit = 0, this.outreachSuitability = 0, this.transitionContext = 0, this.groupOwned = false});
  final String id;
  final double mandateFit;
  final double outreachSuitability;
  final double transitionContext;
  final bool groupOwned;
}

/// Weighted composite on a 0 to 100 scale. A group-owned company scores zero on outreach suitability.
double composite(Company c, [Weights w = const Weights()]) {
  final outreach = c.groupOwned ? 0.0 : c.outreachSuitability;
  final total = w.mandateFit + w.outreachSuitability + w.transitionContext;
  final v = (c.mandateFit * w.mandateFit + outreach * w.outreachSuitability + c.transitionContext * w.transitionContext) / total;
  return (v * 10).round() / 10;
}

/// Companies paired with their composite, highest first.
List<MapEntry<Company, double>> rank(Iterable<Company> companies, [Weights w = const Weights()]) {
  final out = companies.map((c) => MapEntry(c, composite(c, w))).toList();
  out.sort((a, b) => b.value.compareTo(a.value));
  return out;
}

/// Visible and checked counts over the 15 signals; null and "not visible" count as silent.
({int visible, int checked}) signalCoverage(Map<String, String?> found) {
  final known = found.keys.where(signals.contains).toList();
  final visible = known.where((k) => found[k] != null && found[k] != 'not visible').length;
  return (visible: visible, checked: known.length);
}
