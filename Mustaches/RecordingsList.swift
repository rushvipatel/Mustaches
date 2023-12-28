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

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(recordings, id: \.id) { recording in
                        VStack {
                            Button(action: {
                                selectedVideoURL = URL(fileURLWithPath: recording.videoFilePath)
                                isVideoPlayerPresented = true
                            }) {
                                VStack {
                                    VideoThumbnailView(videoURL: URL(fileURLWithPath: recording.videoFilePath))
                                    Text(recording.tag)
                                    Text("Duration: \(recording.duration) second(s)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                .padding()
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
struct VideoThumbnailView: View {
    let videoURL: URL

    var body: some View {
        let thumbnail = generateThumbnail(url: videoURL)
        return Image(uiImage: thumbnail)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: 100, height: 100)
            .clipped()
    }

    func generateThumbnail(url: URL) -> UIImage {
        let asset = AVAsset(url: url)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(1.0, preferredTimescale: 600)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: img)
        } catch {
            return UIImage(systemName: "film") ?? UIImage()
        }
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
