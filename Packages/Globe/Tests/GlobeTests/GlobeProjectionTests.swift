import Foundation
import SkyCore
import Testing

@testable import Globe

@Suite("Globe projection")
struct GlobeProjectionTests {
    private let size = CGSize(width: 400, height: 600)

    @Test("The point facing the camera lands in the middle")
    func centrePoint() {
        let camera = GlobeCamera(longitude: 0, latitude: 0)
        let point = GlobeProjection.screenPoint(for: Coordinate(latitude: 0, longitude: 0),
                                                camera: camera, size: size)
        #expect(point != nil)
        #expect(abs(point!.x - size.width / 2) < 0.001)
        #expect(abs(point!.y - size.height / 2) < 0.001)
    }

    @Test("The far side of the globe is not drawn")
    func backFaceIsHidden() {
        let camera = GlobeCamera(longitude: 0, latitude: 0)
        #expect(GlobeProjection.screenPoint(for: Coordinate(latitude: 0, longitude: 180),
                                            camera: camera, size: size) == nil)
        #expect(GlobeProjection.visibility(for: Coordinate(latitude: 0, longitude: 180),
                                           camera: camera) == 0)
    }

    @Test("Turning the globe brings the other side into view")
    func rotationRevealsTheOtherSide() {
        let antimeridian = Coordinate(latitude: 0, longitude: 180)
        #expect(GlobeProjection.screenPoint(for: antimeridian,
                                            camera: GlobeCamera(longitude: 0), size: size) == nil)
        #expect(GlobeProjection.screenPoint(for: antimeridian,
                                            camera: GlobeCamera(longitude: 180), size: size) != nil)
    }

    @Test("North is up")
    func northIsUp() {
        let camera = GlobeCamera()
        let equator = GlobeProjection.screenPoint(for: Coordinate(latitude: 0, longitude: 0),
                                                  camera: camera, size: size)!
        let north = GlobeProjection.screenPoint(for: Coordinate(latitude: 45, longitude: 0),
                                                camera: camera, size: size)!
        #expect(north.y < equator.y)
    }

    @Test("A marker fades as it turns towards the edge")
    func visibilityFadesAtTheEdge() {
        let camera = GlobeCamera()
        let centre = GlobeProjection.visibility(for: Coordinate(latitude: 0, longitude: 0), camera: camera)
        let edge = GlobeProjection.visibility(for: Coordinate(latitude: 0, longitude: 80), camera: camera)

        #expect(centre == 1)
        #expect(edge > 0 && edge < 1, "got \(edge)")
    }

    @Test("Every marker stays inside the frame")
    func markersStayOnScreen() {
        for longitude in stride(from: 0.0, to: 360.0, by: 15.0) {
            let camera = GlobeCamera(longitude: longitude)
            for person in PersonFixtures.all {
                guard let point = GlobeProjection.screenPoint(for: person.place.coordinate,
                                                              camera: camera, size: size) else { continue }
                #expect(point.x >= 0 && point.x <= size.width, "\(person.place.city)")
                #expect(point.y >= 0 && point.y <= size.height, "\(person.place.city)")
            }
        }
    }

    @Test("An arc follows the sphere and reaches both ends")
    func arcSpansTheGlobe() {
        let camera = GlobeCamera(longitude: 20)
        let points = GlobeProjection.arc(from: PersonFixtures.you.place.coordinate,
                                         to: PersonFixtures.ava.place.coordinate,
                                         camera: camera, size: size)
        #expect(points.count == GlobeProjection.Layout.arcSteps + 1)

        let visible = points.compactMap { $0 }
        #expect(visible.count > 2, "London to New York should be mostly in view")
    }
}
