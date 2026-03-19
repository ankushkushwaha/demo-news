@testable import News

class TestTaskScheduler: TaskScheduler {
    /// If a previous task (task1) is still running when a new task (task2) starts,
    /// task1 might finish after task2 and overwrite the latest state.
    /// Waiting only for the latest task (task 2) in tests risks passing them while stale state persists
    /// Therefore, we wait for all tasks to ensure no old tasks can affect the final state.

    private(set) var tasks: [Task<Void, Never>] = []

    @discardableResult
     func schedule(
        _ work: @escaping @Sendable () async -> Void
    ) -> Task<Void, Never> {
        let task = Task<Void, Never> { await work() }

        tasks.append(task)

        return task
    }

    func waitForAllTasks() async {
        for task in tasks {
            await task.value
        }
    }
}
