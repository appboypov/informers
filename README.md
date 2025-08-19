# Informers

[![Pub Version](https://img.shields.io/pub/v/informers)](https://pub.dev/packages/informers)
[![License: MIT](https://img.shields.io/badge/license-MIT-purple.svg)](https://opensource.org/licenses/MIT)

`Informers` is a Flutter package providing enhanced `ChangeNotifier` implementations for managing and listening to changes in various data structures. It offers a more feature-rich alternative to Flutter's built-in `ValueNotifier`, with convenient methods for updating values, collections (lists, maps, sets) and controlling notifications.

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [`Informer<T>`](#informert-basic-informer)
  - [`ListInformer<T>`](#listinformert-list-informer)
  - [`MapInformer<E, T>`](#mapinformere-t-map-informer)
  - [`SetInformer<T>`](#setinformert-set-informer)
  - [`MaxLengthListInformer<T>`](#maxlengthlistinformert)
  - [`InformNotifier`](#informnotifier)
- [Contributing](#contributing)
- [License](#license)

## Features

*   **`Informer<T>`:** A general-purpose informer for single values, similar to `ValueNotifier<T>`, but with added control over notifications and update behavior.
*   **`ListInformer<T>`:** An informer specifically designed for lists, providing methods for adding, removing, updating, and querying list elements with optional change notifications.
*   **`MapInformer<E, T>`:** An informer for maps, offering similar functionalities as `ListInformer` but tailored for key-value pairs.
*   **`SetInformer<T>`:** An informer for sets, providing methods like add, remove, contains and clear.
*   **`MaxLengthListInformer<T>`:** Similar to `ListInformer<T>` but with a maximum length, automatically trimming older entries when new ones are added beyond the limit.
*   **`InformNotifier`:** An abstract class that exposes the `notifyListeners()` method as `rebuild()`, allowing for more explicit control over when to notify listeners.
*   **Fine-grained notification control:**
    *   Choose to notify listeners on every update or only when the value *actually* changes.
    *   Methods like `silentUpdate` and `silentUpdateCurrent` allow for updates without triggering notifications.
    *   The `doNotifyListeners` parameter in update methods provides explicit control.
*   **Force Update:** A `forceUpdate` flag (defaulting to `false`) allows you to force updates and notifications even if the new value is identical to the old one. This is useful in scenarios where you need to trigger a rebuild regardless of value equality.
*   **`updateCurrent` methods:** These methods allow you to update the value based on the *current* value, using a callback function. This is extremely useful for immutable data structures and avoids creating temporary objects.
*   **Convenience Methods:** Includes `data` getter/setter as an alias for `value`/`update()`.
*   **Type-safe:** All informers are generic, ensuring type safety at compile time.

## Installation

Add `informers` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  informers: ^latest_version # Replace latest_version with the actual version from pub.dev
```

Then run:

```bash
flutter pub get
```

Import the package in your Dart files:

```dart
import 'package:informers/informers.dart';
// For MaxLengthListInformer specifically:
// import 'package:informers/max_length_list_informer.dart';
// For InformNotifier specifically:
// import 'package:informers/inform_notifier.dart';
import 'package:flutter/foundation.dart'; // Often needed for listEquals, mapEquals, setEquals
```

## Usage

### `Informer<T>` (Basic Informer)

Manages a single value and notifies listeners when it changes.

```dart
import 'package:informers/informer.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Create an Informer for an integer.
  // forceUpdate defaults to false. If true, listeners are notified even if the new value is the same.
  final counter = Informer<int>(0);

  counter.addListener(() {
    print('Counter changed: ${counter.value}');
  });

  // Update the value (and notify listeners by default)
  counter.value = 1; // Output: Counter changed: 1
  // Alias for update(newValue)
  // Equivalent to: counter.update(1);

  counter.update(2); // Output: Counter changed: 2

  // Using the 'data' alias
  counter.data = 3; // Output: Counter changed: 3
  // Alias for update(newValue)
  // Equivalent to: counter.update(3);
  print('Current data: ${counter.data}'); // Output: Current data: 3

  // Update the value without notifying listeners
  counter.silentUpdate(5); // No output
  print('Counter after silentUpdate: ${counter.value}'); // Output: Counter after silentUpdate: 5

  // Update the current value based on its previous value
  counter.updateCurrent((currentValue) => currentValue + 10); // Output: Counter changed: 15
  print('Counter after updateCurrent: ${counter.value}'); // Output: Counter after updateCurrent: 15

  // Silent update based on the current value
  counter.silentUpdateCurrent((currentValue) => currentValue + 5); // No output
  print('Counter after silentUpdateCurrent: ${counter.value}'); // Output: Counter after silentUpdateCurrent: 20

  // Explicitly control notification
  counter.update(25, doNotifyListeners: true); // Output: Counter changed: 25
  counter.update(30, doNotifyListeners: false); // No output
  print('Counter after explicit no-notify update: ${counter.value}'); // Output: Counter after explicit no-notify update: 30

  // Force update example
  final forcedInformer = Informer<int>(100, forceUpdate: true);
  forcedInformer.addListener(() {
    print('ForcedInformer updated: ${forcedInformer.value}');
  });

  forcedInformer.update(100); // Output: ForcedInformer updated: 100 (notifies because forceUpdate is true)
  forcedInformer.value = 100; // Output: ForcedInformer updated: 100 (notifies because forceUpdate is true)

  // Disposing the informer when no longer needed
  counter.dispose();
  forcedInformer.dispose();
}
```

### `ListInformer<T>` (List Informer)

Manages a list of values and provides methods for list manipulation.

```dart
import 'package:informers/list_informer.dart';
import 'package:flutter/foundation.dart'; // for listEquals

void main() {
  final names = ListInformer<String>(['InitialName']);

  names.addListener(() {
    print('Names updated: ${names.value}');
  });

  names.add('Alice'); // Output: Names updated: [InitialName, Alice]
  names.addAll(['Bob', 'Charlie']); // Output: Names updated: [InitialName, Alice, Bob, Charlie]

  names.remove('Bob'); // Output: Names updated: [InitialName, Alice, Charlie]
  final removedLastName = names.removeLast(); // Output: Names updated: [InitialName, Alice]
  print('Removed last name: $removedLastName'); // Output: Removed last name: Charlie

  // Update the entire list
  names.update(['David', 'Eve']); // Output: Names updated: [David, Eve]

  // Update based on the current list
  names.updateCurrent((currentList) {
    currentList.add('Frank');
    return currentList; // Or return a new list: [...currentList, 'Frank']
  }); // Output: Names updated: [David, Eve, Frank]

  // Update the first element matching a condition
  final updatedElement = names.updateFirstWhereOrNull(
    (name) => name.startsWith('D'),
    (name) => name.toUpperCase(),
  );
  // Output: Names updated: [DAVID, Eve, Frank]
  print('Updated element: $updatedElement'); // Output: Updated element: DAVID

  print('Is names list empty? ${names.isEmpty}'); // Output: Is names list empty? false
  print('Is names list not empty? ${names.isNotEmpty}'); // Output: Is names list not empty? true
  print('Does names list contain "Eve"? ${names.contains('Eve')}'); // Output: Does names list contain "Eve"? true

  names.clear(doNotifyListeners: true); // Output: Names updated: []
  print('Is names list empty after clear? ${names.isEmpty}'); // Output: Is names list empty after clear? true

  // Force update example for ListInformer
  final listForce = ListInformer<int>([1, 2, 3], forceUpdate: true);
  listForce.addListener(() {
    print('listForce updated: ${listForce.value}');
  });
  listForce.update([1, 2, 3]); // Output: listForce updated: [1, 2, 3] (notifies due to forceUpdate)

  names.dispose();
  listForce.dispose();
}
```

### `MapInformer<E, T>` (Map Informer)

Manages a map of key-value pairs.

```dart
import 'package:informers/map_informer.dart';
import 'package:flutter/foundation.dart'; // For mapEquals

void main() {
  final ages = MapInformer<String, int>({'Initial': 99});

  ages.addListener(() {
    print('Ages updated: ${ages.value}');
  });

  ages.add('Alice', 30); // Output: Ages updated: {Initial: 99, Alice: 30}

  // Update the entire map
  ages.update({'Bob': 25, 'Charlie': 40}); // Output: Ages updated: {Bob: 25, Charlie: 40}

  // Update based on the current map
  ages.updateCurrent((currentMap) {
    currentMap['David'] = 35;
    return currentMap; // Or return a new map: {...currentMap, 'David': 35}
  }); // Output: Ages updated: {Bob: 25, Charlie: 40, David: 35}

  // Update a specific key's value
  ages.updateKey('Bob', (age) => age + 1, ifAbsent: () => 0);
  // Output: Ages updated: {Bob: 26, Charlie: 40, David: 35}

  // Try to update a non-existent key, using ifAbsent
  ages.updateKey('Eve', (age) => age + 1, ifAbsent: () => 22);
  // Output: Ages updated: {Bob: 26, Charlie: 40, David: 35, Eve: 22}

  final removedValue = ages.remove('Charlie'); // Output: Ages updated: {Bob: 26, David: 35, Eve: 22}
  print('Removed Charlie\'s age: $removedValue'); // Output: Removed Charlie's age: 40

  // Put a value if the key is absent
  final previousValueEmily = ages.putIfAbsent('Emily', 42);
  // Output: Ages updated: {Bob: 26, David: 35, Eve: 22, Emily: 42}
  print('Previous value for Emily (should be 42 as it was absent): $previousValueEmily'); // Output: 42

  final previousValueBob = ages.putIfAbsent('Bob', 100); // Bob exists, so value is not updated
  // No output for listener as map content for 'Bob' didn't change in terms of value presence.
  // However, if forceUpdate was true, or if the value actually changed, it would notify.
  // To ensure notification if the value is overwritten, use `add` or `updateKey`.
  print('Previous value for Bob (should be 26): $previousValueBob'); // Output: 26
  print('Ages after trying to putIfAbsent Bob again: ${ages.value}'); // Output: Ages after trying to putIfAbsent Bob again: {Bob: 26, David: 35, Eve: 22, Emily: 42}


  ages.clear(doNotifyListeners: true); // Output: Ages updated: {}

  // Force update example for MapInformer
  final mapForce = MapInformer<String, int>({'one': 1}, forceUpdate: true);
  mapForce.addListener(() {
    print('mapForce updated: ${mapForce.value}');
  });
  mapForce.update({'one': 1}); // Output: mapForce updated: {one: 1} (notifies due to forceUpdate)

  ages.dispose();
  mapForce.dispose();
}
```

### `SetInformer<T>` (Set Informer)

Manages a set of unique values.

```dart
import 'package:informers/set_informer.dart';
import 'package:flutter/foundation.dart'; // For setEquals

void main() {
  final uniqueNumbers = SetInformer<int>({0});

  uniqueNumbers.addListener(() {
    print('Unique Numbers updated: ${uniqueNumbers.value}');
  });

  uniqueNumbers.add(1); // Output: Unique Numbers updated: {0, 1}
  uniqueNumbers.add(2); // Output: Unique Numbers updated: {0, 1, 2}
  uniqueNumbers.add(1); // No notification, as 1 is already in the set and value hasn't changed.

  uniqueNumbers.remove(0); // Output: Unique Numbers updated: {1, 2}

  // Update the entire set
  uniqueNumbers.update({3, 4, 5}); // Output: Unique Numbers updated: {3, 4, 5}

  // Update based on the current set
  uniqueNumbers.updateCurrent((currentSet) {
    currentSet.add(6);
    return currentSet; // Or return a new set: {...currentSet, 6}
  }); // Output: Unique Numbers updated: {3, 4, 5, 6}

  print('Is uniqueNumbers set empty? ${uniqueNumbers.isEmpty}'); // Output: false
  print('Is uniqueNumbers set not empty? ${uniqueNumbers.isNotEmpty}'); // Output: true
  print('Does uniqueNumbers set contain 4? ${uniqueNumbers.contains(4)}'); // Output: true
  
  final removedLast = uniqueNumbers.removeLast(); // Output: Unique Numbers updated: {3, 4, 5} (assuming 6 was last)
  print('Removed last from set: $removedLast'); // Output: Removed last from set: 6

  uniqueNumbers.clear(doNotifyListeners: true); // Output: Unique Numbers updated: {}

  // Force update example for SetInformer
  final setForce = SetInformer<int>({10}, forceUpdate: true);
  setForce.addListener(() {
    print('setForce updated: ${setForce.value}');
  });
  setForce.update({10}); // Output: setForce updated: {10} (notifies due to forceUpdate)

  uniqueNumbers.dispose();
  setForce.dispose();
}
```

### `MaxLengthListInformer<T>`

A `ListInformer` that maintains a maximum number of items. When new items are added beyond the `maxLength`, the oldest items are removed.

```dart
import 'package:informers/max_length_list_informer.dart';
import 'package:flutter/foundation.dart';

void main() {
  // Create a MaxLengthListInformer with a maximum length of 3.
  final recentItems = MaxLengthListInformer<String>([], maxLength: 3);

  recentItems.addListener(() {
    print('Recent Items updated: ${recentItems.value}');
  });

  recentItems.add('Item 1'); // Output: Recent Items updated: [Item 1]
  recentItems.add('Item 2'); // Output: Recent Items updated: [Item 1, Item 2]
  recentItems.add('Item 3'); // Output: Recent Items updated: [Item 1, Item 2, Item 3]

  // Adding a 4th item will remove 'Item 1'
  recentItems.add('Item 4'); // Output: Recent Items updated: [Item 2, Item 3, Item 4]

  // Adding multiple items
  recentItems.addAll(['Item 5', 'Item 6']);
  // Output: Recent Items updated: [Item 4, Item 5, Item 6]
  // (Item 2 and Item 3 were removed)

  // Update the entire list (respects maxLength if the new list is too long)
  recentItems.update(['A', 'B', 'C', 'D']);
  // Output: Recent Items updated: [B, C, D]

  // Update current (respects maxLength)
  recentItems.updateCurrent((currentList) => [...currentList, 'E', 'F']);
  // Output: Recent Items updated: [D, E, F]

  // Force update example
  final maxLengthListForce = MaxLengthListInformer<int>([1, 2], forceUpdate: true, maxLength: 3);
  maxLengthListForce.addListener(() {
    print('maxLengthListForce updated: ${maxLengthListForce.value}');
  });
  maxLengthListForce.update([1, 2]); // Output: maxLengthListForce updated: [1, 2]

  recentItems.dispose();
  maxLengthListForce.dispose();
}
```

### `InformNotifier`

An abstract class that your custom notifiers can extend. It provides a `rebuild()` method, which is an alias for `notifyListeners()`.

```dart
import 'package:informers/inform_notifier.dart';
// import 'package:flutter/foundation.dart'; // Not strictly needed for this example

class MyCustomService extends InformNotifier {
  String _data = "Initial Data";
  int _updateCount = 0;

  String get data => _data;
  int get updateCount => _updateCount;

  void fetchData() {
    // Simulate fetching data
    Future.delayed(Duration(seconds: 1), () {
      _data = "Fetched Data at ${DateTime.now()}";
      _updateCount++;
      print("Data fetched, calling rebuild()...");
      rebuild(); // Notify listeners
    });
  }

  void resetData() {
    _data = "Initial Data";
    _updateCount = 0;
    print("Data reset, calling rebuild()...");
    rebuild(); // Notify listeners
  }
}

void main() {
  final myService = MyCustomService();

  myService.addListener(() {
    print('MyCustomService updated: Data = "${myService.data}", Count = ${myService.updateCount}');
  });

  print("Initial state: Data = \"${myService.data}\", Count = ${myService.updateCount}");

  myService.fetchData();
  // After 1 second, you'll see:
  // Data fetched, calling rebuild()...
  // MyCustomService updated: Data = "Fetched Data at ...", Count = 1

  // Wait a bit for the first fetch to complete if running sequentially in a simple main
  Future.delayed(Duration(seconds: 2), () {
    myService.resetData();
    // Output:
    // Data reset, calling rebuild()...
    // MyCustomService updated: Data = "Initial Data", Count = 0
  });

  // Remember to dispose if it were a long-lived object in a Flutter app
  // myService.dispose();
}
```

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue on the [GitHub repository](https://github.com/ultrawideturbodev/informers/issues).

If you'd like to contribute code:

1.  Fork the repository.
2.  Create a new branch for your feature or bug fix.
3.  Make your changes.
4.  Add tests for your changes.
5.  Ensure all tests pass.
6.  Submit a pull request.

## License

This package is released under the MIT License. See the [LICENSE](LICENSE) file for details.