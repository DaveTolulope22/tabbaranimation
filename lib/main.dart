mport 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: CustomTabView(),
        ),
      ),
    );
  }
}

class CustomTabView extends StatefulWidget {
  const CustomTabView({Key? key}) : super(key: key);

  @override
  CustomTabViewState createState() => CustomTabViewState();
}

class CustomTabViewState extends State<CustomTabView>
    with SingleTickerProviderStateMixin {
  final List<String> links = [
    'https://krik.mpanel.app/api/v1/ios/getMenu/10/html',
    'https://krik.mpanel.app/api/v1/ios/getMenu/2/html',
    'https://krik.mpanel.app/api/v1/ios/getMenu/3/html',
    'https://krik.mpanel.app/api/v1/ios/getMenu/7/html',
  ];
  late PageController _pageController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _tabController = TabController(length: links.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _tabController,
          tabs: links.map((link) => Tab(text: link)).toList(),
          onTap: (index) {
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: links.length,
        onPageChanged: (index) {
          _tabController.animateTo(index);
        },
        itemBuilder: (BuildContext context, int index) {
          return TransformPageView(
            page: index,
            controller: _pageController,
            child: WebView(
              initialUrl: links[index],
              javascriptMode: JavascriptMode.unrestricted,
              gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                Factory<VerticalDragGestureRecognizer>(
                  () => VerticalDragGestureRecognizer()..onUpdate = (e) => {},
                ),
              },
            ),
          );
        },
      ),
    );
  }
}

class TransformPageView extends StatelessWidget {
  final int page;
  final PageController controller;
  final WebView child;

  const TransformPageView({
    Key? key,
    required this.page,
    required this.controller,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (BuildContext context, Widget? child) {
        double value = 1.0;
        if (controller.position.haveDimensions) {
          value = controller.page! - page;
          if (value < 0) {
            value = 1.0;
          } else if (value < 1.0) {
            value = 1 - value;
          } else {
            value = 0.0;
          }
        }
        return Transform.rotate(
          angle: -(1 - value) * (25 * pi / 180),
          child: child,
        );
      },
      child: child,
    );
  }
}
