import GameplayKit

// Delay utility for adding objects to scene
public func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

// Helper for converting float2 -> CGPoint
extension CGPoint {
    init(_ point: float2) {
        x = CGFloat(point.x)
        y = CGFloat(point.y)
    }
}

// Helper for converting CGPoint -> float2
extension float2 {
    init(_ point: CGPoint) {
        self.init(x: Float(point.x), y: Float(point.y))
    }
}

// Pick random element in array
extension Array {
    func randomElement() -> Element {
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}

// Globals
public struct Globals {
    struct Contacts {
        static let normal: UInt32 = 0x1 << 0
        static let police: UInt32 = 0x1 << 1
        static let obstacle: UInt32 = 0x1 << 2
        static let wall: UInt32 = 0
    }
    
    static let trackPath:[float2] = [
        float2(0, 230),
        float2(240, 175),
        float2(300, 0),
        float2(240, -175),
        float2(0, -230),
        float2(-240, -175),
        float2(-300, 0),
        float2(-240, 175),
        float2(0, 230)
    ]

    /* Leftover from debugging
    static let pointsz:[float2] = [
        float2(0, 230),
        float2(240, 200),
        float2(300, 0),
        float2(240, -200),
        float2(0, -230),
        float2(-240, -200),
        float2(-300, 0),
        float2(-240, 200),
        float2(0, 230)
    ]

    static let oldpoints:[float2] = [
        float2(0, 230),
        float2(300, 0),
        float2(0, -230),
        float2(-300, 0),
        float2(0, 230)
    ]

    static let pointsZ:[float2] = [
        float2(-3.99999499320984, 235.0),
        float2(75.9999771118164, 233.0),
        float2(169.0, 216.0),
        float2(238.0, 180.0),
        float2(293.000030517578, 103.0),
        float2(314.000030517578, 19.0000019073486),
        float2(301.0, -86.0000152587891),
        float2(248.0, -171.000015258789),
        float2(162.000015258789, -215.0),
        float2(36.9999847412109, -232.0),
        float2(-80.0, -232.0),
        float2(-196.0, -196.0),
        float2(-266.000030517578, -130.0),
        float2(-306.000030517578, -26.0),
        float2(-298.000030517578, 70.0000076293945),
        float2(-246.000030517578, 150.0),
        float2(-158.000015258789, 207.0),
        float2(-70.0, 230.000015258789)
    ]
     */
}
