import Foundation

public struct FSRSAlgorithm: Codable, Hashable, Sendable {
  public enum Version: String, Codable, Hashable, Sendable {
    case v5

    public var implementation: FSRSAlgorithm {
      switch self {
      case .v5: FSRSAlgorithm.v5
      }
    }
  }

  public var decay: Double
  public var factor: Double
  public var requestRetention: Double
  public var maximumInterval: Double
  public var parameters: [Double]

  public init(
    decay: Double = 0.0,
    factor: Double = 0.0,
    requestRetention: Double = 0.0,
    maximumInterval: Double = 0.0,
    parameters: [Double] = []
  ) {
    self.decay = decay
    self.factor = factor
    self.requestRetention = min(max(requestRetention, 0.0), 1.0)
    self.maximumInterval = maximumInterval
    self.parameters = parameters
  }

  public static let v5 = Self(
    decay: -0.5,
    factor: 19 / 81,
    requestRetention: 0.9,
    maximumInterval: 36500,
    parameters: v5Params
  )

  func initialStability(_ rating: Rating) -> Double {
    max(self[rating.value - 1], 0.1)
  }

  func initialDifficulty(_ rating: Rating) -> Double {
    clampDifficulty(
      self[4] - exp(Double((rating.value - 1)) * self[5]) + 1
    )
    .roundedUp()
  }

  func nextInterval(_ stability: Double) -> Double {
    clampInterval(
      (stability / factor) * (pow(requestRetention, 1.0 / decay) - 1.0),
      maximum: maximumInterval
    )
    .roundedUp()
  }

  func meanReversion(_ initial: Double, current: Double) -> Double {
    self[7] * initial + (1 - self[7]) * current
  }

  func nextDifficulty(_ difficulty: Double, rating: Rating) -> Double {
    let nextDifficulty = difficulty - self[6] * Double(rating.value - 3)

    return clampDifficulty(
      meanReversion(
        initialDifficulty(.easy),
        current: nextDifficulty
      )
    )
    .roundedUp()
  }

  func shortTermNextStability(_ stability: Double, rating: Rating) -> Double {
    (stability * exp(self[17] * (Double(rating.value) - 3 + self[18])))
      .roundedUp()
  }

  func forgettingCurve(
    elapsedDays: Double,
    stability: Double
  ) -> Double {
    guard
      !stability.isZero
    else { return 0 }

    return pow(
      1.0 + factor * elapsedDays / stability,
      decay
    )
    .roundedUp()
  }

  func nextForgetStability(
    difficulty: Double,
    stability: Double,
    retrievability: Double
  ) -> Double {
    (self[11] * pow(difficulty, -self[12]) * (pow(stability + 1.0, self[13]) - 1)
      * exp((1 - retrievability) * self[14]))
      .roundedUp()
  }

  func nextRecallStability(
    difficulty: Double,
    stability: Double,
    retrievability: Double,
    rating: Rating
  ) -> Double {
    let hardPenalty = rating == .hard ? self[15] : 1
    let easyBonus = rating == .easy ? self[16] : 1
    let a = exp(self[8]) * (11 - difficulty) * pow(stability, -self[9])
    let b = exp((1 - retrievability) * self[10]) - 1

    return (stability * (1 + a * b * hardPenalty * easyBonus))
      .roundedUp()
  }
}

extension FSRSAlgorithm {
  public subscript(index: Int) -> Double {
    get {
      parameters[index]
    }
    set {
      parameters[index] = newValue
    }
  }
}

extension Double {
  func roundedUp(toPlaces places: Int = 8) -> Double {
    let precision = pow(10.0, Double(places))
    return (self * precision).rounded() / precision
  }
}
