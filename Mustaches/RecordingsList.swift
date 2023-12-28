//
//  RecordingsList.swift
//  Mustaches
//
//  Created by Rushvi Patel on 12/27/23.
//

import Foundation
import SwiftUI
import AVKit

struct RecordingsListView: View {
    @State private var recordings = [Recording]()
    @State private var selectedVideoURL: URL?
    @State private var isVideoPlayerPresented = false

    var body: some View {
        NavigationView {
            List(recordings, id: \.id) { recording in
                Button(action: {
                    selectedVideoURL = URL(fileURLWithPath: recording.videoFilePath)
                    isVideoPlayerPresented = true
                }) {
                    VStack(alignment: .leading) {
                        Text(recording.tag)
                        Text("Duration: \(recording.duration) seconds").font(.subheadline).foregroundColor(.gray)
                    }
                }
            }
            .navigationBarItems(trailing: Button("Clear All") {
                            clearAllRecordings()
                        })
            .onAppear(perform: loadRecordings)
            .sheet(isPresented: $isVideoPlayerPresented) {
                if let videoURL = selectedVideoURL {
                    VideoPlayerView(videoURL: videoURL)

                }
            }
        }
        
    }

    private func loadRecordings() {
        recordings = DatabaseManager.shared.getRecordings()
    }
    private func clearAllRecordings() {
        DatabaseManager.shared.deleteAllRecordings()
        recordings.removeAll()
    }
}
struct VideoPlayerView: UIViewControllerRepresentable {
    var videoURL: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: videoURL)
        controller.player = player
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the controller if needed.
    }
}
