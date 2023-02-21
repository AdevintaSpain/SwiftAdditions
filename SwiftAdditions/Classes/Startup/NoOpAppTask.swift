import Foundation

///
/// This task represents an async action that can be queued also, like `AppTask`.
///
/// If there's nothing to do, don't override `main`. Otherwise inherit directly from `AppTask`.
open class NoOpAppTask: AppTask {
    open override func main() {
        super.main()
        setFinished()
    }
}
