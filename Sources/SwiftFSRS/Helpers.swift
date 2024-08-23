import Foundation

func clampDifficulty(_ value: Double) -> Double {
  clamp(value, minimum: 1, maximum: 10)
}

func clampInterval(_ value: Double, maximum: Double) -> Double {
  clamp(round(value), minimum: 1, maximum: maximum)
}

func clamp(_ value: Double, minimum: Double, maximum: Double) -> Double {
  min(max(value, minimum), maximum)
}
