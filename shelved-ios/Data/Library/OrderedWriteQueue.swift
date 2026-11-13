/// Runs writes one at a time, in the order they were enqueued, off the main actor.
/// A failed write is reported and does not stop later writes.
nonisolated final class OrderedWriteQueue<Value: Sendable>: Sendable {
    private let continuation: AsyncStream<Value>.Continuation
    private let worker: Task<Void, Never>

    init(
        writer: @escaping @Sendable (Value) async throws -> Void,
        onError: @escaping @Sendable (any Error) -> Void
    ) {
        let (stream, continuation) = AsyncStream.makeStream(of: Value.self)
        self.continuation = continuation
        worker = Task.detached {
            for await value in stream {
                do {
                    try await writer(value)
                } catch {
                    onError(error)
                }
            }
        }
    }

    deinit {
        continuation.finish()
    }

    func enqueue(_ value: Value) {
        continuation.yield(value)
    }

    /// Stops accepting writes and waits for the queued ones to finish.
    func drain() async {
        continuation.finish()
        await worker.value
    }
}
