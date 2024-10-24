import Foundation

public struct CardReview: Codable {
  /// The post-review card.
  public var card: Card

  /// The review log.
  public var reviewLog: ReviewLog

  /// Initialize a new card review.
  ///
  /// - Parameters:
  ///   - card: The post-review card.
  ///   - oldCard: The pre-review card.
  ///   - rating: The rating given to the card.
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
