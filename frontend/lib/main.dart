import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const backendUrl = 'http://localhost:8000';

void main() {
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Search',
      home: const FoodSearchPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class FoodSummary {
  final int fdcId;
  final String description;
  final String? brand;

  FoodSummary({
    required this.fdcId,
    required this.description,
    this.brand,
  });

  factory FoodSummary.fromJson(Map<String, dynamic> json) {
    final rawId = json['fdc_id'] ?? json['fdcId'];
    if (rawId == null) {
      throw StateError('Missing fdc_id/fdcId in response: $json');
    }

    return FoodSummary(
      fdcId: (rawId as num).toInt(),
      description: json['description'] ?? '',
      brand: json['brand_owner'] ?? json['brandOwner'],
    );
  }
}

class FoodDetails {
  final int fdcId;
  final String description;
  final String? brandOwner;
  final String? brandName;
  final String? ingredients;
  final double? servingSize;
  final String? servingSizeUnit;
  final Map<String, dynamic>? labelNutrients;

  FoodDetails({
    required this.fdcId,
    required this.description,
    this.brandOwner,
    this.brandName,
    this.ingredients,
    this.servingSize,
    this.servingSizeUnit,
    this.labelNutrients,
  });

  factory FoodDetails.fromJson(Map<String, dynamic> json) {
  final rawLabels = json['label_nutrients'] as Map<String, dynamic>?;

  Map<String, dynamic>? normalizedLabels;
  if (rawLabels != null) {
    normalizedLabels = rawLabels.map((key, value) {
      if (value is num) {
        return MapEntry(key, { 'value': value });
      }
      return MapEntry(key, value);
    });
  }

  return FoodDetails(
    fdcId: json['fdc_id'],
    description: json['description'] ?? '',
    brandOwner: json['brand_owner'],
    brandName: json['brand_name'],
    ingredients: json['ingredients'],
    servingSize: (json['serving_size'] as num?)?.toDouble(),
    servingSizeUnit: json['serving_size_unit'],
    labelNutrients: normalizedLabels,
  );
}
}

class SearchResult {
  final List<FoodSummary> foods;
  final int currentPage;
  final int totalPages;
  final int totalHits;

  SearchResult({
    required this.foods,
    required this.currentPage,
    required this.totalPages,
    required this.totalHits,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final foodsJson = json['foods'] as List<dynamic>? ?? [];
    return SearchResult(
      foods: foodsJson
          .map((e) => FoodSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentPage: (json['current_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      totalHits: (json['total_hits'] as num?)?.toInt() ?? 0,
    );
  }
}

Future<FoodDetails> fetchFoodDetails(int fdcId) async {
  final uri = Uri.parse('$backendUrl/food/$fdcId');

  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Failed to load food details');
  }

  return FoodDetails.fromJson(jsonDecode(res.body));
}

Future<SearchResult> searchFoods(String query, int page) async {
  final uri = Uri.parse('$backendUrl/foods').replace(queryParameters: {
    'query': query,
    'page': page.toString(),
    'page_size': '20',
  });

  final res = await http.get(uri);
  if (res.statusCode != 200) {
    throw Exception('Backend error: ${res.statusCode}');
  }

  final body = jsonDecode(res.body) as Map<String, dynamic>;
  return SearchResult.fromJson(body);
}

class FoodSearchPage extends StatefulWidget {
  const FoodSearchPage({super.key});

  @override
  State<FoodSearchPage> createState() => _FoodSearchPageState();
}

class _FoodSearchPageState extends State<FoodSearchPage> {
  final TextEditingController controller = TextEditingController();

  bool loading = false;
  String? error;

  List<FoodSummary> results = [];

  int _currentPage = 1;
  int _totalPages = 1;

  Future<void> _performSearch({int page = 1}) async {
    final q = controller.text.trim();
    if (q.length < 2) {
      setState(() {
        error = 'Enter at least 2 characters.';
        results = [];
      });
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final result = await searchFoods(q, page);
      setState(() {
        _currentPage = result.currentPage;
        _totalPages = result.totalPages;
        results = result.foods;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        results = [];
      });
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  void _goToPage(int page) {
    if (page < 1 || page > _totalPages) return;
    _performSearch(page: page);
  }

  Widget _buildPaginationControls() {
    if (results.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Page $_currentPage of $_totalPages'),
          Row(
            children: [
              IconButton(
                onPressed: (!loading && _currentPage > 1)
                    ? () => _goToPage(_currentPage - 1)
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              IconButton(
                onPressed: (!loading && _currentPage < _totalPages)
                    ? () => _goToPage(_currentPage + 1)
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search for a food',
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _performSearch(page: 1),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _performSearch(page: 1),
              child: const Text('Search'),
            ),
            const SizedBox(height: 12),
            if (loading) const LinearProgressIndicator(),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: results.isEmpty
                  ? const Center(child: Text('No results yet.'))
                  : Column(
                      children: [
                        _buildPaginationControls(),
                        const Divider(height: 1),
                        Expanded(
                          child: ListView.builder(
                            itemCount: results.length,
                            itemBuilder: (_, i) {
                              final f = results[i];
                              return ListTile(
                                title: Text(f.description),
                                subtitle:
                                    f.brand != null ? Text(f.brand!) : null,
                                trailing: Text('#${f.fdcId}'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          FoodDetailsPage(fdcId: f.fdcId),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodDetailsPage extends StatefulWidget {
  final int fdcId;

  const FoodDetailsPage({super.key, required this.fdcId});

  @override
  State<FoodDetailsPage> createState() => _FoodDetailsPageState();
}

class _FoodDetailsPageState extends State<FoodDetailsPage> {
  bool loading = true;
  String? error;
  FoodDetails? details;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final d = await fetchFoodDetails(widget.fdcId);
      setState(() {
        details = d;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Food Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : error != null
                ? Center(child: Text(error!))
                : details == null
                    ? const Center(child: Text('No details found'))
                    : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    final d = details!;

    return ListView(
      children: [
        Text(
          d.description,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (d.brandOwner != null) Text("Brand Owner: ${d.brandOwner}"),
        if (d.brandName != null) Text("Brand Name: ${d.brandName}"),
        const SizedBox(height: 12),
        if (d.servingSize != null)
          Text("Serving Size: ${d.servingSize} ${d.servingSizeUnit ?? ''}"),
        const SizedBox(height: 12),
        if (d.ingredients != null) ...[
          const Text(
            "Ingredients:",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(d.ingredients!),
        ],
        const SizedBox(height: 24),
        const Text(
          "Label Nutrients",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (d.labelNutrients != null)
          ...d.labelNutrients!.entries.map((e) {
            final nutrient = e.value;

            if (nutrient == null) {
              return Text("${e.key}: N/A");
            }
            if (nutrient is Map && nutrient['value'] != null) {
              return Text("${e.key}: ${nutrient['value']}");
            }
            return Text("${e.key}: N/A");
          }),
      ],
    );
  }
}


