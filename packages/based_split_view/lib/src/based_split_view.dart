import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

enum SplitMode { flex, width }

class BasedSplitView extends StatelessWidget {
  const BasedSplitView({
    super.key,
    this.navigatorKey,
    required this.leftWidget,
    this.rightPlaceholder = const _BasedSplitViewPlaceholder(),
    this.dividerWidth = 0.5,
    this.splitMode = SplitMode.width,
    this.leftFlex = 1,
    this.rightFlex = 3,
    this.leftWidth = 364,
    this.breakPoint = 364 * 2,
  });

  final GlobalKey<NavigatorState>? navigatorKey;

  /// Prefer to add a `GlobalKey` for keep the state of [leftWidget]
  final Widget leftWidget;

  /// Present when there's no page pushed
  final Widget rightPlaceholder;

  /// Width of divider, only show when [dividerWidth] > 0
  final double dividerWidth;

  final SplitMode splitMode;
  final int leftFlex;
  final int rightFlex;
  final double leftWidth;
  final double breakPoint;

  @override
  Widget build(BuildContext context) {
    final key = navigatorKey ?? GlobalKey<NavigatorState>();

    return NavigatorPopHandler(
      onPop: key.currentState?.maybePop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final singleView = constraints.maxWidth <= breakPoint;

          if (singleView) {
            return Navigator(
              key: key,
              onPopPage: (route, result) {
                /// prevent to pop root page
                if (route.isFirst) return false;
                return route.didPop(result);
              },
              pages: [
                CupertinoPage(
                  child: leftWidget,
                ),
              ],
            );
          }

          return Row(
            children: [
              switch (splitMode) {
                SplitMode.flex => Expanded(
                    flex: leftFlex,
                    child: leftWidget,
                  ),
                SplitMode.width => SizedBox(
                    width: leftWidth,
                    child: leftWidget,
                  )
              },
              if (dividerWidth > 0) VerticalDivider(width: dividerWidth),
              Expanded(
                flex: rightFlex,
                child: ScaffoldMessenger(
                  child: Navigator(
                    key: key,
                    onPopPage: (route, result) {
                      /// prevent to pop root page
                      if (route.isFirst) return false;
                      return route.didPop(result);
                    },
                    pages: [
                      CupertinoPage(
                        child: Center(
                          child: rightPlaceholder,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _BasedSplitViewPlaceholder extends StatelessWidget {
  const _BasedSplitViewPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Text(
          'BasedSplitView',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
