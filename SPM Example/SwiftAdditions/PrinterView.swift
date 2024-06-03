import SwiftUI
import Additions
import Combine

struct PrinterView: View {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    @Inject private var dataSource: DataSource
    @State var text: String = ""

    var body: some View {
        Text(text)
            .onReceive(timer) { _ in
                guard let c = dataSource.next() else {
                    timer.upstream.connect().cancel()
                    return
                }
                text.append(c)
            }
    }
}

protocol DataSource: AnyObject {

    func next() -> Character?
}

class CharacterDataSource: DataSource {

    var characters = "Hello world!!!"

    func next() -> Character? {
        guard characters.count > 0 else {
            return nil
        }
        return characters.removeFirst()
    }
}

#Preview {
    PrinterView()
        .injecting {
            Register(DataSource.self, .unique) { CharacterDataSource() }
        }
}
