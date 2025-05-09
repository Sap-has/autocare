// lib/pages/suggestion/services/repairpal_service.dart
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

/// One named repair problem + its cost-ranges
class RepairIssue {
  final String title;
  final String description;
  final String detailUrl;
  String averageMileage;
  List<Solution> solutions;

  RepairIssue({
    required this.title,
    required this.description,
    required this.detailUrl,
    this.averageMileage = '',
    this.solutions     = const [],
  });
}

/// One discrete solution & its cost range
class Solution {
  final String name;
  final String costRange;

  Solution({required this.name, required this.costRange});
}

class RepairPalService {
  /// Returns a list of RepairIssue scraped from RepairPal
  static Future<List<RepairIssue>> fetchCarIssuesDetailed({
    required String make,
    required String model,
    required String year,
  }) async {
    final mk = make.trim().toLowerCase();
    final md = model.trim().toLowerCase();
    final yr = year.trim();

    // 1) List page: common issues
    final uri = Uri.parse('https://repairpal.com/cars/$mk/$md/$yr');
    final resp = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    if (resp.statusCode != 200) {
      throw Exception('Failed to load issues (HTTP ${resp.statusCode})');
    }
    final doc = parse(resp.body);

    final commonHeadings = doc
        .querySelectorAll('h2')
        .where((h2) => h2.text.trim().startsWith('Most Common'));
    if (commonHeadings.isEmpty) return [];
    final commonHeading = commonHeadings.first;

    // Build initial list of problems (with detailUrl)
    final issues = <RepairIssue>[];
    dom.Element? sib = commonHeading.nextElementSibling;
    while (sib != null && sib.localName != 'h2') {
      for (var a in sib.querySelectorAll('a[href]')) {
        final txt = a.text.trim();
        if (txt.startsWith('See More')) continue;
        final href    = a.attributes['href']!;
        final excerpt = a.nextElementSibling?.text.trim() ?? '';
        issues.add(RepairIssue(
          title:       txt,
          description: excerpt,
          detailUrl:   href,
        ));
      }
      sib = sib.nextElementSibling;
    }

    // 2) For each problem, fetch its detail page to fill mileage + solutions
    await Future.wait(issues.map((issue) async {
      final dUri = issue.detailUrl.startsWith('http')
          ? Uri.parse(issue.detailUrl)               // already absolute
          : Uri.parse('https://repairpal.com${issue.detailUrl}');
      final dResp = await http.get(dUri, headers: {'User-Agent': 'Mozilla/5.0'});
      if (dResp.statusCode != 200) return;
      final dDoc = parse(dResp.body);

      // — average mileage
      final locParent = dDoc.querySelector('img[alt="Location"]')?.parent;
      if (locParent != null) {
        final raw = locParent.text.trim(); // e.g. "Average mileage: 162,176"
        issue.averageMileage = raw.contains(':')
            ? raw.split(':').last.trim()
            : raw;
      }

      // — on-page estimates (e.g. General Diagnosis)
      final sols = <Solution>[];
      for (final div in dDoc.querySelectorAll('div.ng-car-problem-estimate')) {
        final parts = div.text.trim().split(':');
        final name  = parts.first.trim();
        final cost  = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
        if (cost.isNotEmpty) {
          sols.add(Solution(name: name, costRange: cost));
        }
      }

      // — per-leak costs via the “Learn More” links
      for (final link in dDoc.querySelectorAll('a.detailed-estimates-link')) {
        final href = link.attributes['href']!;
        final uri  = Uri.parse('https://repairpal.com$href');
        final r    = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
        if (r.statusCode != 200) continue;

        final eDoc = parse(r.body);
        final div  = eDoc.querySelector('div.ng-car-problem-estimate');
        if (div == null) continue;

        final parts      = div.text.trim().split(':');
        final desc       = parts.first.trim();
        final costRange  = parts.length > 1 ? parts.sublist(1).join(':').trim() : '';
        if (costRange.isNotEmpty) {
          sols.add(Solution(name: desc, costRange: costRange));
        }
      }

      issue.solutions = sols;
    }));

    return issues;
  }
}
