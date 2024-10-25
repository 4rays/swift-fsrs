import Foundation

public enum Grade: Codable, Hashable, Sendable {
  case manual
  case rating(Rating)
}
