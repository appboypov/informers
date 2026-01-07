## 0.0.5

* **🔄 Changed:** Updated GitHub repository URLs to appboypov organization.

## 0.0.4

* **✨ New:** Added `data` getter/setter as an alias for `value`/`update()`.
* **✨ New:** Added `silentUpdateCurrent` method for updating value based on current value without notifying listeners.

## 0.0.3+2

* **✨ New:** Added standard value setter to `Informer` class.
* **✨ New:** Added `silentUpdate` method to `Informer` class for updating values without notifying listeners.

## 0.0.3+1
* **🐛️ Bugfix:** Fixed `MapInformer` and `ListInformer` not notifying listeners unless `forceUpdate` was set to `true`.
* 
## 0.0.3

* **🐛️ Bugfix:** Fixed `MapInformer` and `ListInformer` not notifying listeners unless `forceUpdate` was set to `true`.

## 0.0.2+4

* **✨ New:** Added `MaxLengthListInformer.addAll` and `ListInformer.addAll` methods.

## 0.0.2+3

* **✨ New:** Added `MaxLengthListInformer` class.

## 0.0.2+2

* **✨ New:** Added `SetInformer` class.

## 0.0.2+1

* **🐛️ Bugfix:** Improve equality check when using `MapInformer.updateCurrent` and `ListInformer.updateCurrent`.

## 0.0.2

* **⚠️ Breaking:** Changed default `forceUpdate` behaviour of all informers to false.
* **✨ New:** Added `doNotifyListeners` option to all methods to update informers silently. This will allow for updating several informers at once, calling the rebuild function yourself and only trigger one rebuild with all new values.

## 0.0.1+6

* **⚠️ Breaking:** Changed default `forceUpdate` behaviour of all informers to false.

## 0.0.1+5

* Update example project.

## 0.0.1+4

* Update readme.

## 0.0.1+3

* Added example project, unit tests and updated read me.

* **✨ New:** Added `forceUpdate`
* Update formatting

## 0.0.1+2

* Fix faulty naming of `MapInformer` and `ListInformer`.

## 0.0.1+1

* Improve ListInformer current methods.

## 0.0.1

* Initial release.
