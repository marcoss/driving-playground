import Foundation

// MARK: Customizable behavior instance vars
public enum BehaviorWeight: NSNumber {
    case critical = 100.0
    case high = 75.0
    case normal = 50.0
    case low = 25.0
}

// Scene sounds
public enum SoundType: String {
    case police = "sound_police"
    case carAdded = "sound_carstart"
    case obstacleAdded = "sound_obstacle"
    case obstacleHit = "sound_obstaclehit"
}

// Types of cars
public enum CarType {
    case normal
    case police
}
