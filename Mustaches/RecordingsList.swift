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

    private func loadRecordings() {
        recordings = DatabaseManager.shared.getRecordings()
    }

    var body: some View {
        List(recordings, id: \.id) { recording in
            VStack(alignment: .leading) {
                Text("Tag: \(recording.tag)")
                Text("Duration: \(recording.duration) seconds")
                Text("File Path: \(recording.videoFilePath)")
            }
            .onTapGesture {
                let url = URL(fileURLWithPath: recording.videoFilePath)
                // Check if the file exists before attempting to play
                if FileManager.default.fileExists(atPath: url.path) {
                    selectedVideoURL = url
                    isVideoPlayerPresented = true
                } else {
                    print("File does not exist at path: \(url.path)")
                }
            }
        }
        .onAppear(perform: loadRecordings)
        .sheet(isPresented: $isVideoPlayerPresented) {
            if let url = selectedVideoURL {
                VideoPlayerView(url: url)
            }
        }
    }
}



struct VideoPlayerView: UIViewControllerRepresentable {
    var url: URL

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        let player = AVPlayer(url: url)
        controller.player = player
        player.play() // Start playing the video
        return controller
    }


    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the view controller if needed
    }
}
