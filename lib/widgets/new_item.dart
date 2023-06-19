import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop_list/data/categories.dart';
import 'package:shop_list/models/category.dart';
import 'package:http/http.dart' as http;
import 'package:shop_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});
  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  var enteredName = '';
  var enteredQuantity = 1;
  var selectedCategory = categories[Categories.vegetables];
  var _isSending = false;

  void _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSending = true;
      });
      _formKey.currentState!.save();
      final url = Uri.https("flutter-app-11029-default-rtdb.firebaseio.com",
          'shopping-list.json');
      var res = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'id': DateTime.now().toString(),
          'name': enteredName,
          'quantity': enteredQuantity,
          'category': selectedCategory!.title
        }),
      );

      final Map<String, dynamic> resData = json.decode(res.body);
      if (!context.mounted) {
        return;
      }

      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: enteredName,
          quantity: enteredQuantity,
          category: selectedCategory!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yeni məhsul əlavə et"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(label: Text("Ad")),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Simvol sayı 1-50 arası oolmalıdır';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    enteredName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          label: Text("Say"),
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              int.tryParse(value) == null ||
                              int.tryParse(value)! <= 0) {
                            return 'Yanlş rəqən daxil etdiniz!';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          enteredQuantity = int.parse(value!);
                        },
                        initialValue: enteredQuantity.toString(),
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: DropdownButtonFormField(
                        value: selectedCategory,
                        items: [
                          for (final cat in categories.entries.toList())
                            DropdownMenuItem(
                                value: cat.value,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 16,
                                      height: 16,
                                      color: cat.value.color,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(cat.value.title)
                                  ],
                                ))
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: const Text("Formu təmizlə")),
                    ElevatedButton(
                        onPressed: _isSending ? null : _saveItem,
                        child: _isSending
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text("Əlavə et"))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
