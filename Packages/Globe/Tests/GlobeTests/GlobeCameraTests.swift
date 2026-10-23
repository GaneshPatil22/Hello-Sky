import Foundation
import SkyCore
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

@Suite("Globe camera focus")
struct GlobeCameraFocusTests {
    @Test("Focusing on a place brings it to the centre of the screen")
    func focusCentresThePlace() {
        let size = CGSize(width: 400, height: 600)
        for person in PersonFixtures.all {
            let camera = GlobeCamera.focused(on: person.place.coordinate)
            guard let point = GlobeProjection.screenPoint(for: person.place.coordinate,
                                                          camera: camera, size: size) else {
                Issue.record("\(person.place.city) was not visible after focusing on it")
                continue
            }
            #expect(abs(point.x - size.width / 2) < 0.5, "\(person.place.city) x")
            #expect(abs(point.y - size.height / 2) < 0.5, "\(person.place.city) y")
        }
    }

    @Test("Interpolation starts where it is and ends where it was told")
    func interpolationHitsBothEnds() {
        let start = GlobeCamera(longitude: 10, latitude: -20)
        let target = GlobeCamera.focused(on: PersonFixtures.kenji.place.coordinate)

        let atStart = start.interpolated(towards: target, progress: 0)
        #expect(abs(atStart.longitude - start.longitude) < 0.001)
        #expect(abs(atStart.latitude - start.latitude) < 0.001)

        let atEnd = start.interpolated(towards: target, progress: 1)
        #expect(abs(atEnd.longitude - target.longitude) < 0.001)
        #expect(abs(atEnd.latitude - target.latitude) < 0.001)
    }

    @Test("Longitude takes the short way round the globe")
    func takesTheShortWay() {
        let start = GlobeCamera(longitude: 350)
        let target = GlobeCamera(longitude: 10)
        let halfway = start.interpolated(towards: target, progress: 0.5)

        // The short way passes through 0, not through 180.
        #expect(halfway.longitude > 355 || halfway.longitude < 5, "went the long way to \(halfway.longitude)")
    }

    @Test("Progress outside zero and one is clamped")
    func progressIsClamped() {
        let start = GlobeCamera(longitude: 0)
        let target = GlobeCamera(longitude: 90)
        #expect(start.interpolated(towards: target, progress: -1) == start.interpolated(towards: target, progress: 0))
        #expect(start.interpolated(towards: target, progress: 2) == start.interpolated(towards: target, progress: 1))
    }

    @Test("The move eases rather than running at a constant rate")
    func movementEases() {
        let start = GlobeCamera(longitude: 0)
        let target = GlobeCamera(longitude: 100)

        let early = start.interpolated(towards: target, progress: 0.1).longitude
        let middle = start.interpolated(towards: target, progress: 0.5).longitude
        let late = start.interpolated(towards: target, progress: 0.9).longitude

        #expect(early < 10, "should start slowly, got \(early)")
        #expect(abs(middle - 50) < 0.001, "should be halfway at halfway")
        #expect(late > 90, "should finish slowly, got \(late)")
    }

    @Test("Focusing cancels any carried spin")
    func focusStopsTheSpin() {
        var start = GlobeCamera()
        start.release(velocity: 200)
        #expect(start.interpolated(towards: .focused(on: PersonFixtures.you.place.coordinate),
                                   progress: 0.5).isCoasting == false)
    }
}

@Suite("Globe camera projection")
struct GlobeCameraProjectionTests {
    @Test("No time passing leaves the camera alone")
    func zeroIsIdentity() {
        var camera = GlobeCamera(longitude: 42, latitude: 10)
        camera.release(velocity: 90)
        #expect(camera.projected(after: 0) == camera)
        #expect(camera.projected(after: -5) == camera)
    }

    @Test("Projecting forward matches stepping there frame by frame")
    func matchesSteppingInSmallIncrements() {
        var stepped = GlobeCamera(longitude: 0)
        stepped.release(velocity: 150)
        let projected = stepped.projected(after: 2)

        for _ in 0..<480 {
            stepped.advance(by: 2.0 / 480)
        }
        // Closed form and fine stepping should agree to well under a degree.
        #expect(abs(stepped.longitude - projected.longitude) < 0.5,
                "stepped to \(stepped.longitude), projected \(projected.longitude)")
    }

    @Test("Projecting in one jump matches two shorter jumps")
    func composesOverTime() {
        var camera = GlobeCamera(longitude: 20)
        camera.release(velocity: 200)

        let once = camera.projected(after: 3)
        let twice = camera.projected(after: 1).projected(after: 2)
        #expect(abs(once.longitude - twice.longitude) < 0.001)
        #expect(abs(once.spin - twice.spin) < 0.001)
    }

    @Test("A camera at rest still drifts")
    func restingCameraDrifts() {
        let camera = GlobeCamera(longitude: 0)
        #expect(abs(camera.projected(after: 10).longitude - GlobeCamera.Motion.idleDrift * 10) < 0.001)
    }
}
