import SwiftUI
import Additions

struct PrinterView: View {

    @ObservedObject var presenter = PrinterPresenter()

    var body: some View {
        Text(presenter.text)
    }
}

class PrinterPresenter: ObservableObject {
    @Inject var reader: ReaderProtocol
    @Published var text: String = ""

    init() {
        reader.start { (c) in
            self.text.append(c)
        }
    }
}

protocol ReaderProtocol {
    func start(update: @escaping (Character) -> Void)
}

class Reader: ReaderProtocol {
    var timer: Timer?

    var characters = "Hello world!!!"

    func start(update: @escaping (Character) -> Void ) {
        timer = Timer.scheduledTimer(
            withTimeInterval: 0.2,
            repeats: true, block: { (timer) in
                guard let first = self.characters.first else {
                    self.cancel()
                    return
                }
                self.characters.removeFirst()
                update(first)
            })
    }

    func cancel() {
        timer?.invalidate()
        timer = nil
    }
}
