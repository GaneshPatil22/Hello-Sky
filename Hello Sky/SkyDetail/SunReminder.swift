import Foundation
import SkyCore
import UserNotifications

/// Reminding someone when the sun is about to rise or set somewhere.
///
/// Worked out on the phone and scheduled as a local notification, so this needs
/// no server and no paid account — which is why it can exist before Phase 7.
enum SunReminder {
    enum Outcome: Equatable {
        case scheduled(SolarEvent.Kind, Date)
        case noEvent
        case refused
        case failed
    }

    /// Schedules the next sun event at a person's place.
    static func schedule(for person: Person, from date: Date = .now) async -> Outcome {
        guard let event = Sun.solarDay(around: date, at: person.place.coordinate).next else {
            return .noEvent
        }
        let centre = UNUserNotificationCenter.current()
        guard (try? await centre.requestAuthorization(options: [.alert, .sound])) == true else {
            return .refused
        }

        let content = UNMutableNotificationContent()
        content.title = title(for: event.kind, person: person)
        content.body = body(for: event.kind, person: person)
        content.sound = .default

        // A calendar trigger rather than an interval, so the reminder survives
        // the phone being asleep and still lands at the right moment.
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute], from: event.date
        )
        let request = UNNotificationRequest(
            identifier: identifier(for: person, event: event),
            content: content,
            trigger: UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        )

        do {
            try await centre.add(request)
            return .scheduled(event.kind, event.date)
        } catch {
            return .failed
        }
    }

    static func title(for kind: SolarEvent.Kind, person: Person) -> String {
        kind == .sunrise ? "Sunrise at \(person.name)'s" : "Sunset at \(person.name)'s"
    }

    static func body(for kind: SolarEvent.Kind, person: Person) -> String {
        let moment = kind == .sunrise ? "The sun is coming up" : "The sun is going down"
        return "\(moment) in \(person.place.city)."
    }

    /// One pending reminder per person and event, so tapping twice replaces
    /// rather than stacks.
    static func identifier(for person: Person, event: SolarEvent) -> String {
        "sun-\(person.id)-\(event.kind.rawValue)"
    }
}
