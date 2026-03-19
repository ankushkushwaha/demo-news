protocol TaskScheduler {
    @discardableResult
    func schedule(_ work: @escaping @Sendable () async -> Void) -> Task<Void, Never>
}

struct DefaultTaskScheduler: TaskScheduler {
    @discardableResult
    func schedule(_ work: @escaping @Sendable () async -> Void) -> Task<Void, Never> {
        Task { await work() }
    }
}
