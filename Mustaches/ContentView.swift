//
//  ContentView.swift
//  Mustaches
//
//  Created by Rushvi Patel on 12/25/23.
//
import SwiftUI
import RealityKit
import ARKit
import ReplayKit
import AVKit

class PreviewDelegate: NSObject, RPPreviewViewControllerDelegate {
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true)
    }
}

struct ContentView : View {
    @State private var selectedMustache: Int = 1 // default to mustache1
    @State private var isRecording = false
    @State private var showTagInputView = false
    @State private var tagText = ""
    @State private var recordedVideoURL: URL?
    @State private var recordedVideoDuration: TimeInterval = 0
    @State private var isVideoPreviewPresented = false

    let previewDelegate = PreviewDelegate()

    var body: some View {
        NavigationView {
            VStack {
                ARViewContainer(selectedMustache: $selectedMustache)
                    .edgesIgnoringSafeArea(.all)
                if !isRecording {
                    Picker("Select Mustache", selection: $selectedMustache) {
                        Text("Mustache 1").tag(1)
                        Text("Mustache 2").tag(2)
                        Text("Mustache 3").tag(3)
                    }.pickerStyle(SegmentedPickerStyle())
                    
                    NavigationLink(destination: RecordingsListView()) {
                                Text("View Recordings")
                    }
                }
                Button(isRecording ? "Stop Recording" : "Start Recording") {
                    if isRecording {
                        stopRecording()
                    } else {
                        startRecording()
                    }
                }.padding()

                if showTagInputView && !isRecording {
                        TagInputView(isPresented: $showTagInputView, tagText: $tagText) {
                                self.isVideoPreviewPresented = true
                            
                        }
                    }
            
                }
            .sheet(isPresented: $isVideoPreviewPresented) {
                if let videoURL = recordedVideoURL {
                    VideoPreviewView(videoURL: videoURL, isPresented: $isVideoPreviewPresented, onSave: {
                        self.isVideoPreviewPresented = false
                        self.showTagInputView = false
                        if let videoPath = recordedVideoURL?.path {
                            DatabaseManager.shared.saveRecording(videoPath: videoPath, duration: Int(recordedVideoDuration), tagText: tagText)

                        }
                        
                    }, onCancel: {
                        self.isVideoPreviewPresented = false
                        self.showTagInputView = false
                    })
                } else {
                    Text("No video selected")
                }
            }



            }
        }
            
    func startRecording() {
        let recorder = RPScreenRecorder.shared()
        recorder.startRecording { error in
            if let error = error {
                print("Recording failed to start: \(error.localizedDescription)")
            } else {
                isRecording = true
            }
        }
    }

    func stopRecording() {
        guard let tempURL = tempURL() else {
            print("Failed to create temp URL")
            return
        }

        let recorder = RPScreenRecorder.shared()
        recordedVideoURL = tempURL

        if let unwrappedURL = recordedVideoURL {
            recorder.stopRecording(withOutput: unwrappedURL) { error in
                DispatchQueue.main.async {
                    self.isRecording = false
                    if let error = error {
                        print("Failed to save: \(error.localizedDescription)")
                    } else {
                        print("Recorded video URL: \(unwrappedURL)")
                        self.showTagInputView = true
                    }
                }
            }
        } else {
            print("Error: Recorded video URL is nil")
        }
    }


    func tempURL() -> URL? {
                let directory = NSTemporaryDirectory() as NSString
                if directory != "" {
                    let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
                    return URL(fileURLWithPath: path)
                }
                return nil
            }

}
struct VideoPreviewView: View {
    var videoURL: URL
    @Binding var isPresented: Bool
    var onSave: () -> Void
    var onCancel: () -> Void

    var body: some View {
        VStack {
            VideoPlayer(player: AVPlayer(url: videoURL))
                .frame(height: 300)

            HStack {
                Button("Cancel") {
                    onCancel()
                }
                Button("Save") {
                    onSave()
                }
            }
        }
    }
}

struct TagInputView: View {
    @Binding var isPresented: Bool
    @Binding var tagText: String
    var onSave: () -> Void

    var body: some View {
        VStack {
            TextField("Enter a tag", text: $tagText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button("Save") {
                onSave()
                isPresented = false
            }.padding()
        }
        .frame(width: 300, height: 200)
        .background(Color.white)
        .cornerRadius(20).shadow(radius: 10)
    }
}

struct ARViewContainer: UIViewRepresentable {
    @Binding var selectedMustache: Int
    
    func makeUIView(context: Context) -> ARView {
        let arView = ARView(frame: .zero)
        updateMustacheOverlay(arView: arView)
        return arView
    }
    
    func updateUIView(_ uiView: ARView, context: Context) {
        updateMustacheOverlay(arView: uiView)
    }
    
    private func updateMustacheOverlay(arView: ARView) {
        let faceTrackingConfig = ARFaceTrackingConfiguration()
        arView.session.run(faceTrackingConfig, options: [.resetTracking, .removeExistingAnchors])

        arView.scene.anchors.removeAll()

        switch selectedMustache {
        case 1:
            if let mustacheScene = try? Mustache1.loadScene() {
                arView.scene.anchors.append(mustacheScene)
            }
        case 2:
            if let mustacheScene = try? Mustache2.loadScene() {
                arView.scene.anchors.append(mustacheScene)
            }
        case 3:
            if let mustacheScene = try? Mustache3.loadScene() {
                arView.scene.anchors.append(mustacheScene)
            }
        default:
            break
        }
    }

}

#if DEBUG
struct ContentView_Previews : PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
