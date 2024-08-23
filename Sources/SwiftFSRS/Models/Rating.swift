import Foundation

public enum Rating: String, Codable, Hashable, Sendable {
  case again, hard, good, easy

  public var value: Int {
    switch self {
    case .again: 1
    case .hard: 2
    case .good: 3
    case .easy: 4
    }
  }
}
