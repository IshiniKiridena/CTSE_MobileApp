import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class CartScreen extends StatefulWidget {
  final String productId;
  final String productName;
  final String price;
  const CartScreen(
      {Key? key,
      required this.productId,
      required this.productName,
      required this.price})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final CollectionReference _cartData =
      FirebaseFirestore.instance.collection('cart');
  final TextEditingController _productIdController = TextEditingController();
  final TextEditingController _customerIdController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _productName = TextEditingController();

  @override
  Widget build(BuildContext context) {
    print('Product ID : ${widget.productId}');
    print('Product Name : ${widget.productName}');
    print('Product price : ${widget.price}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
      ),
      //using the streambuilder to view all product for the particular customer
      body: StreamBuilder(
        stream: _cartData.snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
          if (streamSnapshot.hasData) {
            return ListView.builder(
              itemCount: streamSnapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final DocumentSnapshot documentSnapshot =
                    streamSnapshot.data!.docs[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(documentSnapshot['productname']),
                    // ignore: prefer_interpolation_to_compose_strings
                    subtitle: Text(
                        'Price : ${documentSnapshot['price']} , Quantity : ${documentSnapshot['quantity']}'),
                    trailing: SizedBox(
                      width: 100,
                      child: Row(
                        children: [
                          IconButton(
                              onPressed: () => _updateItem(documentSnapshot),
                              icon: const Icon(Icons.edit)),
                          IconButton(
                              onPressed: () =>
                                  _deleteItemFromCart(documentSnapshot.id),
                              icon: const Icon(Icons.delete))
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),

      //add new item into the cart - manual process
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createItem(),
        child: const Icon(Icons.add),
      ),
    );
  }

  //Method to delete the cart item using the product id
  Future<void> _deleteItemFromCart(String productID) async {
    await _cartData.doc(productID).delete();

    //delete snackbar
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You removed an item from the cart")));
  }

  //Method to create  item details
  Future<void> _createItem([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //manual input for the user
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  //letting user only update the quantity
                  controller: _productIdController,
                  decoration: const InputDecoration(labelText: 'Product ID'),
                ),
                TextField(
                  controller: _customerIdController,
                  decoration: const InputDecoration(labelText: 'Customer ID'),
                ),
                TextField(
                  controller: _productName,
                  decoration: const InputDecoration(labelText: 'Product name'),
                ),
                TextField(
                  controller: _priceController,
                  decoration: const InputDecoration(labelText: 'Price'),
                ),
                TextField(
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    final String? productID = _productIdController.text;
                    final String? customerID = _customerIdController.text;
                    final String? productName = _productName.text;
                    final String? price = _priceController.text;
                    final String? quantity = _quantityController.text;
                    //validation for the quantity input
                    if (quantity != null) {
                      //insert to collection
                      await _cartData.add({
                        "productid": productID,
                        "customerid": customerID,
                        "quantity": quantity,
                        "price": price,
                        "productname": productName
                      });

                      //clear input fields
                      _productIdController.text = '';
                      _customerIdController.text = '';
                      _productName.text = '';
                      _priceController.text = '';
                      _quantityController.text = '';

                      //hide the bottom prompt view
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  //Method to update cart item details
  Future<void> _updateItem([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _productIdController.text = documentSnapshot['productid'];
      _customerIdController.text = documentSnapshot['customerid'];
      _quantityController.text = documentSnapshot['quantity'];
      _priceController.text = documentSnapshot['price'];
      _productName.text = documentSnapshot['productname'];
    }

    //bottom input to update the cart items
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  //letting user only update the quantity
                  controller: _quantityController,
                  decoration: const InputDecoration(labelText: 'Quantity'),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: Text('Update'),
                  onPressed: () async {
                    final String? quantity = _quantityController.text;
                    //validation for the quantity input
                    if (quantity != null) {
                      await _cartData
                          .doc(documentSnapshot!.id)
                          .update({"quantity": quantity});
                      //clear input field
                      _quantityController.text = '';

                      //hide the bottom prompt view
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }
}
