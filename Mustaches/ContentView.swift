//
//  ContentView.swift
//  Mustaches
//
//  Created by Rushvi Patel on 12/25/23.
//
import SwiftUI
import RealityKit
import ARKit


struct ContentView : View {
    @State private var selectedMustache: Int = 1 // default to mustache1

    var body: some View {
        VStack {
            ARViewContainer(selectedMustache: $selectedMustache)
                .edgesIgnoringSafeArea(.all)

            // mustache selection
            Picker("Select Mustache", selection: $selectedMustache) {
                Text("Mustache 1").tag(1)
                Text("Mustache 2").tag(2)
                Text("Mustache 3").tag(3)
            }.pickerStyle(SegmentedPickerStyle())
        }
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
