import Foundation

public struct ShortTermScheduler: Scheduler {
  public func schedule(
    card: Card,
    algorithm: FSRSAlgorithm,
    reviewRating: Rating,
    reviewTime: Date = Date()
  ) -> CardReview {
    var newCard = card

    newCard.lastReview = reviewTime
    newCard.reps += 1

    // Elapsed days since the last review
    if card.status == .new {
      newCard.elapsedDays = 0
    } else if let lastReview = card.lastReview,
      reviewTime > lastReview
    {
      newCard.elapsedDays = (reviewTime.timeIntervalSince(lastReview) / 86_400).rounded()
    }

    switch newCard.status {
    case .new:
      newCard.difficulty = algorithm.initialDifficulty(reviewRating)
      newCard.stability = algorithm.initialStability(reviewRating)

      switch reviewRating {
      case .again:
        newCard.scheduledDays = 0
        newCard.due = reviewTime.advanced(by: 60)
        newCard.status = .learning

      case .hard:
        newCard.scheduledDays = 0
        newCard.due = reviewTime.advanced(by: 60 * 5)
        newCard.status = .learning

      case .good:
        newCard.scheduledDays = 0
        newCard.due = reviewTime.advanced(by: 60 * 10)
        newCard.status = .learning

      case .easy:
        let interval = algorithm.nextInterval(newCard.stability)
        newCard.scheduledDays = interval
        newCard.due = reviewTime.advanced(by: interval * 86_400)
        newCard.status = .review
      }

    case .learning, .relearning:
      let status = card.status
      let difficulty = card.difficulty
      let stability = card.stability

      newCard.difficulty = algorithm.nextDifficulty(difficulty, rating: reviewRating)
      newCard.stability = algorithm.shortTermNextStability(stability, rating: reviewRating)

      switch reviewRating {
      case .again:
        newCard.scheduledDays = 0
        newCard.due = reviewTime.advanced(by: 60 * 5)
        newCard.status = status

      case .hard:
        newCard.scheduledDays = 0
        newCard.due = reviewTime.advanced(by: 60 * 10)
        newCard.status = status

      case .good:
        let interval = algorithm.nextInterval(newCard.stability)
        newCard.scheduledDays = interval
        newCard.due = reviewTime.advanced(by: interval * 86_400)
        newCard.status = .review

      case .easy:
        let goodStability = algorithm.shortTermNextStability(stability, rating: .good)
        let goodInterval = algorithm.nextInterval(goodStability)

        let easyInterval = max(
          goodInterval + 1,
          algorithm.nextInterval(newCard.stability)
        )

        newCard.scheduledDays = easyInterval
        newCard.due = reviewTime.advanced(by: easyInterval * 86_400)
        newCard.status = .review
      }

    case .review:
      let elapsedDays = newCard.elapsedDays
      let difficulty = card.difficulty
      let stability = card.stability

      let retrievability = algorithm.forgettingCurve(
        elapsedDays: elapsedDays,
        stability: stability
      )

      newCard.difficulty = algorithm.nextDifficulty(difficulty, rating: reviewRating)

      // Stability
      let hardStability = algorithm.nextRecallStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability,
        rating: .hard
      )

      let goodStability = algorithm.nextRecallStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability,
        rating: .good
      )

      let easyStability = algorithm.nextRecallStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability,
        rating: .easy
      )

      var hardInterval = algorithm.nextInterval(hardStability)
      var goodInterval = algorithm.nextInterval(goodStability)

      hardInterval = min(hardInterval, goodInterval)
      goodInterval = max(hardInterval + 1, goodInterval)

      let easyInterval = max(
        goodInterval + 1,
        algorithm.nextInterval(easyStability)
      )

      switch reviewRating {
      case .again:
        newCard.stability = algorithm.nextForgetStability(
          difficulty: difficulty,
          stability: stability,
          retrievability: retrievability
        )

        newCard.scheduledDays = 0
        newCard.status = .relearning
        newCard.due = reviewTime.advanced(by: 60 * 5)
        newCard.lapses += 1

      case .hard:
        newCard.scheduledDays = hardInterval
        newCard.stability = hardStability
        newCard.status = .review
        newCard.due = reviewTime.advanced(by: hardInterval * 86_400)

      case .good:
        newCard.scheduledDays = goodInterval
        newCard.stability = goodStability
        newCard.status = .review
        newCard.due = reviewTime.advanced(by: goodInterval * 86_400)

      case .easy:
        newCard.scheduledDays = easyInterval
        newCard.stability = easyStability
        newCard.status = .review
        newCard.due = reviewTime.advanced(by: easyInterval * 86_400)
      }
    }

    return CardReview(postReviewCard: newCard, preReviewCard: card, rating: reviewRating)
  }
}
