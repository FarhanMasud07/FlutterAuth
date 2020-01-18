import 'package:aythentication/models/http_exception.dart';
import 'package:aythentication/provider/product.dart';
import 'package:aythentication/provider/products_provider.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:provider/provider.dart';

import './provider/auth.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
        ChangeNotifierProxyProvider<Auth, ProductsProvider>(
          builder: (ctx, auth, previousProducts) => ProductsProvider(auth.token,
              previousProducts == null ? [] : previousProducts.items),
        ),
      ],
      child: Consumer<Auth>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: auth.isAuth ? ProductScreen() : AuthScreen(),
          //home: AuthScreen(),
        ),
      ),
    );
  }
}

enum AuthMode { Signup, Login }

class AuthScreen extends StatelessWidget {
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold(
      // resizeToAvoidBottomInset: false,
      body: Stack(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                  Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0, 1],
              ),
            ),
          ),
          SingleChildScrollView(
            child: Container(
              height: deviceSize.height,
              width: deviceSize.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      margin: EdgeInsets.only(bottom: 20.0),
                      padding:
                          EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
                      transform: Matrix4.rotationZ(-8 * pi / 180)
                        ..translate(-10.0),
                      // ..translate(-10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.deepOrange.shade900,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 8,
                            color: Colors.black26,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Text(
                        'WeDev',
                        style: TextStyle(
                          color: Theme.of(context).accentTextTheme.title.color,
                          fontSize: 50,
                          fontFamily: 'Anton',
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: deviceSize.width > 600 ? 2 : 1,
                    child: AuthCard(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AuthCard extends StatefulWidget {
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  void _showErrorDialogue(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('An Error Occured!'),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text('Okay'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          )
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState.validate()) {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      if (_authMode == AuthMode.Login) {
        // Log user in
        await Provider.of<Auth>(context, listen: false).login(
          _authData['email'],
          _authData['password'],
        );
        // Navigator.of(context).pushReplacement(
        //   MaterialPageRoute(
        //     builder: (context) => ProductScreen(_authData.toString()),
        //   ),
        // );
      } else {
        // Sign user up
        await Provider.of<Auth>(context, listen: false).signup(
          _authData['email'],
          _authData['password'],
        );
      }
    } on HttpException catch (e) {
      var errorMessage = 'Authentication Failed!';
      if (e.toString().contains('EMAIL_EXISTS')) {
        errorMessage = 'This email address is already in use';
      } else if (e.toString().contains('INVALID_EXISTS')) {
        errorMessage = 'This is not a valid email';
      } else if (e.toString().contains('WEAK_PASSWORD')) {
        errorMessage = 'This password is weak';
      } else if (e.toString().contains('EMAIL_NOT_FOUND')) {
        errorMessage = 'Email not found with this email';
      } else if (e.toString().contains('INVALID_PASSWORD')) {
        errorMessage = 'Invalid Password';
      }
      _showErrorDialogue(errorMessage);
    } catch (e) {
      var errorMessage = 'Could not authenticate you , please try later';
      _showErrorDialogue(errorMessage);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() {
    if (_authMode == AuthMode.Login) {
      setState(() {
        _authMode = AuthMode.Signup;
      });
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,
      child: Container(
        height: _authMode == AuthMode.Signup ? 320 : 260,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 260),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value.isEmpty || !value.contains('@')) {
                      return 'Invalid email!';
                    }
                  },
                  onSaved: (value) {
                    _authData['email'] = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) {
                    if (value.isEmpty || value.length < 5) {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) {
                    _authData['password'] = value;
                  },
                ),
                if (_authMode == AuthMode.Signup)
                  TextFormField(
                    enabled: _authMode == AuthMode.Signup,
                    decoration: InputDecoration(labelText: 'Confirm Password'),
                    obscureText: true,
                    validator: _authMode == AuthMode.Signup
                        ? (value) {
                            if (value != _passwordController.text) {
                              return 'Passwords do not match!';
                            }
                          }
                        : null,
                  ),
                SizedBox(
                  height: 20,
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : RaisedButton(
                        child: Text(
                            _authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                        onPressed: _submit,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 30.0, vertical: 8.0),
                        color: Theme.of(context).primaryColor,
                        textColor:
                            Theme.of(context).primaryTextTheme.button.color,
                      ),
                FlatButton(
                  child: Text(
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductScreen extends StatelessWidget {
  // String authdata;
  // ProductScreen(this.authdata);
  @override
  Widget build(BuildContext context) {
    final data = Provider.of<Auth>(context).items;
    Future<void> _refreshproduct(BuildContext context) async {
      await Provider.of<ProductsProvider>(context).fetchAndSetProducts();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('data'),
      ),
      body: Container(
          child: GridView.builder(
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: data.length,
        itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
          //builder: (ctx)=>products[i],
          value: data[i],
          child: ProductItem(
              // products[i].id,
              // products[i].title,
              // products[i].imageUrl,
              ),
        ),
      )),
    );
  }
}

class ProductItem extends StatefulWidget {
  @override
  _ProductItemState createState() => _ProductItemState();
}

class _ProductItemState extends State<ProductItem> {
  final _form = GlobalKey<FormState>();
  var _initValue = {
    'email': '',
    'password': '',
  };
  var _editedProduct = Product(
    email: '',
    password: '',
  );
  var _isInit = true;
  @override
  void didChangeDependencies() {
    //var _editedProduct, _initValue;
    if (_isInit) {
      final productemail = Provider.of<Product>(context, listen: false);
      _editedProduct = Provider.of<Auth>(context, listen: false)
          .findById(productemail.email);
      _initValue = {
        'email': _editedProduct.email,
        'password': _editedProduct.password,
      };
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    // final product = Provider.of<Product>(context, listen: false);
    // var _editedProduct = Product(
    //   email: product.email,
    //   password: product.password,
    // );

    Future<void> _saveForm() async {
      // var _editedProduct, _initValue;
      final isValid = _form.currentState.validate();
      if (!isValid) {
        return;
      }
      _form.currentState.save();

      // print(_editedProduct.title);
      if (_editedProduct.email != null) {
        await Provider.of<Auth>(context, listen: false)
            .updateProduct(_editedProduct.email, _editedProduct);
      }
      print('Saved');
    }

    return Column(
      children: <Widget>[
        Container(
          child: Padding(
            padding: EdgeInsets.all(15),
            child: Form(
              key: _form,
              child: TextFormField(
                initialValue: _initValue['email'],
                decoration: InputDecoration(labelText: 'email'),
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) {
                  _saveForm();
                },
                validator: (value) {
                  if (value.isEmpty) {
                    return "please enter a value";
                  }
                  return null;
                },
                onSaved: (value) {
                  _editedProduct = Product(
                    email: value,
                    password: _editedProduct.password,
                  );
                },
              ),
            ),
          ),
        ),
        Container(
          color: Colors.amberAccent,
          //rheight: 20,
          child: FlatButton(
            child: Text(
              'Submit',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            onPressed: _saveForm,
          ),
        ),
      ],
    );
  }
}
