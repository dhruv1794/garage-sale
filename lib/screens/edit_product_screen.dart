import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product.dart';
import '../providers/products.dart';

//https://www.w3schools.com/html/img_girl.jpg
class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageURLFocusNode = FocusNode();
  final _imageURLController = TextEditingController();
  final _form = GlobalKey<FormState>();
  var _editedProduct = Product(
    id: '',
    title: '',
    price: 0,
    description: '',
    imageUrl: '',
  );
  var _isInit = true;
  var _initValue = {
    'title': '',
    'description': '',
    'price': '',
    'imageUrl': '',
  };
  var _isLoading = false;

  @override
  void initState() {
    _imageURLFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  //Because we use focus nodes we need to dispose them to prevent memoryLeaks
  void dispose() {
    _imageURLFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageURLController.dispose();
    _imageURLFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      var argument = ModalRoute.of(context)?.settings.arguments;
      if (argument != null) {
        final productId = argument as String;
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);

        _initValue = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageURLController.text = _editedProduct.imageUrl;
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageURLFocusNode.hasFocus) {
      // Empty set state to initiate re-render
      if (_imageURLController.text.isEmpty ||
          (!_imageURLController.text.startsWith('http') &&
              !_imageURLController.text.startsWith('https')) ||
          (!_imageURLController.text.endsWith('png') &&
              !_imageURLController.text.endsWith('jpeg') &&
              !_imageURLController.text.endsWith('jpg'))) {
        return;
      }
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState?.validate();
    if (!isValid!) {
      return;
    }
    _form.currentState?.save();
    setState(() {
      _isLoading = true;
    });
    var productData = Provider.of<Products>(context, listen: false);

    try {
      if (_editedProduct.id != '') {
        await productData.updateProduct(_editedProduct.id, _editedProduct);
      } else {
        await productData.addProducts(_editedProduct);
      }
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Error occured'),
          content: Text(
            error.toString(),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
              },
              child: const Text('Okay!'),
            )
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
      Navigator.of(context).pop();
    }

    // productData.addProducts(_editedProduct).catchError((error) {
    //   return showDialog(
    //     context: context,
    //     builder: (ctx) => AlertDialog(
    //       title: const Text('Error occured'),
    //       content: Text(
    //         error.toString(),
    //       ),
    //       actions: [
    //         TextButton(
    //           onPressed: () {
    //             Navigator.of(ctx).pop();
    //           },
    //           child: const Text('Okay!'),
    //         )
    //       ],
    //     ),
    //   );
    // }).then((_) {
    //   setState(() {
    //     _isLoading = false;
    //   });
    //   Navigator.of(context).pop();
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(
            onPressed: _saveForm,
            icon: const Icon(Icons.save),
          )
        ],
      ),
      body: !_isLoading
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    children: [
                      TextFormField(
                        initialValue: _initValue['title'],
                        decoration: const InputDecoration(label: Text('Title')),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted: (_) {
                          // Following happens automatically and is used here only for reference
                          FocusScope.of(context).requestFocus(
                              _priceFocusNode); // when next is pressed we shift focus to _priceFocusNode
                        },
                        validator: (value) {
                          // String returned is error !
                          if (value!.isEmpty) {
                            return 'Please provide a value for title';
                          }
                          return null; // input is correct
                        },
                        onSaved: (newValue) => {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: newValue.toString(),
                              description: _editedProduct.description,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl)
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['price'],
                        decoration: const InputDecoration(label: Text('Price')),
                        textInputAction: TextInputAction.next,
                        keyboardType: TextInputType.number,
                        focusNode: _priceFocusNode,
                        onFieldSubmitted: (_) {
                          FocusScope.of(context).requestFocus(
                              _descriptionFocusNode); // when next is pressed we shift focus to _descriptionFocusNode
                        },
                        validator: (value) {
                          // String returned is error !
                          if (value!.isEmpty) {
                            return 'Please enter a price';
                          }
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          if (double.parse(value) <= 0) {
                            return 'Please enter a price greater than 0';
                          }
                          return null; // input is correct
                        },
                        onSaved: (newValue) => {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(newValue!),
                              imageUrl: _editedProduct.imageUrl)
                        },
                      ),
                      TextFormField(
                        initialValue: _initValue['description'],
                        decoration:
                            const InputDecoration(label: Text('Description')),
                        maxLines: 3,
                        focusNode: _descriptionFocusNode,
                        keyboardType: TextInputType.multiline,
                        onSaved: (newValue) => {
                          _editedProduct = Product(
                              id: _editedProduct.id,
                              isFavourite: _editedProduct.isFavourite,
                              title: _editedProduct.title,
                              description: newValue.toString(),
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl)
                        },
                        validator: (value) {
                          // String returned is error !
                          if (value!.isEmpty) {
                            return 'Please enter a Description';
                          }
                          if (value.length < 10) {
                            return 'Too short';
                          }
                          return null; // input is correct
                        },
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: const EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 1,
                                color: Colors.grey,
                              ),
                            ),
                            child: _imageURLController.text.isEmpty
                                ? const Text('Enter a Url')
                                : FittedBox(
                                    child: Image.network(
                                      _imageURLController.text,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                          ),
                          Expanded(
                            child: TextFormField(
                              decoration:
                                  const InputDecoration(labelText: 'Image URL'),
                              keyboardType: TextInputType.url,
                              textInputAction: TextInputAction.done,
                              controller: _imageURLController,
                              focusNode: _imageURLFocusNode,
                              onFieldSubmitted: (_) {
                                _saveForm();
                              },
                              onSaved: (newValue) => {
                                _editedProduct = Product(
                                    id: _editedProduct.id,
                                    isFavourite: _editedProduct.isFavourite,
                                    title: _editedProduct.title,
                                    description: _editedProduct.description,
                                    price: _editedProduct.price,
                                    imageUrl: newValue.toString())
                              },
                              validator: (value) {
                                // String returned is error !
                                if (value!.isEmpty) {
                                  return 'Please enter an Image URL';
                                }
                                if (!value.startsWith('http') ||
                                    !value.startsWith('https')) {
                                  return 'Valid URLS start with http or https';
                                }
                                if (!value.endsWith('.png') &&
                                    !value.endsWith('.jpg') &&
                                    !value.endsWith('.jpeg')) {
                                  return 'Does not seem to be an image URL';
                                }
                                return null; // input is correct
                              },
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
