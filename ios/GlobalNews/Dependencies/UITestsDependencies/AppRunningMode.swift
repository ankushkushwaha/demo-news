#if DEBUG

enum AppRunningMode {
    case normal
    case uiTestSuccess
    case uiTestError
    case uiTestEmpty

    static func current(from arguments: [String]) -> AppRunningMode {
        if arguments.contains("UITestSimulateSuccess") {
            return .uiTestSuccess
        } else if arguments.contains("UITestSimulateError") {
            return .uiTestError
        } else if arguments.contains("UITestSimulateEmpty") {
            return .uiTestEmpty
        }
        return .normal
    }
}

#endif
