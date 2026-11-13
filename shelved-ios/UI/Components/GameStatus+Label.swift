extension GameStatus {
    /// Display name used on pills, rows, and stats ("Backlog", "Playing", "Completed").
    var label: String {
        switch self {
        case .backlog: "Backlog"
        case .playing: "Playing"
        case .completed: "Completed"
        }
    }
}
