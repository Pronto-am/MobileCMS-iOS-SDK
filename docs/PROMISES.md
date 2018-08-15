# Promises

For more information about promises, see [google/promises](https://github.com/google/promises).

You can convert promises to your own handling type:

## Regular closures

```swift
extension Promise {
    func closure(_ handle: @escaping ((Value?, Swift.Error?) -> Void)) {
        self.then { result in
            handle(result, nil)
        }.catch { error in
            handle(nil, error)
        }
    }
}
```

And use it like so:

```swift
let collection = ProntoCollection<Location>()
collection.list().closure { value, error in
    // ...
}
```

## Result closures
Using [antitypical's Result](https://github.com/antitypical/Result):

```swift
extension Promise {
    func closure<U: Swift.Error>(_ handle: @escaping ((Result<Value, U>) -> Void)) {
        self.then { result in
            handle(.success(result))
        }.catch { error in
            handle(.failure(error))
        }
    }
}
```

And use it like so:

```swift
let collection = ProntoCollection<Location>()
collection.list().closure { result in
    switch result {
        case .success(let value):
        break
        
        case .failure(let error):
        break
    }
}
```

## RxSwift
Using [RxSwift](https://github.com/ReactiveX/RxSwift):

```swift
import RxSwift

extension Promise: ReactiveCompatible { }

extension Reactive where Base: Promise {
    func asObservable() -> Observable<Value> {
        return Observable<Value>.create { observer in
            self.base.then { value in
                observer.onNext(value)
            }.catch { error in
                observer.onError(error)
            }

            return Disposables.create { }
        }
    }
}
```
And use it like so:

```swift
let collection = ProntoCollection<Location>()
collection.list().rx.asObservable() // ... rxswift etc.
```
