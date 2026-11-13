import Synchronization
import Testing
@testable import shelved_ios

/// Port of Android `OrderedWriteQueueTest`.
struct OrderedWriteQueueTests {
    @Test func writesFinishInTheSameOrderTheyWereEnqueued() async {
        let log = EventLog()
        let queue = OrderedWriteQueue<Int>(
            writer: { value in
                await log.append("start\(value)")
                // The first write is slowest; it must still finish before the second starts.
                try await Task.sleep(for: .milliseconds(value == 1 ? 50 : 1))
                await log.append("end\(value)")
            },
            onError: { Issue.record($0) }
        )

        queue.enqueue(1)
        queue.enqueue(2)
        queue.enqueue(3)
        await queue.drain()

        #expect(await log.events == ["start1", "end1", "start2", "end2", "start3", "end3"])
    }

    @Test func failedWriteDoesNotStopLaterWrites() async {
        let completed = EventLog()
        let errors = ErrorRecorder()
        let queue = OrderedWriteQueue<Int>(
            writer: { value in
                if value == 1 { throw WriteFailure() }
                await completed.append("\(value)")
            },
            onError: { errors.record($0) }
        )

        queue.enqueue(1)
        queue.enqueue(2)
        await queue.drain()

        #expect(await completed.events == ["2"])
        #expect(errors.count == 1)
    }
}

private struct WriteFailure: Error {}

/// `onError` is synchronous, so errors are recorded behind a lock instead of an actor.
private final class ErrorRecorder: Sendable {
    private let errors = Mutex<[any Error]>([])

    var count: Int { errors.withLock { $0.count } }

    func record(_ error: any Error) {
        errors.withLock { $0.append(error) }
    }
}

private actor EventLog {
    private(set) var events: [String] = []

    func append(_ event: String) {
        events.append(event)
    }
}
