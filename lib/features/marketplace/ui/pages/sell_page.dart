import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/marketplace_bloc.dart';
import '../../bloc/marketplace_event.dart';
import '../../data/models/listing.dart';

class SellPage extends StatefulWidget {
  final VoidCallback? onPosted;

  const SellPage({
    super.key,
    this.onPosted,
  });

  @override
  State<SellPage> createState() => _SellPageState();
}

class _SellPageState extends State<SellPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _locationController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Electronics',
    'Furniture',
    'Gaming',
    'Sports',
    'Cars',
    'Music',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    final title = _titleController.text.trim();
    final priceText = _priceController.text.trim().replaceAll(RegExp(r'[,\s]'), '');
    final price = double.tryParse(priceText);
    
    return title.isNotEmpty &&
        price != null &&
        price > 0 &&
        _selectedCategory != null;
  }

  void _handlePost() {
    if (!_isFormValid()) {
      return;
    }

    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final priceText = _priceController.text.trim().replaceAll(RegExp(r'[,\s]'), '');
    final listing = Listing(
      id: id,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      price: double.parse(priceText).toInt(),
      category: _selectedCategory!,
      location: _locationController.text.trim(),
      images: ['https://picsum.photos/400?random=$id'],
      createdAt: DateTime.now(),
      ownerId: 'local-user',
    );

    context.read<MarketplaceBloc>().add(CreateListing(listing));

    // Clear form
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _locationController.clear();
    setState(() {
      _selectedCategory = null;
    });

    // Navigate to home tab
    widget.onPosted?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sell'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  autofocus: true,
                  onChanged: (_) => setState(() {}),
                  onFieldSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(),
                    prefixText: '\$',
                  ),
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a price';
                    }
                    final priceText = value.trim().replaceAll(RegExp(r'[,\s]'), '');
                    final price = double.tryParse(priceText);
                    if (price == null || price <= 0) {
                      return 'Please enter a valid price';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => setState(() {}),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                const Text(
                  'Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((category) {
                    final isSelected = _selectedCategory == category;
                    return FilterChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          _selectedCategory = selected ? category : null;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isFormValid() ? _handlePost : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
