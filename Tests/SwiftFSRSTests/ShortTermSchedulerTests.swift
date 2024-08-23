import XCTest

@testable import SwiftFSRS

final class ShortTermSchedulerTests: XCTestCase {
  override func setUp() {
    super.setUp()
    continueAfterFailure = false
  }

  func testSchedulingSteadyProgress() async throws {
    let jsonFile = Bundle.module.url(
      forResource: "short-term-bench-steady",
      withExtension: "json"
    )!

    let data = try Data(contentsOf: jsonFile)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // 2022-12-23T09:26:00.000Z
    decoder.dateDecodingStrategy = .iso8601

    let expectedCards = try decoder.decode([Card].self, from: data)

    let simulatedRatings = [
      Rating.again,
      .again,
      .hard,
      .hard,
      .good,
      .good,
      .good,
      .good,
      .easy,
      .easy,
      .easy,
      .easy,
    ]

    let reviewCards = try await reviewCards(
      from: jsonFile,
      simulatedRatings: simulatedRatings,
      firstCard: expectedCards[0]
    )

    for (index, card) in reviewCards.enumerated() {
      XCTAssertEqual(expectedCards[index], card)
    }
  }

  func testSchedulingUnsteadyProgress() async throws {
    let jsonFile = Bundle.module.url(
      forResource: "short-term-bench-unsteady",
      withExtension: "json"
    )!

    let data = try Data(contentsOf: jsonFile)
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase

    // 2022-12-23T09:26:00.000Z
    decoder.dateDecodingStrategy = .iso8601

    let expectedCards = try decoder.decode([Card].self, from: data)

    let simulatedRatings = [
      Rating.again,
      .hard,
      .again,
      .again,
      .hard,
      .good,
      .good,
      .again,
      .easy,
    ]

    let reviewCards = try await reviewCards(
      from: jsonFile,
      simulatedRatings: simulatedRatings,
      firstCard: expectedCards[0]
    )

    for (index, card) in reviewCards.enumerated() {
      XCTAssertEqual(expectedCards[index], card)
    }
  }

  private func reviewCards(
    from jsonFile: URL,
    simulatedRatings: [Rating],
    firstCard: Card
  ) async throws -> [Card] {
    let scheduler = ShortTermScheduler()
    var reviewCards = [firstCard]

    for rating in simulatedRatings {
      guard let previousCard = reviewCards.last
      else { continue }

      let review = scheduler.schedule(
        card: previousCard,
        algorithm: .v5,
        reviewRating: rating,
        reviewTime: previousCard.due
      )

      reviewCards.append(review.card)
    }

    return reviewCards
  }
}
