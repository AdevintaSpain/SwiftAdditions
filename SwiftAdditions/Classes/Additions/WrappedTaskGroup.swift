public struct WrappedTaskGroup {

    public static func run<U>(_ groupReady: (inout ThrowingTaskGroup<U, Error>) -> Void) async throws -> [U] {
        try await withThrowingTaskGroup(of: U.self) { group in
            groupReady(&group)
            var results = [U]()

            for try await value in group {
                results.append(value)
            }

            return results
        }
    }
}
