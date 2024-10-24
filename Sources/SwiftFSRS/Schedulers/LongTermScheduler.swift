import Foundation

public struct LongTermScheduler: Scheduler {
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
      newCard.elapsedDays = reviewTime.timeIntervalSince(lastReview) / 86_400
    }

    switch newCard.status {
    case .new:
      newCard.difficulty = algorithm.initialDifficulty(reviewRating)
      newCard.stability = algorithm.initialStability(reviewRating)
      let firstStability = algorithm.initialStability(reviewRating)

      let againStability = algorithm.shortTermNextStability(
        firstStability,
        rating: .again
      )

      let hardStability = algorithm.shortTermNextStability(
        firstStability,
        rating: .hard
      )

      let goodStability = algorithm.shortTermNextStability(
        firstStability,
        rating: .good
      )

      let easyStability = algorithm.shortTermNextStability(
        firstStability,
        rating: .easy
      )

      var againInterval = algorithm.nextInterval(againStability)
      var hardInterval = algorithm.nextInterval(hardStability)
      var goodInterval = algorithm.nextInterval(goodStability)
      var easyInterval = algorithm.nextInterval(easyStability)

      againInterval = min(againInterval, hardInterval)
      hardInterval = max(hardInterval, againInterval + 1)
      goodInterval = max(goodInterval, hardInterval + 1)
      easyInterval = max(easyInterval, goodInterval + 1)

      switch reviewRating {
      case .again:
        newCard.scheduledDays = againInterval
        newCard.due = reviewTime.advanced(by: againInterval * 86_400)
        newCard.status = .review

      case .hard:
        newCard.scheduledDays = hardInterval
        newCard.due = reviewTime.advanced(by: hardInterval * 86_400)
        newCard.status = .review

      case .good:
        newCard.scheduledDays = goodInterval
        newCard.due = reviewTime.advanced(by: goodInterval * 86_400)
        newCard.status = .review

      case .easy:
        newCard.scheduledDays = easyInterval
        newCard.due = reviewTime.advanced(by: easyInterval * 86_400)
        newCard.status = .review
      }

    case .learning, .relearning, .review:
      let elapsedDays = newCard.elapsedDays
      let difficulty = newCard.difficulty
      let stability = newCard.stability

      newCard.difficulty = algorithm.nextDifficulty(difficulty, rating: reviewRating)

      let retrievability = algorithm.forgettingCurve(
        elapsedDays: elapsedDays,
        stability: stability
      )

      newCard.stability = algorithm.nextForgetStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability
      )

      let againStability = algorithm.nextForgetStability(
        difficulty: difficulty,
        stability: stability,
        retrievability: retrievability
      )

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

      var againInterval = algorithm.nextInterval(againStability)
      var hardInterval = algorithm.nextInterval(hardStability)
      var goodInterval = algorithm.nextInterval(goodStability)
      var easyInterval = algorithm.nextInterval(easyStability)

      againInterval = min(againInterval, hardInterval)
      hardInterval = max(hardInterval, againInterval + 1)
      goodInterval = max(goodInterval, hardInterval + 1)
      easyInterval = max(easyInterval, goodInterval + 1)

      switch reviewRating {
      case .again:
        newCard.scheduledDays = againInterval
        newCard.due = reviewTime.advanced(by: againInterval * 86_400)
        newCard.stability = againStability
        newCard.lapses += 1
        newCard.status = .review

      case .hard:
        newCard.scheduledDays = hardInterval
        newCard.due = reviewTime.advanced(by: hardInterval * 86_400)
        newCard.stability = hardStability
        newCard.status = .review

      case .good:
        newCard.scheduledDays = goodInterval
        newCard.due = reviewTime.advanced(by: goodInterval * 86_400)
        newCard.stability = goodStability
        newCard.status = .review

      case .easy:
        newCard.scheduledDays = easyInterval
        newCard.due = reviewTime.advanced(by: easyInterval * 86_400)
        newCard.stability = easyStability
        newCard.status = .review
      }
    }

    return CardReview(postReviewCard: newCard, preReviewCard: card, rating: reviewRating)
  }
}
