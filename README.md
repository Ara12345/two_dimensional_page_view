# two_dimensional_page_view

A Flutter implementation of Recycling Two Dimensional page View .

## Features

* 2D scrolling
* Recycling scroll.

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  two_dimensional_page_view: <latest_version>
```

In your library add the following import:

```dart
import 'package:two_dimensional_page_view/two_dimensional_page_view.dart';
```

## Getting started

Example:

```dart
TwoDimensionalPageView(
    // Called whenever the page in the center of the viewport changes
    onSwipe: (xIndex, yIndex) {},
    // Starting position for page view
    initialPosition: const StartPosition(xIndex: 1, yIndex: 1),
    // A delegate that provides the children for the [TwoDimensionalPageView]
    delegate: TwoDimensionalPageBuilderDelegate<String>(
      // Matrix should have equal sub-lists e.g. 2x3, 3x4
      matrix: [
        ['1', '2', '3'],
        ['4', '5', '6'],
        ['7', '8', '9'],
      ],
      builder: (context, vicinity) {
        return Text('${vicinity.xIndex} ${vicinity.xIndex}');
      },
    ),
  )
```

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me so that I can take time to read the issues, fix bugs, merge pull requests and add features to these packages.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].


<!-- Links -->
[issue]: https://github.com/Ara12345/two_dimensional_page_view/issues
[pr]: https://github.com/Ara12345/two_dimensional_page_view/pulls