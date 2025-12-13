// lib/screens/sales_screen.dart

import 'package:flutter/material.dart';
import '../services/firestore_item_service.dart';
import '../services/firestore_sale_service.dart';
import '../Models/sale.dart'; // <--- استيراد نموذج Sale الذي قمت بتعريفه

class SalesScreen extends StatefulWidget {
  @override
  // استخدام const لحل بعض التحذيرات
  _SalesScreenState createState() => const _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final itemSvc = FirestoreItemService();
  final saleSvc = FirestoreSaleService();

  Map<String, int> cart = {}; // itemId -> qty
  double total = 0.0; // متغير لحساب الإجمالي (مطلوب لنموذج Sale)

  // دالة لحساب الإجمالي (يجب تطويرها لتعتمد على أسعار المنتجات الفعلية)
  void _calculateTotal() {
    // في الوضع الحالي، هذه عملية حسابية بسيطة مؤقتة
    // تعتمد على عدد العناصر فقط
    total = cart.values.length.toDouble() * 10; 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sales')), // تم إضافة const
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
          return const Center(child: CircularProgressIndicator()); // تم إضافة const
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
                child: const Text('Add'), // تم إضافة const
                onPressed: () {
                  setState(() {
                    cart[it.id] = (cart[it.id] ?? 0) + 1;
                    _calculateTotal(); // تحديث الإجمالي
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
                  icon: const Icon(Icons.remove_circle), // تم إضافة const
                  onPressed: () {
                    setState(() {
                      if (e.value > 1) {
                        cart[e.key] = e.value - 1;
                      } else {
                        cart.remove(e.key);
                      }
                      _calculateTotal(); // تحديث الإجمالي
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
        // عرض الإجمالي
        Padding(
          padding: const EdgeInsets.all(8.0), // تم إضافة const
          child: Text('Total: ${total.toStringAsFixed(2)}'),
        ),
        ElevatedButton(
          onPressed: _checkout,
          child: const Text('Checkout'), // تم إضافة const
        ),
      ],
    );
  }

  Future<void> _checkout() async {
    if (cart.isEmpty) return;
    
    // إنشاء كائن Sale بدلاً من الخريطة الخام (يحل الخطأ argument_type_not_assignable)
    final saleData = Sale(
      date: DateTime.now(),
      totalAmount: total, // استخدام الإجمالي المحسوب
      items: cart.entries
          .map((e) => {
                'itemId': e.key,
                'qty': e.value,
              })
          .toList(),
      status: 'paid', // يمكنك تغيير هذا بناءً على منطق الدفع
    );

    try {
      await saleSvc.createSale(saleData); // تمرير كائن Sale

      setState(() {
        cart.clear();
        total = 0.0;
      });
      
      // استخدام if (mounted) يحل خطأ use_build_context_synchronously
      if (mounted) { 
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sale completed')), // تم إضافة const
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Checkout error: $e')),
        );
      }
    }
  }
}
