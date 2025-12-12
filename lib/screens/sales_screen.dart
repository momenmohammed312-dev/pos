import 'package:flutter/material.dart';
import '../services/firestore_item_service.dart';
import '../services/firestore_sale_service.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final itemSvc = FirestoreItemService();
  final saleSvc = FirestoreSaleService();

  Map<String, int> cart = {}; // itemId -> qty

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sales')),
      body: Row(
        children: [
          Expanded(child: _itemsList()),
          SizedBox(width: 360, child: _cartPanel()),
        ],
      ),
    );
  }

  Widget _itemsList() {
    return StreamBuilder(
      stream: itemSvc.streamItems(),
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final items = snapshot.data;

        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, i) {
            final it = items[i];

            return ListTile(
              title: Text(it.name),
              subtitle: Text(
                'Qty: ${it.quantity} • Price: ${it.price.toStringAsFixed(2)}',
              ),
              trailing: ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    cart[it.id] = (cart[it.id] ?? 0) + 1;
                  });
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _cartPanel() {
    return Column(
      children: [
        Expanded(
          child: ListView(
            children: cart.entries.map((e) {
              return ListTile(
                title: Text(e.key),
                subtitle: Text('Qty: ${e.value}'),
                trailing: IconButton(
                  icon: Icon(Icons.remove_circle),
                  onPressed: () {
                    setState(() {
                      if (e.value > 1) {
                        cart[e.key] = e.value - 1;
                      } else {
                        cart.remove(e.key);
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        ElevatedButton(
          onPressed: _checkout,
          child: Text('Checkout'),
        ),
      ],
    );
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) return;

    try {
      await saleSvc.createSale({
        'date': DateTime.now(),
        'items': cart.entries
            .map((e) => {
                  'itemId': e.key,
                  'qty': e.value,
                })
            .toList(),
        'totalAmount': 0.0,
        'status': 'paid',
      });

      setState(() {
        cart.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sale completed')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Checkout error: $e')),
      );
    }
  }
}
