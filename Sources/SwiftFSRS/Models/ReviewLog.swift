import Foundation

/// Review record information associated with the card, used for analysis, undoing the review, and optimization
public struct ReviewLog: Hashable, Codable, Sendable {
  /// Rating of the review (Again, Hard, Good, Easy)
  public var rating: Rating

  /// Status of the review (New, Learning, Review, Relearning)
  public var status: Status

  /// Date of the last scheduling
  public var due: Date

  /// Stability of the card before the review
  public var stability: Double

  /// Difficulty of the card before the review
  public var difficulty: Double

  /// Number of days elapsed since the last review
  public var elapsedDays: Double

  /// Number of days until the next review
  public var scheduledDays: Double

  /// Date of the review
  public var reviewedAt: Date

  public init(
    rating: Rating,
    status: Status,
    due: Date, stability: Double,
    difficulty: Double,
    elapsedDays: Double,
    scheduledDays: Double,
    reviewedAt: Date
  ) {
    self.rating = rating
    self.status = status
    self.due = due
    self.stability = stability
    self.difficulty = difficulty
    self.elapsedDays = elapsedDays
    self.scheduledDays = scheduledDays
    self.reviewedAt = reviewedAt
  }
}
