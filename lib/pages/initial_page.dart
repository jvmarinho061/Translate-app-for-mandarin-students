import 'package:flutter/material.dart';
import 'package:pinyinapp/utils/responsive.dart';

class InitialPage extends StatefulWidget {
  const InitialPage({super.key});

  @override
  State<InitialPage> createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  @override
  Widget build(BuildContext context) {
    final isTablet = Responsive.isTablet(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.redAccent,
        centerTitle: false,
        title:
        Container(
          height: isTablet? 50 : 40,
          padding: EdgeInsets.symmetric(horizontal: isTablet ? 20 : 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isTablet ? 28 : 20),
          ),
          child: TextField(
            onChanged: widget.controller.search,
          ),
        ),
        ),
    );
  }
}
