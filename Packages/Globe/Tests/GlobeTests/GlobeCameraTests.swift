import Foundation
import Testing

@testable import Globe

@Suite("Globe camera")
struct GlobeCameraTests {
    @Test("Longitude wraps instead of growing without bound")
    func longitudeWraps() {
        var camera = GlobeCamera(longitude: 350)
        camera.drag(by: (longitude: 20, latitude: 0))
        #expect(abs(camera.longitude - 10) < 0.0001)

        camera.drag(by: (longitude: -30, latitude: 0))
        #expect(abs(camera.longitude - 340) < 0.0001)
    }

    @Test("Latitude stops short of the poles")
    func latitudeIsClamped() {
        var camera = GlobeCamera()
        camera.drag(by: (longitude: 0, latitude: 200))
        #expect(camera.latitude == GlobeCamera.Limits.latitude.upperBound)

        camera.drag(by: (longitude: 0, latitude: -400))
        #expect(camera.latitude == GlobeCamera.Limits.latitude.lowerBound)
    }

    @Test("Dragging stops whatever spin was carried")
    func draggingCancelsMomentum() {
        var camera = GlobeCamera()
        camera.release(velocity: 100)
        #expect(camera.isCoasting)

        camera.drag(by: (longitude: 1, latitude: 0))
        #expect(!camera.isCoasting)
    }

    @Test("Momentum decays to rest rather than running forever")
    func momentumDecays() {
        var camera = GlobeCamera()
        camera.release(velocity: 200)

        for _ in 0..<60 {
            camera.advance(by: 1.0 / 60)
        }
        #expect(camera.isCoasting, "a second in, it should still be moving")

        for _ in 0..<300 {
            camera.advance(by: 1.0 / 60)
        }
        #expect(!camera.isCoasting, "six seconds in, it should have settled")
    }

    @Test("A released flick is capped, so a fast swipe cannot spin it wildly")
    func velocityIsCapped() {
        var camera = GlobeCamera()
        camera.release(velocity: 10_000)
        #expect(camera.spin == GlobeCamera.Limits.spin.upperBound)
    }

    @Test("It drifts slowly when left alone")
    func idleDrift() {
        var camera = GlobeCamera()
        let start = camera.longitude
        camera.advance(by: 10)

        #expect(camera.longitude != start)
        #expect(abs(camera.longitude - start - GlobeCamera.Motion.idleDrift * 10) < 0.0001)
    }

    @Test("Time running backwards or standing still changes nothing")
    func ignoresNonPositiveTime() {
        var camera = GlobeCamera(longitude: 42)
        camera.release(velocity: 50)
        let before = camera

        camera.advance(by: 0)
        camera.advance(by: -1)
        #expect(camera == before)
    }
}
