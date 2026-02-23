import SwiftUI
import Foundation
import Combine
// MARK: - Model

struct NewsItem: Identifiable {
    let id = UUID()
    let title: String
    let source: String
    let pubDate: String
    let link: String
    let description: String
}

struct NewsRowView: View {
    let item: NewsItem
    @State private var pressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(item.title)
                .font(.custom("Georgia", size: 16))
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            if !item.description.isEmpty {
                Text(item.description)
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }

            HStack(spacing: 6) {
                Image(systemName: "newspaper.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.orange)
                Text(item.source)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.orange)
                Spacer()
                Text(item.pubDate)
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 3)
        )
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.25), value: pressed)
        .onTapGesture {
            if let url = URL(string: item.link) {
//                UIApplication.shared.open(url)
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var vm = NewsViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                switch vm.currentState {
                case .idle(let location):
                    if let location {
                        HStack {
                            Spacer()
                            Image(systemName: "location")
                                .font(.system(size: 14))
                            Text(location)
                                .font(.system(size: 14))
                        }
                        .padding(.horizontal)
                    } else {
                        EmptyView()
                    }
                case .loading:
                    LoadingView()
                case .error(let message):
                    ErrorView(message: message) {

                    }
                }
                    List {
                        ForEach(vm.items) { item in
                            NewsRowView(item: item)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    }
                    .listStyle(.plain)
                }
            .background(
                Color(.systemGroupedBackground)
                .ignoresSafeArea()
                        )
            
        }
        .onAppear {
            print("Content vie appeared")
        }
    }
}


struct Shimmer: ViewModifier {
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [.clear, .white.opacity(0.85), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .rotationEffect(.degrees(20))
                .offset(x: phase * 400)
                .blendMode(.overlay)
                .onAppear {
                    withAnimation(.linear(duration: 1.4).repeatForever(autoreverses: false)) {
                        phase = 1
                    }
                }
            )
            .clipped()
    }
}

extension View {
    func shimmer() -> some View { modifier(Shimmer()) }
}

struct SkeletonCardView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            RoundedRectangle(cornerRadius: 5).fill(Color(.systemGray))
                .frame(maxWidth: .infinity).frame(height: 14)
            RoundedRectangle(cornerRadius: 5).fill(Color(.systemGray5))
                .frame(maxWidth: 260).frame(height: 14)
            RoundedRectangle(cornerRadius: 5).fill(Color(.systemGray5))
                .frame(maxWidth: 180).frame(height: 14)

            Spacer().frame(height: 2)

            RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray6))
                .frame(maxWidth: .infinity).frame(height: 11)
            RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray6))
                .frame(maxWidth: 220).frame(height: 11)

            Spacer().frame(height: 2)

            HStack {
                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5))
                    .frame(width: 80, height: 10)
                Spacer()
                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5))
                    .frame(width: 50, height: 10)
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        )
        .shimmer()
    }
}

// MARK: - Loading View

struct LoadingView: View {
    @State private var iconScale: CGFloat = 0.85
    @State private var appeared = false
    @State private var dotsCount = 1
    private let dotTimer = Timer.publish(every: 0.45, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 0) {

            VStack(spacing: 14) {
                

                HStack(alignment: .bottom, spacing: 2) {
                    Text("Fetching latest news")
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.secondary)
                    Text(String(repeating: ".", count: dotsCount))
                        .font(.custom("Georgia", size: 16))
                        .foregroundColor(.secondary)
                        .frame(width: 22, alignment: .leading)
                        .animation(.none, value: dotsCount)
                }
                .opacity(appeared ? 1 : 0)
                .animation(.easeIn(duration: 0.4), value: appeared)
            }
            .padding(.bottom, 30)

            // Staggered skeleton cards
            VStack(spacing: 12) {
                ForEach(0..<4, id: \.self) { i in
                    SkeletonCardView()
                        .padding(.horizontal, 16)
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 22)
                        .animation(
                            .spring(response: 0.5, dampingFraction: 0.72)
                                .delay(Double(i) * 0.09 + 0.15),
                            value: appeared
                        )
                }
            }
        }
        .onAppear {
            iconScale = 1.12
            appeared = true
        }
        .onReceive(dotTimer) { _ in
            dotsCount = (dotsCount % 3) + 1
        }
    }
}

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 52))
                .foregroundColor(.secondary)
            Text("Couldn't load news")
                .font(.custom("Georgia", size: 20))
                .fontWeight(.semibold)
            Text(message)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            Button(action: retry) {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(.system(size: 15, weight: .semibold))
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
        }
    }
}

// MARK: - App Entry Point

@main
struct IndiaNewsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
