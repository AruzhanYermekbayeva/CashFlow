import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as google_maps;
import '../models/transactions_model.dart';
import '../helper/transaction_provider.dart';
import 'currency_provider.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  _TransactionsPageState createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _latController = TextEditingController();
  final TextEditingController _lngController = TextEditingController();

  String _sortCriteria = 'Date';
  bool _isLoading = true;
  bool _showMap = false;
  google_maps.GoogleMapController? _mapController;
  google_maps.LatLng? _initialPosition;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
      await Provider.of<CurrencyProvider>(context, listen: false).fetchRates();
      _calculateInitialPosition(Provider.of<TransactionProvider>(context, listen: false).transactions);
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _initialPosition = const google_maps.LatLng(37.7749, -122.4194);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading data: ${e.toString()}')),
      );
    }
  }

  void _calculateInitialPosition(List<TransactionModel> transactions) {
    final validLocations = transactions
        .where((t) => t.lat != null && t.lng != null)
        .map((t) => google_maps.LatLng(t.lat!, t.lng!))
        .toList();

    setState(() {
      _initialPosition = validLocations.isNotEmpty
          ? google_maps.LatLng(
        validLocations.map((l) => l.latitude).reduce((a, b) => a + b) / validLocations.length,
        validLocations.map((l) => l.longitude).reduce((a, b) => a + b) / validLocations.length,
      )
          : const google_maps.LatLng(37.7749, -122.4194);
    });
  }

  void _confirmDelete(BuildContext context, TransactionModel transaction) {
    if (transaction.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot delete - transaction has no ID')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Delete "${transaction.title}" transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(transaction.id!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Deleted ${transaction.title}')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: ${e.toString()}')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _searchController.dispose();
    _latController.dispose();
    _lngController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txnProvider = Provider.of<TransactionProvider>(context);
    List<TransactionModel> filteredTransactions = txnProvider.transactions
        .where((txn) => txn.title.toLowerCase().contains(_searchController.text.toLowerCase()))
        .toList();

    if (_sortCriteria == 'Date') {
      filteredTransactions.sort((a, b) => b.date.compareTo(a.date));
    } else if (_sortCriteria == 'Amount') {
      filteredTransactions.sort((a, b) => b.amount.compareTo(a.amount));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          Consumer<CurrencyProvider>(
            builder: (context, currency, _) {
              return DropdownButton<String>(
                value: currency.baseCurrency,
                icon: const Icon(Icons.arrow_drop_down),
                items: ['USD', 'EUR', 'JPY', 'GBP'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  currency.setBaseCurrency(newValue!);
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              setState(() => _isLoading = true);
              await txnProvider.fetchTransactions();
              await Provider.of<CurrencyProvider>(context, listen: false).fetchRates();
              _calculateInitialPosition(txnProvider.transactions);
              setState(() => _isLoading = false);
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
        child: Lottie.asset(
          'assets/loading_animation.json',
          width: 150,
          height: 150,
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      labelText: 'Search Transactions',
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _sortCriteria,
                  onChanged: (newValue) {
                    setState(() {
                      _sortCriteria = newValue!;
                    });
                  },
                  items: ['Date', 'Amount'].map((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showMap = !_showMap;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(_showMap ? 'Show List' : 'Show Map'),
            ),
          ),
          Expanded(
            child: _showMap
                ? _buildMapView(filteredTransactions)
                : _buildListView(filteredTransactions),
          ),
        ],
      ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        backgroundColor: Colors.teal,
        label: const Text('Add Transaction'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildListView(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No transactions found.', style: TextStyle(fontSize: 18)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await Provider.of<TransactionProvider>(context, listen: false).fetchTransactions();
      },
      child: ListView.builder(
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final txn = transactions[index];
          return Dismissible(
            key: Key(txn.id?.toString() ?? '${txn.title}_${txn.date}'),
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              return await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content: Text('Delete "${txn.title}" transaction?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) async {
              if (txn.id == null) return;

              try {
                await Provider.of<TransactionProvider>(context, listen: false)
                    .deleteTransaction(txn.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deleted ${txn.title}'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await Provider.of<TransactionProvider>(context, listen: false)
                              .addTransaction(txn);
                        },
                      ),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete: ${e.toString()}')),
                  );
                }
              }
            },
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Consumer<CurrencyProvider>(
                builder: (context, currency, _) {
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: txn.amount >= 0 ? Colors.green : Colors.red,
                      child: Icon(txn.amount >= 0 ? Icons.arrow_upward : Icons.arrow_downward),
                    ),
                    title: Text(txn.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${txn.amount.toStringAsFixed(2)} ${currency.baseCurrency}'),
                        Text(
                          '≈ ${currency.convert(txn.amount, 'EUR').toStringAsFixed(2)} EUR',
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        Text(
                          '${txn.date.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (txn.lat != null && txn.lng != null)
                          IconButton(
                            icon: const Icon(Icons.location_pin, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _showMap = true;
                                _initialPosition = google_maps.LatLng(txn.lat!, txn.lng!);
                                _mapController?.animateCamera(
                                  google_maps.CameraUpdate.newLatLngZoom(
                                    google_maps.LatLng(txn.lat!, txn.lng!),
                                    15,
                                  ),
                                );
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _confirmDelete(context, txn),
                        ),
                      ],
                    ),
                    onTap: () => _showEditDialog(context, txn),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapView(List<TransactionModel> transactions) {
    if (_initialPosition == null) {
      return const Center(child: Text('No location data available'));
    }

    final Set<google_maps.Marker> markers = transactions
        .where((txn) => txn.lat != null && txn.lng != null)
        .map((txn) {
      return google_maps.Marker(
        markerId: google_maps.MarkerId(txn.id?.toString() ?? DateTime.now().toString()),
        position: google_maps.LatLng(txn.lat!, txn.lng!),
        infoWindow: google_maps.InfoWindow(
          title: txn.title,
          snippet: '${txn.amount.toStringAsFixed(2)} ₸',
        ),
      );
    }).toSet();

    return google_maps.GoogleMap(
      initialCameraPosition: google_maps.CameraPosition(
        target: _initialPosition!,
        zoom: 12,
      ),
      markers: markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title*'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount*'),
              ),
              const SizedBox(height: 16),
              const Text('Location (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final amount = double.tryParse(_amountController.text.trim());
              final lat = double.tryParse(_latController.text.trim());
              final lng = double.tryParse(_lngController.text.trim());

              if (title.isEmpty || amount == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and amount are required')),
                );
                return;
              }

              try {
                final txn = TransactionModel(
                  id: null,
                  title: title,
                  amount: amount,
                  date: DateTime.now(),
                  lat: lat,
                  lng: lng,
                );

                await Provider.of<TransactionProvider>(context, listen: false)
                    .addTransaction(txn);

                _titleController.clear();
                _amountController.clear();
                _latController.clear();
                _lngController.clear();

                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error adding transaction: ${e.toString()}')),
                );
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, TransactionModel txn) {
    _titleController.text = txn.title;
    _amountController.text = txn.amount.toString();
    _latController.text = txn.lat?.toString() ?? '';
    _lngController.text = txn.lng?.toString() ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit Transaction'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title*'),
              ),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount*'),
              ),
              const SizedBox(height: 16),
              const Text('Location (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _latController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _lngController,
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              final amount = double.tryParse(_amountController.text.trim());
              final lat = double.tryParse(_latController.text.trim());
              final lng = double.tryParse(_lngController.text.trim());

              if (title.isEmpty || amount == null || txn.id == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Title and amount are required')),
                );
                return;
              }

              try {
                final updatedTxn = TransactionModel(
                  id: txn.id,
                  title: title,
                  amount: amount,
                  date: txn.date,
                  lat: lat,
                  lng: lng,
                );

                await Provider.of<TransactionProvider>(context, listen: false)
                    .updateTransaction(updatedTxn);

                _titleController.clear();
                _amountController.clear();
                _latController.clear();
                _lngController.clear();

                Navigator.of(context).pop();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error updating transaction: ${e.toString()}')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}