import SwiftUI
import Additions

struct OnboardingScreen: View {

    @Inject var onboardingTask: OnboardingTask

    var body: some View {
        VStack {
            Text("Hello, This is the onboarding!")

            Button(action: {
                onboardingTask.finish()
            }, label: {
                Text("Got it!")
            })
        }
    }
}
