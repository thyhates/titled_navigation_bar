import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import 'navigation_bar_item.dart';

const double DEFAULT_BAR_HEIGHT = 60;

const double DEFAULT_INDICATOR_HEIGHT = 2;

// ignore: must_be_immutable
class TitledBottomNavigationBar extends StatefulWidget {
  final Curve curve;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? inactiveStripColor;
  final Color? indicatorColor;
  final bool enableShadow;
  final bool showIndicator;
  final bool animateItem;
  int currentIndex;

  /// Called when a item is tapped.
  ///
  /// This provide the selected item's index.
  final ValueChanged<int> onTap;

  /// The items of this navigation bar.
  ///
  /// This should contain at least two items and five at most.
  final List<TitledNavigationBarItem> items;

  /// The selected item is indicator height.
  ///
  /// Defaults to [DEFAULT_INDICATOR_HEIGHT].
  final double indicatorHeight;

  /// Change the navigation bar's size.
  ///
  /// Defaults to [DEFAULT_BAR_HEIGHT].
  final double height;

  TitledBottomNavigationBar({
    Key? key,
    this.curve = Curves.linear,
    required this.onTap,
    required this.items,
    this.activeColor,
    this.inactiveColor,
    this.inactiveStripColor,
    this.indicatorColor,
    this.enableShadow = true,
    this.currentIndex = 0,
    this.showIndicator = true,
    this.animateItem = true,
    this.height = DEFAULT_BAR_HEIGHT,
    this.indicatorHeight = DEFAULT_INDICATOR_HEIGHT,
  })  : assert(items.length >= 2 && items.length <= 5),
        super(key: key);

  @override
  State createState() => _TitledBottomNavigationBarState();
}

class _TitledBottomNavigationBarState extends State<TitledBottomNavigationBar> {
  Curve get curve => widget.curve;

  bool get showIndicator => widget.showIndicator;

  bool get animateItem => widget.animateItem;

  List<TitledNavigationBarItem> get items => widget.items;

  double width = 0;
  Color? activeColor;
  Duration duration = Duration(milliseconds: 270);
  int touchIndex = -1;

  double _getIndicatorPosition(int index) {
    var isLtr = Directionality.of(context) == TextDirection.ltr;
    if (isLtr)
      return lerpDouble(-1.0, 1.0, index / (items.length - 1))!;
    else
      return lerpDouble(1.0, -1.0, index / (items.length - 1))!;
  }

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    activeColor = widget.activeColor ?? Theme.of(context).indicatorColor;

    return Container(
      height: widget.height + MediaQuery.of(context).viewPadding.bottom,
      width: width,
      decoration: BoxDecoration(
        color: widget.inactiveStripColor ?? Theme.of(context).cardColor,
        boxShadow: widget.enableShadow
            ? [
                BoxShadow(color: Colors.black12, blurRadius: 10),
              ]
            : null,
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: items.map((item) {
                var index = items.indexOf(item);
                return GestureDetector(
                  onTap: () => _select(index),
                  onTapDown: (TapDownDetails detail) {
                    touchIndex = index;
                    setState(() {});
                  },
                  onTapUp: (TapUpDetails detail) {
                    touchIndex = -1;
                    setState(() {});
                  },
                  child: _buildItemWidget(
                      item, index == widget.currentIndex, index == touchIndex),
                );
              }).toList(),
            ),
          ),
          if (this.showIndicator)
            Positioned(
              top: 0,
              width: width,
              child: AnimatedAlign(
                alignment:
                    Alignment(_getIndicatorPosition(widget.currentIndex), 0),
                curve: curve,
                duration: duration,
                child: Container(
                  color: widget.indicatorColor ?? activeColor,
                  width: width / items.length,
                  height: widget.indicatorHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _select(int index) {
    widget.currentIndex = index;
    widget.onTap(widget.currentIndex);

    setState(() {});
  }

  Widget _buildIcon(TitledNavigationBarItem item, bool isSelect) {
    return Stack(
      children: [
        Positioned(
          child: SizedBox(
            width: 35,
            height: 35,
            child: IconTheme(
              data: IconThemeData(
                color: isSelect ? activeColor : widget.inactiveColor,
              ),
              child: item.icon,
            ),
          ),
        ),
        if (item.badge != null)
          Positioned(
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.all(Radius.circular(20))),
              child: SizedBox(
                child: Center(
                  child: Padding(
                      child: Text(
                        item.badge!,
                        style: TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      padding: const EdgeInsets.all(1)),
                ),
                width: 15,
                height: 15,
              ),
            ),
            right: 0,
            top: 0,
          ),
      ],
    );
  }

  Widget _buildText(TitledNavigationBarItem item, bool isSelect) {
    return DefaultTextStyle.merge(
      child: item.title,
      style: TextStyle(color: isSelect ? activeColor : widget.inactiveColor),
    );
  }

  Widget _buildItemWidget(
      TitledNavigationBarItem item, bool isSelected, bool isTouched) {
    return AnimatedScale(
      scale: animateItem
          ? isTouched
              ? 0.8
              : 1
          : 1,
      duration: const Duration(milliseconds: 200),
      child: Container(
        color: item.backgroundColor,
        height: widget.height,
        width: width / items.length,
        child: Column(
          // alignment: AlignmentDirectional.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildIcon(item, isSelected),
            _buildText(item, isSelected),
          ],
        ),
      ),
    );
  }
}
