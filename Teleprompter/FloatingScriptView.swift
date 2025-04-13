import SwiftData
import SwiftUI

struct FloatingScriptView: View {
    @Bindable var script: Script
    @Binding var isVisible: Bool
    @State private var isPlaying = false
    @State private var scrollPosition = ScrollPosition(edge: .top)
    @State private var scrollTimer: Timer?
    @State private var position: CGPoint = CGPoint(
        x: UIScreen.main.bounds.width / 2,
        y: UIScreen.main.bounds.height / 2
    )
    @State private var size: CGSize = CGSize(width: 300, height: 200)
    @State private var isLocked = false
    @State private var lastDragPosition: CGPoint?

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text(script.title ?? "")
                        .font(.headline)
                        .lineLimit(1)

                    Spacer()

                    Button(action: { isLocked.toggle() }) {
                        Image(
                            systemName: isLocked
                                ? "lock.fill" : "lock.open.fill"
                        )
                    }

                    Button(action: {
                        isVisible = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))

                ScrollView {
                    Text(script.content ?? "")
                        .font(.system(size: CGFloat(script.fontSize)))
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .scrollPosition(
                    $scrollPosition
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if isPlaying {
                                stopScrolling()
                            }
                        }
                        .onEnded { _ in
                            if isPlaying {
                                startScrolling()
                            }
                        }
                )

                HStack {
                    Button(action: { resetScroll() }) {
                        Image(systemName: "arrow.counterclockwise")
                    }

                    Button(action: { scrollBackward() }) {
                        Image(systemName: "backward.fill")
                    }

                    Button(action: { togglePlayback() }) {
                        Image(
                            systemName: isPlaying ? "pause.fill" : "play.fill"
                        )
                    }

                    Button(action: { scrollForward() }) {
                        Image(systemName: "forward.fill")
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.2))
            }
            .frame(width: size.width, height: size.height)
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
            .position(position)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if !isLocked {
                            if let lastPosition = lastDragPosition {
                                let translation = CGPoint(
                                    x: value.location.x - lastPosition.x,
                                    y: value.location.y - lastPosition.y
                                )
                                position = CGPoint(
                                    x: position.x + translation.x,
                                    y: position.y + translation.y
                                )
                            }
                            lastDragPosition = value.location
                        }
                    }
                    .onEnded { _ in
                        lastDragPosition = nil
                    }
            )
            .gesture(
                MagnificationGesture()
                    .onChanged { scale in
                        if !isLocked {
                            size = CGSize(
                                width: min(
                                    max(200, size.width * scale),
                                    geometry.size.width - 40
                                ),
                                height: min(
                                    max(200, size.height * scale),
                                    geometry.size.height - 40
                                )
                            )
                        }
                    }
            )
        }
    }

    private func resetScroll() {
        withAnimation {
            scrollPosition.scrollTo(edge: .top)
        }
    }

    private func scrollBackward() {
        withAnimation {
            scrollPosition.scrollTo(
                x: 0,
                y: max(0, (scrollPosition.point?.y ?? 0) - 50)
            )
        }
    }

    private func togglePlayback() {
        isPlaying.toggle()
        if isPlaying {
            startScrolling()
        } else {
            stopScrolling()
        }
    }

    private func startScrolling() {
        let interval = 0.25 / CGFloat(script.scrollSpeed)
        scrollTimer =
            Timer
            .scheduledTimer(withTimeInterval: interval, repeats: true) { _ in
                withAnimation(.linear(duration: 0.1)) {
                    scrollPosition.scrollTo(
                        x: 0,
                        y: (scrollPosition.point?.y ?? 0) + 1
                    )
                }
            }
    }

    private func stopScrolling() {
        scrollTimer?.invalidate()
        scrollTimer = nil
    }

    private func scrollForward() {
        withAnimation {
            scrollPosition.scrollTo(
                x: 0,
                y: (scrollPosition.point?.y ?? 0) + 50
            )
        }
    }
}
