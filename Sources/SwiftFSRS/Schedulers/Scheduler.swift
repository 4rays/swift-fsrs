import Foundation

public protocol Scheduler {
  /// Schedule a card for review.
  ///
  /// - Parameters:
  ///  - card: The card to schedule.
  /// - grade: The grade assigned to the card.
  /// - algorithm: The FSRS algorithm to use.
  func schedule(
    card: Card,
    algorithm: FSRSAlgorithm,
    reviewRating: Rating,
    reviewTime: Date
  ) -> CardReview
}

public enum SchedulerType: String, Codable, Hashable, Sendable {
  case shortTerm
  case longTerm

  public var implementation: any Scheduler {
    switch self {
    case .shortTerm: ShortTermScheduler()
    case .longTerm: LongTermScheduler()
    }
  }
}
