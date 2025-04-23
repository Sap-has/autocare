import 'package:http/http.dart' as http;
import 'dart:convert';

class CarApiService {
  static const _base = 'https://carapi.app/api';

  List<int> fetchYears() {
    return [2015, 2016, 2017, 2018, 2019, 2020];
  }

  Future<List<String>> fetchMakes(int year) async {
    final res = await http.get(Uri.parse('$_base/makes?year=$year'));
    if (res.statusCode != 200) throw Exception('Failed to load makes');
    final data = json.decode(res.body)['data'] as List;
    return data.map((e) => e['name'] as String).toList();
  }

  Future<List<String>> fetchModels(int year, String make) async {
    final res = await http.get(Uri.parse('$_base/models?year=$year&make=$make'));
    if (res.statusCode != 200) throw Exception('Failed to load models');
    final data = json.decode(res.body)['data'] as List;
    return data.map((e) => e['name'] as String).toList();
  }

  Future<List<Map<String, dynamic>>> fetchTrimsRaw(int year, String make, String model) async {
    final res = await http.get(Uri.parse('$_base/trims?year=$year&make=$make&model=$model'));
    if (res.statusCode != 200) throw Exception('Failed to load trims');
    final data = json.decode(res.body)['data'] as List;
    return data.cast<Map<String, dynamic>>();
  }

  Future<List<String>> fetchTrims(int year, String make, String model) async {
    final raw = await fetchTrimsRaw(year, make, model);
    return raw.map((e) => e['name'] as String).toList();
  }

  Future<Map<String, dynamic>> fetchTrimVerbose(int trimId) async {
    final uri = Uri.parse('$_base/trims/$trimId?verbose=yes');
    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Failed to load trim details (${res.statusCode})');
    }

    // 1. Decode JSON
    final decoded = json.decode(res.body);

    // 2. Grab the actual payload (some APIs wrap in "data", some don’t)
    final Map<String, dynamic> payload =
    (decoded is Map && decoded.containsKey('data'))
        ? decoded['data'] as Map<String, dynamic>
        : decoded as Map<String, dynamic>;

    // 3. Build a flattened specs map
    final specs = <String, dynamic>{};

    // a) copy over simple fields
    specs['id']          = payload['id'];
    specs['name']        = payload['name'];
    specs['description'] = payload['description'];
    specs['msrp']        = payload['msrp'];
    specs['invoice']     = payload['invoice'];

    // b) flatten engine
    final engine = payload['make_model_trim_engine'] as Map<String, dynamic>? ?? {};
    specs.addAll(engine.map((k, v) => MapEntry(k, v)));

    // c) flatten mileage
    final mileage = payload['make_model_trim_mileage'] as Map<String, dynamic>? ?? {};
    specs.addAll(mileage.map((k, v) => MapEntry(k, v)));

    // d) flatten body
    final body = payload['make_model_trim_body'] as Map<String, dynamic>? ?? {};
    specs.addAll(body.map((k, v) => MapEntry(k, v)));

    // e) include color lists
    specs['interior_colors'] = payload['make_model_trim_interior_colors'];
    specs['exterior_colors'] = payload['make_model_trim_exterior_colors'];

    return specs;
  }

}