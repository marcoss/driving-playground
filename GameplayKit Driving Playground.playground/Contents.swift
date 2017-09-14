//#-hidden-code
import SpriteKit
import PlaygroundSupport
//#-end-hidden-code

/*:
 # Autonomous Driving Playground
 * Experiment:
 Add cars or police to the scene using the buttons on your timeline, watch as police attempt to catch speeders! Add obstacles on the track by tapping anywhere on the screen. Customize and tweak car driving behavior, including speed and aggressiveness below.
 */

let racetrack = Scene(fileNamed: "DrivingScene")!

/*:
 ![Red car](car_red.png)
 **Step 1:** Customize Car Behavior *(optional)*

 - Note: By default, cars will try to evade police capture. Change car behavior variables to determine their driving behavior:
 * **`carReachSpeed`:** The speed limit cars will reach
 * **`carStayOnRoad`:** Car's tendency to stay within road
 * **`carAvoidObstacles`:** Car's tendency to avoid obstacles on road
 * **`carAvoidPolice`:** Car's tendency to avoid police capture
 */
racetrack.carReachSpeed = /*#-editable-code*/90.0/*#-end-editable-code*/
racetrack.carStayOnRoad = /*#-editable-code*/.low/*#-end-editable-code*/
racetrack.carAvoidObstacles = /*#-editable-code*/.critical/*#-end-editable-code*/
racetrack.carAvoidPolice = /*#-editable-code*/.critical/*#-end-editable-code*/

/*:
 ![Red car](car_police.png)
 **Step 2:** Customize Police Behavior *(optional)*

 - Note: By default, police will try to capture cars on the road. Change police behavior variables to determine their driving behavior:
 * **`policeReachSpeed`:** The speed limit police will reach
 * **`policeStayOnRoad`:** Police's rule to stay within road
 * **`policeAvoidObstacles`:** Police's tendency to avoid obstacles on road
 * **`policeChaseCars`:** Police aggressiveness to capture cars
 */
racetrack.policeReachSpeed = /*#-editable-code*/80.0/*#-end-editable-code*/
racetrack.policeChaseCars = /*#-editable-code*/.critical/*#-end-editable-code*/
racetrack.policeStayOnRoad = /*#-editable-code*/.high/*#-end-editable-code*/
racetrack.policeAvoidObstacles = /*#-editable-code*/.high/*#-end-editable-code*/

//#-hidden-code
racetrack.scaleMode = .aspectFit

let sceneView = SKView(frame: CGRect(x: 0, y: 0, width: 850, height: 638))
sceneView.showsPhysics = false
sceneView.showsFields = false
sceneView.isUserInteractionEnabled = true
sceneView.presentScene(racetrack)

PlaygroundPage.current.liveView = sceneView
//#-end-hidden-code

/*:
 **Step 3:** Add Cars to Scene

 - Note: Add cars using these built-in functions or tap the buttons on your timeline.
 */

//#-editable-code Tap to enter code
racetrack.addCar(withDelay: 2.0)

/*:
 * Callout(Remember!):
 Add obstacles on your scene by tapping anywhere on the racetrack.
 */

racetrack.addPolice(withDelay: 6.0)
//#-end-editable-code
