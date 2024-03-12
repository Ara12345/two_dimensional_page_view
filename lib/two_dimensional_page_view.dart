library two_dimensional_page_view;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';

class StartPosition {
  final int xIndex;
  final int yIndex;

  const StartPosition({
    required this.xIndex,
    required this.yIndex,
  });
}

class TwoDimensionalPageView extends StatefulWidget {
  const TwoDimensionalPageView({
    super.key,
    required this.delegate,
    this.initialPosition = const StartPosition(xIndex: 1, yIndex: 1),
    this.onSwipe,
    this.primary,
    this.mainAxis = Axis.vertical,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    this.dragStartBehavior = DragStartBehavior.start,
    this.clipBehavior = Clip.hardEdge,
    this.cacheExtent,
  });

  final TwoDimensionalPageBuilderDelegate delegate;
  final StartPosition initialPosition;
  final void Function(int xIndex, int yIndex)? onSwipe;
  final bool? primary;
  final Axis mainAxis;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final DragStartBehavior dragStartBehavior;
  final Clip clipBehavior;
  final double? cacheExtent;

  @override
  State<TwoDimensionalPageView> createState() => _TwoDimensionalPageViewState();
}

class _TwoDimensionalPageViewState extends State<TwoDimensionalPageView> {
  late TwoDimensionalPageBuilderDelegate delegate;

  late final PageController verticalController;
  late final PageController horizontalController;

  late final ValueNotifier<ChildVicinity> pageChangeNotifier;

  @override
  void initState() {
    delegate = widget.delegate;

    assert(delegate.matrix.length > 3, 'Matrix should have at least 3 items');
    _assertValidMatrix();
    verticalController = PageController(initialPage: 1);
    horizontalController = PageController(initialPage: 1);

    pageChangeNotifier = ValueNotifier(ChildVicinity(
      xIndex: widget.initialPosition.xIndex,
      yIndex: widget.initialPosition.yIndex,
    ));
    super.initState();
  }

  void _assertValidMatrix() {
    int sum = 0;
    for (var e in delegate.matrix) {
      sum += e.length;
    }
    assert(
        sum % delegate.matrix.length == 0, 'Not valid matrix, e.g. 2x3, 3x4');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ChildVicinity>(
        valueListenable: pageChangeNotifier,
        builder: (context, value, _) {
          return _TwoDimensionalPageView(
            diagonalDragBehavior: DiagonalDragBehavior.free,
            key: UniqueKey(),
            center: value,
            cacheExtent: widget.cacheExtent,
            clipBehavior: widget.clipBehavior,
            dragStartBehavior: widget.dragStartBehavior,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            mainAxis: widget.mainAxis,
            primary: widget.primary,
            onSwipe: (xIndex, yIndex) {
              pageChangeNotifier.value =
                  ChildVicinity(xIndex: xIndex, yIndex: yIndex);
              widget.onSwipe?.call(xIndex, yIndex);
            },
            horizontalDetails: ScrollableDetails.horizontal(
              controller: horizontalController,
              physics: const PageScrollPhysics(),
            ),
            verticalDetails: ScrollableDetails.vertical(
              controller: verticalController,
              physics: const PageScrollPhysics(),
            ),
            delegate: delegate,
          );
        });
  }
}

class _TwoDimensionalPageView extends TwoDimensionalScrollView {
  const _TwoDimensionalPageView({
    super.key,
    super.primary,
    super.mainAxis = Axis.vertical,
    required this.center,
    super.cacheExtent,
    super.dragStartBehavior = DragStartBehavior.start,
    super.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.onDrag,
    super.diagonalDragBehavior = DiagonalDragBehavior.none,
    super.verticalDetails = const ScrollableDetails.vertical(),
    super.horizontalDetails = const ScrollableDetails.horizontal(),
    super.clipBehavior = Clip.hardEdge,
    required TwoDimensionalPageBuilderDelegate delegate,
    this.onSwipe,
  }) : super(
          delegate: delegate,
        );

  final void Function(int xIndex, int yIndex)? onSwipe;
  final ChildVicinity center;
  @override
  Widget buildViewport(
    BuildContext context,
    ViewportOffset verticalOffset,
    ViewportOffset horizontalOffset,
  ) {
    return _TwoDimensionalPageViewport(
      key: key,
      center: center,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalDetails.direction,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalDetails.direction,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalPageBuilderDelegate,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      onSwipe: onSwipe,
    );
  }
}

class _TwoDimensionalPageViewport extends TwoDimensionalViewport {
  const _TwoDimensionalPageViewport({
    super.key,
    required this.center,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.delegate,
    required super.mainAxis,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    this.onSwipe,
  });

  final ChildVicinity center;

  final void Function(int xIndex, int yIndex)? onSwipe;

  @override
  _RenderTwoDimensionalPageViewport createRenderObject(BuildContext context) {
    return _RenderTwoDimensionalPageViewport(
      center: center,
      horizontalOffset: horizontalOffset,
      horizontalAxisDirection: horizontalAxisDirection,
      verticalOffset: verticalOffset,
      verticalAxisDirection: verticalAxisDirection,
      mainAxis: mainAxis,
      delegate: delegate as TwoDimensionalPageBuilderDelegate,
      childManager: context as TwoDimensionalChildManager,
      cacheExtent: cacheExtent,
      clipBehavior: clipBehavior,
      onSwipe: onSwipe,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    _RenderTwoDimensionalPageViewport renderObject,
  ) {
    renderObject
      ..horizontalOffset = horizontalOffset
      ..horizontalAxisDirection = horizontalAxisDirection
      ..verticalOffset = verticalOffset
      ..verticalAxisDirection = verticalAxisDirection
      ..mainAxis = mainAxis
      ..delegate = delegate
      ..cacheExtent = cacheExtent
      ..clipBehavior = clipBehavior;
  }
}

class _RenderTwoDimensionalPageViewport extends RenderTwoDimensionalViewport {
  _RenderTwoDimensionalPageViewport({
    required this.center,
    required super.horizontalOffset,
    required super.horizontalAxisDirection,
    required super.verticalOffset,
    required super.verticalAxisDirection,
    required TwoDimensionalPageBuilderDelegate delegate,
    required super.mainAxis,
    required super.childManager,
    super.cacheExtent,
    super.clipBehavior = Clip.hardEdge,
    this.onSwipe,
  }) : super(delegate: delegate);
  final ChildVicinity center;

  final void Function(int xIndex, int yIndex)? onSwipe;

  @override
  void performLayout() {
    super.performLayout();

    var deltaX = 0;
    var deltaY = 0;

    if (horizontalOffset.userScrollDirection == ScrollDirection.idle &&
        verticalOffset.userScrollDirection == ScrollDirection.idle) {
      deltaX = (horizontalOffset.pixels / viewportDimension.width - 1).round();
      deltaY = (verticalOffset.pixels / viewportDimension.height - 1).round();
    }

    if (deltaX != 0 || deltaY != 0) {
      final builderDelegate = delegate as TwoDimensionalPageBuilderDelegate;

      final maxRowIndex = builderDelegate.matrix.length - 1;
      deltaX = recycleIndexIfAtEdge(center.xIndex + deltaX, maxRowIndex);
      final maxColumnIndex = builderDelegate.matrix[deltaX].length - 1;
      deltaY = recycleIndexIfAtEdge(center.yIndex + deltaY, maxColumnIndex);
      SchedulerBinding.instance.addPostFrameCallback((_) {
        onSwipe?.call(
          deltaX,
          deltaY,
        );
      });
    }
  }

  @override
  void layoutChildSequence() {
    final horizontalPixels = horizontalOffset.pixels;
    final verticalPixels = verticalOffset.pixels;
    final viewportWidth = viewportDimension.width;
    final viewportHeight = viewportDimension.height;

    final builderDelegate = delegate as TwoDimensionalPageBuilderDelegate;

    final maxRowIndex = builderDelegate.matrix.length - 1;

    var rowIndex = recycleIndexIfAtEdge(center.xIndex, maxRowIndex);
    var leadingRowIndex = recycleIndexIfAtEdge(rowIndex - 1, maxRowIndex);
    var trailingRowIndex = recycleIndexIfAtEdge(rowIndex + 1, maxRowIndex);

    final rowIndexes = [
      leadingRowIndex,
      rowIndex,
      trailingRowIndex,
    ];

    var xLayoutOffset = -(horizontalPixels);

    for (var rIndex in rowIndexes) {
      var yLayoutOffset = -(verticalPixels);

      final maxColumnIndex = builderDelegate.matrix[rIndex].length - 1;

      var columnIndex = recycleIndexIfAtEdge(center.yIndex, maxColumnIndex);
      var leadingColumnIndex =
          recycleIndexIfAtEdge(columnIndex - 1, maxColumnIndex);
      var trailingColumnIndex =
          recycleIndexIfAtEdge(columnIndex + 1, maxColumnIndex);

      final columnIndexes = [
        leadingColumnIndex,
        columnIndex,
        trailingColumnIndex
      ];

      for (var cIndex in columnIndexes) {
        final vicinity = ChildVicinity(xIndex: rIndex, yIndex: cIndex);
        final child = buildOrObtainChildFor(vicinity)!;

        child.layout(constraints.loosen());

        parentDataOf(child).layoutOffset = Offset(xLayoutOffset, yLayoutOffset);
        yLayoutOffset += viewportHeight;
      }
      xLayoutOffset += viewportWidth;
    }

    // Set the min and max scroll extents for each axis.
    verticalOffset.applyContentDimensions(
      0,
      2 * viewportHeight,
    );
    horizontalOffset.applyContentDimensions(
      0,
      2 * viewportWidth,
    );
  }
}

int recycleIndexIfAtEdge(int index, int max) {
  if (index < 0) return max;

  if (index > max) return 0;

  return index;
}

class TwoDimensionalPageBuilderDelegate<T extends Object>
    extends TwoDimensionalChildDelegate {
  /// Creates a delegate that supplies children for a [TwoDimensionalScrollView]
  /// using the given builder callback.
  TwoDimensionalPageBuilderDelegate({
    required this.builder,
    required this.matrix,
    this.addRepaintBoundaries = true,
    this.addAutomaticKeepAlive = true,
  });

  final TwoDimensionalIndexedWidgetBuilder builder;
  final List<List<T>> matrix;

  final bool addRepaintBoundaries;

  final bool addAutomaticKeepAlive;

  @override
  Widget? build(BuildContext context, ChildVicinity vicinity) {
    final maxXIndex = matrix.length - 1;
    final maxYIndex = matrix[vicinity.xIndex].length - 1;
    // If we have exceeded explicit upper bounds, return null.
    if (vicinity.xIndex < 0 || (vicinity.xIndex > maxXIndex)) {
      return null;
    }
    if (vicinity.yIndex < 0 || (vicinity.yIndex > maxYIndex)) {
      return null;
    }

    Widget? child;
    try {
      child = builder(context, vicinity);
    } catch (exception, stackTrace) {
      child = _createErrorWidget(exception, stackTrace);
    }
    if (child == null) {
      return null;
    }
    if (addRepaintBoundaries) {
      child = RepaintBoundary(child: child);
    }
    if (addAutomaticKeepAlive) {
      child = AutomaticKeepAlive(child: _SelectionKeepAlive(child: child));
    }
    return child;
  }

  @override
  bool shouldRebuild(covariant TwoDimensionalChildDelegate oldDelegate) => true;
}

// Return a Widget for the given Exception
Widget _createErrorWidget(Object exception, StackTrace stackTrace) {
  final FlutterErrorDetails details = FlutterErrorDetails(
    exception: exception,
    stack: stackTrace,
    library: 'widgets library',
    context: ErrorDescription('building'),
  );
  FlutterError.reportError(details);
  return ErrorWidget.builder(details);
}

class _SelectionKeepAlive extends StatefulWidget {
  /// Creates a widget that listens to [KeepAliveNotification]s and maintains a
  /// [KeepAlive] widget appropriately.
  const _SelectionKeepAlive({
    required this.child,
  });

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<_SelectionKeepAlive> createState() => _SelectionKeepAliveState();
}

class _SelectionKeepAliveState extends State<_SelectionKeepAlive>
    with AutomaticKeepAliveClientMixin
    implements SelectionRegistrar {
  Set<Selectable>? _selectableWithSelections;
  Map<Selectable, VoidCallback>? _selectableAttachments;
  SelectionRegistrar? _registrar;

  @override
  bool get wantKeepAlive => _wantKeepAlive;
  bool _wantKeepAlive = false;
  set wantKeepAlive(bool value) {
    if (_wantKeepAlive != value) {
      _wantKeepAlive = value;
      updateKeepAlive();
    }
  }

  VoidCallback listensTo(Selectable selectable) {
    return () {
      if (selectable.value.hasSelection) {
        _updateSelectableWithSelections(selectable, add: true);
      } else {
        _updateSelectableWithSelections(selectable, add: false);
      }
    };
  }

  void _updateSelectableWithSelections(Selectable selectable,
      {required bool add}) {
    if (add) {
      assert(selectable.value.hasSelection);
      _selectableWithSelections ??= <Selectable>{};
      _selectableWithSelections!.add(selectable);
    } else {
      _selectableWithSelections?.remove(selectable);
    }
    wantKeepAlive = _selectableWithSelections?.isNotEmpty ?? false;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final SelectionRegistrar? newRegistrar =
        SelectionContainer.maybeOf(context);
    if (_registrar != newRegistrar) {
      if (_registrar != null) {
        _selectableAttachments?.keys.forEach(_registrar!.remove);
      }
      _registrar = newRegistrar;
      if (_registrar != null) {
        _selectableAttachments?.keys.forEach(_registrar!.add);
      }
    }
  }

  @override
  void add(Selectable selectable) {
    final VoidCallback attachment = listensTo(selectable);
    selectable.addListener(attachment);
    _selectableAttachments ??= <Selectable, VoidCallback>{};
    _selectableAttachments![selectable] = attachment;
    _registrar!.add(selectable);
    if (selectable.value.hasSelection) {
      _updateSelectableWithSelections(selectable, add: true);
    }
  }

  @override
  void remove(Selectable selectable) {
    if (_selectableAttachments == null) {
      return;
    }
    assert(_selectableAttachments!.containsKey(selectable));
    final VoidCallback attachment = _selectableAttachments!.remove(selectable)!;
    selectable.removeListener(attachment);
    _registrar!.remove(selectable);
    _updateSelectableWithSelections(selectable, add: false);
  }

  @override
  void dispose() {
    if (_selectableAttachments != null) {
      for (final Selectable selectable in _selectableAttachments!.keys) {
        _registrar!.remove(selectable);
        selectable.removeListener(_selectableAttachments![selectable]!);
      }
      _selectableAttachments = null;
    }
    _selectableWithSelections = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (_registrar == null) {
      return widget.child;
    }
    return SelectionRegistrarScope(
      registrar: this,
      child: widget.child,
    );
  }
}
