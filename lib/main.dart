import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const LoveEverApp());
}

class LoveEverApp extends StatelessWidget {
  const LoveEverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'LoveEver',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepPurple, width: 2),
          ),
        ),
      ),
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;
  bool _obscurePassword = true;
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _initDeepLinks() async {
    _appLinks = AppLinks();

    // Handle initial URI if the app was launched from a deep link
    final uri = await _appLinks.getInitialLink();
    if (uri != null) {
      _handleDeepLink(uri);
    }

    // Listen for incoming links while the app is running
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      _handleDeepLink(uri);
    });
  }

  void _handleDeepLink(Uri uri) {
    if (uri.scheme == 'loveever' && uri.host == 'callback') {
      final code = uri.queryParameters['code'];
      debugPrint('Google OAuth code: $code');

      // ✅ Handle successful login here
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login successful! Code: $code")),
      );
    }
  }

  void _handleEmailLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement email login
      debugPrint('Email: ${_emailController.text}');
      debugPrint('Password: ${_passwordController.text}');
    }
  }

  void _handleGoogleLogin() {
    const googleLoginUrl =
        'https://accounts.google.com/o/oauth2/v2/auth'
        '?client_id=293981945717-tttkk4co6s9c3cbkanmkg0gd6h6mh1on.apps.googleusercontent.com'
        '&redirect_uri=loveever://callback'
        '&response_type=code'
        '&scope=email%20profile'
        '&access_type=offline';

    try {
      // launch(
      //   googleLoginUrl,
      //   customTabsOption: const CustomTabsOption(
      //     toolbarColor: Colors.deepPurple,
      //     enableUrlBarHiding: true,
      //     showPageTitle: true,
      //     enableDefaultShare: false,
      //   ),
      //   safariVCOption: const SafariViewControllerOption(
      //     preferredBarTintColor: Colors.deepPurple,
      //     preferredControlTintColor: Colors.white,
      //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      //   ),
      // );
    } catch (e) {
      debugPrint('Could not launch secure tab: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Container(
                    height: 120,
                    width: 120,
                    margin: const EdgeInsets.only(bottom: 32),
                    child: Image.asset(
                      'assets/images/icon.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const Text(
                    'Welcome to LoveEver',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  TextFormField(
                    controller: _emailController,
                    focusNode: _emailFocusNode,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    focusNode: _passwordFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    enableInteractiveSelection: true,
                    autocorrect: false,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _handleEmailLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Sign In'),
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR'),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: _handleGoogleLogin,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    icon: Image.network(
                      'https://www.google.com/favicon.ico',
                      height: 24,
                    ),
                    label: const Text('Sign in with Google'),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});

  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> {
  late final WebViewController _controller;
  StreamSubscription? _linkSub;

  final String siteUrl = 'https://loveevertagapps.com';
  final String interceptedLoginPath = '/account/signInWithGoogle';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            if (url.contains(interceptedLoginPath.toLowerCase())) {
              // _launchGoogleLogin(context);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(siteUrl));

    _listenToRedirect();
  }

  void _listenToRedirect() {
    // _linkSub = uriLinkStream.listen((Uri? uri) {
    //   if (uri?.scheme == 'loveever' && uri?.host == 'callback') {
    //     final code = uri?.queryParameters['code'];
    //     debugPrint('Google OAuth code: $code');

    //     // ✅ Handle successful login here
    //     ScaffoldMessenger.of(context).showSnackBar(
    //       SnackBar(content: Text("Login successful! Code: $code")),
    //     );
    //     // Optionally reload your authenticated site
    //     _controller.loadRequest(Uri.parse(siteUrl));
    //   }
    // });
  }

  void _launchGoogleLogin(BuildContext context) async {
    const googleLoginUrl =
        'https://accounts.google.com/o/oauth2/v2/auth'
        '?client_id=293981945717-tttkk4co6s9c3cbkanmkg0gd6h6mh1on.apps.googleusercontent.com'
        '&redirect_uri=loveever://callback'
        '&response_type=code'
        '&scope=email%20profile'
        '&access_type=offline';

    try {
      // await launch(
      //   googleLoginUrl,
      //   customTabsOption: const CustomTabsOption(
      //     toolbarColor: Colors.deepPurple,
      //     enableUrlBarHiding: true,
      //     showPageTitle: true,
      //     enableDefaultShare: false,
      //   ),
      //   safariVCOption: const SafariViewControllerOption(
      //     preferredBarTintColor: Colors.deepPurple,
      //     preferredControlTintColor: Colors.white,
      //     dismissButtonStyle: SafariViewControllerDismissButtonStyle.close,
      //   ),
      // );
    } catch (e) {
      debugPrint('Could not launch secure tab: $e');
    }
  }

  @override
  void dispose() {
    _linkSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}



/*


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


*/