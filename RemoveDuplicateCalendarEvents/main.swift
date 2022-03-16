import EventKit
import Foundation

/// The combined identifiers for a unique event in a given calendar.
struct UniqueEventIdentifier: Hashable {
	let calendarIdentifier: String
	let eventExternalIdentifier: String
	
	init(event: EKEvent) {
		calendarIdentifier = event.calendar.calendarIdentifier
		eventExternalIdentifier = event.calendarItemExternalIdentifier
	}
}

let shouldRemove = CommandLine.arguments.contains("--remove")
print(shouldRemove ? "Removing duplicate calendar events." : "Showing duplicate calendar events. To remove, run with '--remove'.")

// Request permission.
let store = EKEventStore()
var storeAccessGranted = false
let dispatchGroup = DispatchGroup()
dispatchGroup.enter()
store.requestAccess(to: .event) { granted, error in storeAccessGranted = granted; dispatchGroup.leave() }
dispatchGroup.wait()
guard storeAccessGranted else { print("Permission denied."); exit(1) }

// Get events. Queries one year at a time because EventKit limits the date range.
var events = [EKEvent]()
let now = Date()
for years in -30 ..< 10 { // Looks back 30 years and ahead 10 years.
	var yearComponent = DateComponents()
	yearComponent.year = years - 1
	let start = Calendar.current.date(byAdding: yearComponent, to: now)!
	yearComponent.year = years
	let end = Calendar.current.date(byAdding: yearComponent, to: now)!
	events.append(contentsOf: store.events(matching: store.predicateForEvents(withStart: start, end: end, calendars: nil)))
}
events.sort { e1, e2 in e1.startDate! < e2.startDate }

// Remove duplicates.
do {
	var uniqueEventIdentifiers = Set<UniqueEventIdentifier>()
	for event in events {
		if event.calendar.allowsContentModifications, !event.hasRecurrenceRules, !uniqueEventIdentifiers.insert(.init(event: event)).inserted {
			print(event.startDate!, event.title!)
			if shouldRemove { try store.remove(event, span: .futureEvents, commit: false) }
		}
	}
	if shouldRemove { try store.commit() }
} catch {
	print(error)
	exit(2)
}
print("Done.")
