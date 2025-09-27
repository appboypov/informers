import 'dart:collection';

import 'package:flutter_test/flutter_test.dart';
import 'package:gherkin_unit_test/gherkin_unit_test.dart';
import 'package:informers/informers.dart';

void main() {
  MapInformerFeature().test();
}

class MapInformerFeature extends UnitFeature<MapInformer<String, String>> {
  MapInformerFeature()
      : super(
          description: 'MapInformer',
          systemUnderTest: (_) => MapInformer({}),
          setUpEach: (mocks, systemUnderTest) => systemUnderTest!.clear(),
          scenarios: [
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    MapEntry('new', 'value'),
                  ],
                ),
              ],
              description: 'Using the MapInformer.update to update the map',
              steps: [
                Given(
                  'the map informer is empty',
                  (systemUnderTest, log, box, mocks, [example]) {
                    expect(systemUnderTest.value.isEmpty, true);
                    log.success('MapInformer is empty!');
                  },
                ),
                When(
                  'the map informer value gets updated with a new value with MapInformer.update',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final MapEntry<String, String> newEntry = example.firstValue();
                    log.info(
                        'Setting the value of the MapInformer to the new value of $newEntry..');
                    systemUnderTest.update({newEntry.key: newEntry.value});
                    log.success('New value set!');
                    box.write(0, newEntry);
                  },
                ),
                Then(
                  'the map informer should have the new value as its value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final newValue = box.read<MapEntry<String, String>>(0);
                    log.info(
                        'Checking if value of MapInformer has updated to new value: $newValue.. ');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, newValue.key);
                    expect(mapEntry.value, newValue.value);
                    log.success('MapInformer has the new value!');
                  },
                )
              ],
            ), // update
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    'start',
                    'middle',
                    'end',
                  ],
                ),
              ],
              description: 'Using the MapInformer.updateCurrent to update the map',
              steps: [
                Given(
                  'the map informer has a starting value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching starting values..');
                    final startingKey = example.firstValue();
                    final startingValue = example.secondValue();
                    systemUnderTest.update(<String, String>{startingKey: startingValue});
                    log.info('System under test updated!');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, startingKey);
                    expect(mapEntry.value, startingValue);
                    log.success('MapInformer has starting values!');
                    box.write(#startingKey, startingKey);
                  },
                ),
                When(
                  'the map informer gets updated with MapInformer.updateCurrent',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Updating systemUnderTest with new value..');
                    systemUnderTest.updateCurrent(
                      (current) {
                        log.info('Fetching new value..');
                        final newValue = example.thirdValue();
                        box.write(#newValue, newValue);
                        return current..[box.read(#startingKey)] = newValue;
                      },
                    );
                    log.success('New value set!');
                  },
                ),
                Then(
                  'the current value should contain the updated value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info(
                        'Checking if current value under starting key is equal to updated value.');
                    expect(
                      systemUnderTest.value[box.read(#startingKey)],
                      box.read(#newValue),
                    );
                    log.success('Starting key has updated value!');
                  },
                )
              ],
            ), // updateCurrent
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    'key',
                    'firstValue',
                    'key',
                    'newValue',
                    'ifAbsentValue',
                    true,
                  ],
                ),
                const UnitExample(
                  values: [
                    'key',
                    'firstValue',
                    'noKey',
                    'newValue',
                    'ifAbsentValue',
                    false,
                  ],
                ),
              ],
              description: 'Using the MapInformer.updateKey to update the map',
              steps: [
                Given(
                  'the map informer has a starting value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching starting values..');
                    final startingKey = example.firstValue();
                    final startingValue = example.secondValue();
                    systemUnderTest.update(<String, String>{startingKey: startingValue});
                    log.info('System under test updated!');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, startingKey);
                    expect(mapEntry.value, startingValue);
                    log.success('MapInformer has starting values!');
                  },
                ),
                When(
                  'the map informer gets updated with MapInformer.updateKey',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Updating systemUnderTest with new value..');
                    log.info('Fetching new value..');
                    final newValue = example.fourthValue();
                    final ifAbsentValue = example.fifthValue();
                    box.write(#newValue, newValue);
                    final newKey = example.thirdValue();
                    box.write(#newKey, newKey);
                    systemUnderTest.updateKey(
                      newKey,
                      (value) => newValue,
                      ifAbsent: () => ifAbsentValue,
                    );
                    log.success('New value set!');
                  },
                ),
                Then(
                  'the value should be the newValue if key present, or else it should be the ifAbsent value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info(
                        'Checking if current value under starting key is equal to updated value.');
                    final hasKey = example.sixthValue();
                    expect(
                      systemUnderTest.value[box.read(#newKey)] == box.read(#newValue),
                      hasKey,
                    );
                    log.success('Starting key has updated value!');
                  },
                )
              ],
            ), // updateKey
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    MapEntry('new', 'value'),
                  ],
                ),
              ],
              description: 'Using the MapInformer.add to update the map',
              steps: [
                Given(
                  'the map informer is empty',
                  (systemUnderTest, log, box, mocks, [example]) {
                    expect(systemUnderTest.value.isEmpty, true);
                    log.success('MapInformer is empty!');
                  },
                ),
                When(
                  'the map informer value gets updated with a new value with MapInformer.add',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final MapEntry<String, String> newEntry = example.firstValue();
                    log.info(
                        'Setting the value of the MapInformer to the new value of $newEntry..');
                    systemUnderTest.add(newEntry.key, newEntry.value);
                    log.success('New value set!');
                    box.write(0, newEntry);
                  },
                ),
                Then(
                  'the map informer should have the new value as its value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final newValue = box.read<MapEntry<String, String>>(0);
                    log.info(
                        'Checking if value of MapInformer has updated to new value: $newValue.. ');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, newValue.key);
                    expect(mapEntry.value, newValue.value);
                    log.success('MapInformer has the new value!');
                  },
                )
              ],
            ), // add
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    'key',
                    'firstValue',
                    'key',
                    true,
                  ],
                ),
                const UnitExample(
                  values: [
                    'key',
                    'firstValue',
                    'noKey',
                    false,
                  ],
                ),
              ],
              description: 'Using the MapInformer.remove to remove a value from the map',
              steps: [
                Given(
                  'the map informer has a starting value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching starting values..');
                    final startingKey = example.firstValue();
                    final startingValue = example.secondValue();
                    systemUnderTest.update(<String, String>{startingKey: startingValue});
                    log.info('System under test updated!');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, startingKey);
                    expect(mapEntry.value, startingValue);
                    box.write('startingKey', startingKey);
                    log.success('MapInformer has starting values!');
                  },
                ),
                When(
                  'the map informer gets a value removed with MapInformer.remove',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching key to be removed..');
                    final keyToBeRemoved = example.thirdValue();
                    log.info('Try to remove key $keyToBeRemoved..');
                    final result = systemUnderTest.remove(keyToBeRemoved);
                    box.write('result', result);
                    log.success('Tried removing key $keyToBeRemoved!');
                  },
                ),
                Then(
                  'the value should be removed if the was present',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final bool hasRemoveKey = example.fourthValue();
                    log.info('Checking if key is present..');
                    final valueIsRemoved = systemUnderTest.value[box.read('startingKey')] == null;
                    expect(valueIsRemoved, hasRemoveKey);
                    if (hasRemoveKey) {
                      log.success('Key found!');
                    } else {
                      log.success('Key not found!');
                    }
                    log.info('Checking if remove method returned result..');
                    expect(box.read('result') != null, hasRemoveKey);
                    if (hasRemoveKey) {
                      log.success('Result found!');
                    } else {
                      log.success('Result not found!');
                    }
                  },
                )
              ],
            ), // remove
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    'presentKey',
                    'firstValue',
                    'absentKey',
                    'absentValue',
                    true,
                  ],
                ),
                const UnitExample(
                  values: [
                    'presentKey',
                    'firstValue',
                    'presentKey',
                    'presentValue',
                    false,
                  ],
                ),
              ],
              description: 'Using the MapInformer.putIfAbsent method to update the map',
              steps: [
                Given(
                  'the map informer has a starting value',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching starting values..');
                    final startingKey = example.firstValue();
                    final startingValue = example.secondValue();
                    systemUnderTest.update(<String, String>{startingKey: startingValue});
                    log.info('System under test updated!');
                    final mapEntry = systemUnderTest.value.entries.single;
                    expect(mapEntry.key, startingKey);
                    expect(mapEntry.value, startingValue);
                    log.success('MapInformer has starting values!');
                  },
                ),
                When(
                  'the map informer gets a value update with MapInformer.putIfAbsent',
                  (systemUnderTest, log, box, mocks, [example]) {
                    log.info('Fetching key to be updated..');
                    final updateKey = example.thirdValue();
                    final valueIfAbsent = example.fourthValue();
                    log.info('Updating key $updateKey..');
                    final result = systemUnderTest.putIfAbsent(updateKey, valueIfAbsent);
                    box.write('result', result);
                    box.write('valueIfAbsent', valueIfAbsent);
                    box.write('updateKey', updateKey);
                    log.success('Updated key $updateKey with MapInformer.putIfAbsent!');
                  },
                ),
                Then(
                  'the key should have the value if it was not present',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final keyWasAbsent = example.fifthValue();
                    final result = box.read('result');
                    final valueIfAbsent = box.read('valueIfAbsent');
                    final updateKey = box.read('updateKey');
                    log.success('Checking if value was absent..');
                    expect(systemUnderTest.value[updateKey] == valueIfAbsent, keyWasAbsent);
                    expect(result == valueIfAbsent, keyWasAbsent);
                    log.success('Value was${keyWasAbsent ? '' : ' not'} absent');
                  },
                )
              ],
            ), // putIfAbsent
            UnitScenario(
              examples: [
                const UnitExample(
                  values: [
                    {
                      '3': 'Three',
                      '1': 'One',
                    },
                    ['2', 'Two'],
                  ],
                ),
              ],
              description: 'Using a different implementation of Map keeps the implementation',
              steps: [
                Given(
                  'the Map informer uses a (monotonically increasing) SplayTreeMap implementation',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final initialMapData = example.firstValue<Map<String, String>>();
                    int comp(String a, String b) => a.compareTo(b);
                    final sut = MapInformer<String, String>(
                      SplayTreeMap<String, String>(comp),
                      copier: (map) => SplayTreeMap<String, String>.from(map, comp),
                    );
                    sut.update(initialMapData);
                    box.write(#sut, sut);
                    expect(sut.value, isA<SplayTreeMap<String, String>>());
                    log.success(
                        'MapInformer initialized with SplayTreeMap preserving type and order!');
                  },
                ),
                When(
                  'the map informer added with a new value in between the existing values',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final sut = box.read<MapInformer<String, String>>(#sut);
                    final newEntry = example.secondValue<List<String>>();
                    sut.add(newEntry.first, newEntry.last);
                    log.success('New value inserted!');
                  },
                ),
                Then(
                  'the added value should appear in between the existing values',
                  (systemUnderTest, log, box, mocks, [example]) {
                    final initialMapData = example.firstValue<Map<String, String>>();
                    final newEntry = example.secondValue<List<String>>();
                    final sut = box.read<MapInformer<String, String>>(#sut);
                    int comp(String a, String b) => a.compareTo(b);
                    final expectedKeys = SplayTreeMap<String, String>(comp)
                      ..addAll(initialMapData)
                      ..[newEntry.first] = newEntry.last;
                    log.info('Checking if current value is in between the existing values.');

                    expect(sut.value, isA<SplayTreeMap<String, String>>());
                    expect(
                      sut.value.keys.toList(growable: false),
                      expectedKeys.keys.toList(growable: false),
                    );
                    log.success('Starting key has updated value!');
                  },
                )
              ],
            ),
          ],
        );
}
