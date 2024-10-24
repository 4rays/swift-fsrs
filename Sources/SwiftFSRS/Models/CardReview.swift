import Foundation

public struct CardReview: Codable {
  /// The post-review card.
  public var postReviewCard: Card

  /// The review log.
  public var reviewLog: ReviewLog

  /// Initialize a new card review.
  ///
  /// - Parameters:
  ///   - postReviewCard: The post-review card.
  ///   - preReviewCard: The pre-review card.
  ///   - rating: The rating given to the card.
  public init(postReviewCard: Card, preReviewCard: Card, rating: Rating) {
    self.postReviewCard = postReviewCard

    self.reviewLog = .init(
      rating: rating,
      status: preReviewCard.status,
      due: preReviewCard.due,
      stability: preReviewCard.stability,
      difficulty: preReviewCard.difficulty,
      elapsedDays: preReviewCard.elapsedDays,
      scheduledDays: preReviewCard.scheduledDays,
      reviewedAt: Date()
    )
  }
}
