import Foundation

public struct CardReview: Codable {
  public var card: Card
  public var reviewLog: ReviewLog

  // Unlike other implementations, we only persist pre-review data in the review log
  public init(card: Card, oldCard: Card, rating: Rating) {
    self.card = card

    self.reviewLog = .init(
      rating: rating,
      status: oldCard.status,
      due: oldCard.due,
      stability: oldCard.stability,
      difficulty: oldCard.difficulty,
      elapsedDays: oldCard.elapsedDays,
      scheduledDays: oldCard.scheduledDays,
      reviewedAt: Date()
    )
  }
}
