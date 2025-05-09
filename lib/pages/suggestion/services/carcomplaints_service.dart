// lib/pages/suggestion/services/carcomplaints_service.dart

import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

class CarComplaintsIssue {
  final String title;
  final String detailUrl;
  final String description;  // complaint count or snippet

  CarComplaintsIssue({
    required this.title,
    required this.detailUrl,
    required this.description,
  });
}

class CarComplaintsService {
  /// Scrape the “Worst … Problems by Category” list from CarComplaints.com
  static Future<List<CarComplaintsIssue>> fetchIssues({
    required String make,
    required String model,
    required String year,
  }) async {
    // Title-case each word and join with '_' to match site URLs
    String slugify(String s) {
      return s.trim()
          .split(RegExp(r'\s+'))
          .map((w) {
        final lw = w.toLowerCase();
        return lw[0].toUpperCase() + lw.substring(1);
      })
          .join('_');
    }

    final mk = slugify(make);
    final md = slugify(model);
    Uri uri = Uri.parse('https://www.carcomplaints.com/$mk/$md/$year/');
    var resp = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});

    // fallback to the search endpoint if direct URL 404s
    if (resp.statusCode == 404) {
      uri = Uri.https('www.carcomplaints.com', '/search/', {
        'Make':  mk,
        'Model': md,
        'Year':  year,
      });
      resp = await http.get(uri, headers: {'User-Agent': 'Mozilla/5.0'});
    }
    if (resp.statusCode != 200) {
      throw Exception('CC load failed: ${resp.statusCode}');
    }

    final doc = parse(resp.body);
    final issues = <CarComplaintsIssue>[];

    // 1) Find the <h4> whose text contains “Click on a category”
    Element? header;
    for (final h4 in doc.querySelectorAll('h4')) {
      if (h4.text.toLowerCase().contains('click on a category')) {
        header = h4;
        break;
      }
    }

    // 2) From there, walk next siblings until you hit a <ul>
    Element? list;
    if (header != null) {
      var sib = header;
      while ((sib = sib.nextElementSibling!) != null) {
        if (sib.localName == 'ul') {
          list = sib;
          break;
        }
      }
    }

    // 3) Parse each <li> in that <ul>
    if (list != null) {
      for (final li in list.querySelectorAll('li')) {
        final a = li.querySelector('a');
        if (a == null) continue;

        final titleRaw = a.text.trim();
        // grab the leading number as complaint count
        final countMatch = RegExp(r'(\d+)\b').firstMatch(titleRaw);
        final countText = countMatch != null
            ? '${countMatch.group(1)} complaints'
            : '';

        // strip trailing numbers for a clean title
        final title = titleRaw.replaceAll(RegExp(r'\d.*$'), '').trim();

        final href = a.attributes['href']!;
        final detailUrl = href.startsWith('http')
            ? href
            : 'https://www.carcomplaints.com$href';

        issues.add(CarComplaintsIssue(
          title:       title,
          detailUrl:   detailUrl,
          description: countText,
        ));
      }
    }

    return issues;
  }
}
