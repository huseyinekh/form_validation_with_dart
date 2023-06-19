import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/data/dummy_items.dart';

import 'package:shop_list/models/grocery_item.dart';
import 'package:shop_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _GroceryListState();
  }
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    _loadItems();
    super.initState();
  }

  void _loadItems() async {
    final url = Uri.https(
        "flutter-app-11029-default-rtdb.firebaseio.com", 'shopping-list.json');
    final res = await http.get(url);
    if (res.body == 'null') {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> lisData = json.decode(res.body);
    final List<GroceryItem> loadedItems = [];

    if (res.statusCode >= 400) {
      setState(() {
        _error = "serverlə bağlantıda xəta baş verdi";
      });
    }
    for (var item in lisData.entries) {
      final currentCategory = categories.entries
          .firstWhere((c) => c.value.title == item.value["category"])
          .value;

      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: currentCategory));
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem(BuildContext context) async {
    var newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(builder: (ctx) => const NewItem()),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      groceryItems.add(newItem);
    });
    _loadItems();
  }

  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https("Aflutter-app-11029-default-rtdb.firebaseio.com",
        'shopping-list/${item.id}.json');
    final res = await http.delete(
      url,
    );

    if (res.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text("Boşdur"),
    );
    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      setState(() {
        _isLoading = false;
      });
      content = Center(child: Text(_error!));
    }
    return Scaffold(
        appBar: AppBar(
          title: const Text('Məhsullar'),
          actions: [
            IconButton(
                onPressed: () {
                  _addItem(context);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: content);
  }
}
