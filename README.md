# SwiftFSRS

An idiomatic and configurable Swift implementation of the [FSRS spaced repetition algorithm](https://github.com/open-spaced-repetition/fsrs4anki/wiki/The-Algorithm).

The workhorse of the algorithm is the `Scheduler` protocol. It takes a card and a review and returns a new card and review log object.

Out of the box, the library ships with a short-term and a long-term scheduler.
Use the short-term scheduler when you want to support multiple reviews of the same card in a single day. Use the long-term scheduler otherwise.

The library uses `v5` of the FSRS algorithm but supports is designed to support custom algorithm implementations, and by defaults ships with the `v5` implementation.

## Installation

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "")
]
```

## Usage

To review a card:

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

## Customization

To customize the algorithm, you can implement the `Scheduler` protocol:

```swift
import SwiftFSRS

struct CustomScheduler: Scheduler {
  func schedule(card: Card, algorithm: Algorithm, reviewRating: ReviewRating, reviewTime: Date) -> (Card, ReviewLog) {
    // Implement your custom algorithm here
  }
}
```

You can also implement your own `FSRSAlgorithm`:

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

## License

SwiftFSRS is available under the MIT license. See the LICENSE file for more info.
