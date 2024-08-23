import Foundation

public struct Card: Hashable, Codable, Sendable {
  /// Date when the card is next due for review
  public var due: Date

  /// A measure of how well the information is retained
  public var stability: Double

  /// Reflects the inherent difficulty of the card content
  public var difficulty: Double

  /// Days since the card was last reviewed
  public var elapsedDays: Double

  /// The interval at which the card is next scheduled
  public var scheduledDays: Double

  /// Total number of times the card has been reviewed
  public var reps: Int

  /// Times the card was forgotten or remembered incorrectly
  public var lapses: Int

  /// The current state of the card (New, Learning, Review, Relearning)
  public var status: Status

  /// The most recent review date, if applicable
  public var lastReview: Date?

  public init(
    due: Date = Date(),
    stability: Double = 0,
    difficulty: Double = 0,
    elapsedDays: Double = 0,
    scheduledDays: Double = 0,
    reps: Int = 0,
    lapses: Int = 0,
    status: Status = .new,
    lastReview: Date? = nil
  ) {
    self.due = due
    self.stability = stability
    self.difficulty = difficulty
    self.elapsedDays = elapsedDays
    self.scheduledDays = scheduledDays
    self.reps = reps
    self.lapses = lapses
    self.status = status
    self.lastReview = lastReview
  }
}
