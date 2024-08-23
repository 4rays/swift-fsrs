import Foundation

public enum Grade: Codable, Equatable {
  case manual
  case rating(Rating)
}
