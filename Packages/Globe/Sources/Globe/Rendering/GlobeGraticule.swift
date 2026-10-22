import SkyCore
import SkyUI
import SwiftUI
import simd

/// The faint grid of latitude and longitude lines.
///
/// Mostly invisible, and the globe reads as flat without it: the lines are what
/// tell the eye the dots are on a sphere rather than scattered on a disc.
struct GlobeGraticule {
    let frame: GlobeFrame
    let style: GlobeStyle

    func draw(in context: inout GraphicsContext) {
        var path = Path()
        for line in Self.lines {
            add(line, to: &path)
        }
        context.stroke(
            path,
            with: .color(style.graticule.color.opacity(Layout.opacity)),
            lineWidth: Layout.width
        )
    }

    /// Adds one line, lifting the pen wherever it passes behind the globe.
    private func add(_ line: [SIMD3<Float>], to path: inout Path) {
        var isDrawing = false
        for point in line {
            let (position, facing) = frame.project(point)
            guard facing > 0 else {
                isDrawing = false
                continue
            }
            if isDrawing {
                path.addLine(to: position)
            } else {
                path.move(to: position)
                isDrawing = true
            }
        }
    }

    /// Parallels every 30° and meridians every 30°, as points on the sphere.
    static let lines: [[SIMD3<Float>]] = {
        var lines: [[SIMD3<Float>]] = []
        for latitude in stride(from: -60.0, through: 60.0, by: 30.0) {
            lines.append(stride(from: -180.0, through: 180.0, by: 5.0).map {
                GlobeGeometry.vector(for: Coordinate(latitude: latitude, longitude: $0))
            })
        }
        for longitude in stride(from: -180.0, to: 180.0, by: 30.0) {
            lines.append(stride(from: -90.0, through: 90.0, by: 5.0).map {
                GlobeGeometry.vector(for: Coordinate(latitude: $0, longitude: longitude))
            })
        }
        return lines
    }()
}

extension GlobeGraticule {
    private enum Layout {
        static let opacity = 0.09
        static let width: Double = 0.8
    }
}
