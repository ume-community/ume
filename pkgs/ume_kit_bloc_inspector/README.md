# ume_kit_bloc_inspector

A UME kit for debugging `flutter_bloc` states and events.

## Getting Started

1.  Add this to your package's `pubspec.yaml` file:

```yaml
dev_dependencies:
  ume_kit_bloc_inspector:
    path: path/to/ume_kits/packages/ume_kit_bloc_inspector
```

2.  Initialize the kit in your `main.dart` before `runApp`.

```dart
import 'package:ume_kit_bloc_inspector/ume_kit_bloc_inspector.dart';

void main() {
  // ...
  UmeKitBloc.initialize();
  // ...
  runApp(MyApp());
}
```

3.  Register the plugin with UME.

```dart
import 'package:ume/ume.dart';
import 'package:ume_kit_bloc_inspector/ume_kit_bloc_inspector.dart';
import 'package:flutter/foundation.dart';

// ...
if (kDebugMode) {
  PluginManager.instance.register(const UmeKitBloc());
}
//...
```

Now you can see BLoC events in the UME panel.

## Features

TODO: List what your package can do. Maybe include images, gifs, or videos.

## Usage

TODO: Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
const like = 'sample';
```

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
