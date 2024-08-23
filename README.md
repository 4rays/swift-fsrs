# SwiftFSRS

An idiomatic and configurable Swift implementation of the [FSRS spaced repetition algorithm](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm).

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/4rays/swift-fsrs")
]
```

## Usage

### The Scheduler

The workhorse of the algorithm is the `Scheduler` protocol. It takes a card and a review and returns a new card and review log object.

Out of the box, the library ships with a short-term and a long-term scheduler.
Use the short-term scheduler when you want to support multiple reviews of the same card in a single day. Use the long-term scheduler otherwise.

Here is how you can create your own scheduler:

```swift
import SwiftFSRS

struct CustomScheduler: Scheduler {
  func schedule(card: Card, algorithm: Algorithm, reviewRating: ReviewRating, reviewTime: Date) -> (Card, ReviewLog) {
    // Implement your custom algorithm here
  }
}
```

### The Algorithm

The library implements `v5` of the FSRS algorithm out of the box. It can also support custom implementations.

```swift
import SwiftFSRS

let customAlgorithm = FSRSAlgorithm(
  decay: -0.5,
  factor: 19 / 81,
  requestRetention: 0.9,
  maximumInterval: 36500,
  parameters: [/* ... */]
)

scheduler.schedule(
  card: card,
  algorithm: customAlgorithm,
  reviewRating: .good,
  reviewTime: Date()
)
```

### Scheduling a Review

To schedule a review for a given card:

```swift
import SwiftFSRS

let scheduler = LongTermScheduler()
let card = Card()

let review = scheduler.schedule(
  card: card,
  algorithm: .v5,
  reviewRating: .good, // or .easy, .hard, .again
  reviewTime: Date()
)

print(review.card)
print(review.log)
```

Cards don't have any content properties and are meant to be properties of your own type.

```swift
import SwiftFSRS

struct MyFlashCard {
  let question: String
  let answer: String
  let fsrsCard: Card
}
```

## License

SwiftFSRS is available under the MIT license. See the LICENSE file for more info.
