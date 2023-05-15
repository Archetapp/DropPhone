//
//  ContentView.swift
//  DropPhone
//
//  Created by Jared Davidson on 5/15/23.
//

import SwiftUI
import CoreMotion

struct AccelerationView: View {
    @State private var acceleration: Double = 0.0
    @State private var isInFreefall = false
    @State private var unlocked: Bool = false
    private let motionManager = CMMotionManager()
    
    var body: some View {
        Group {
            if unlocked == true {
                ZStack {
                    Color.green.edgesIgnoringSafeArea(.all)
                    Text("Unlocked!")
                        .font(.title)
                }
            } else {
                VStack {
                    Text("Current Acceleration")
                        .font(.title)
                    
                    Text("\(acceleration)")
                        .font(.largeTitle)
                        .padding()
                    
                    Text(isInFreefall ? "Freefall Detected" : "")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
        }
        .onAppear {
            startAccelerometerUpdates()
        }
        .onDisappear {
            stopAccelerometerUpdates()
        }
    }
    
    func startAccelerometerUpdates() {
        guard motionManager.isAccelerometerAvailable else {
            print("Accelerometer is not available.")
            return
        }
        
        motionManager.accelerometerUpdateInterval = 0.1
        
        motionManager.startAccelerometerUpdates(to: .main) { (data, error) in
            if let error = error {
                print("Error receiving accelerometer data: \(error.localizedDescription)")
                return
            }
            
            if let acceleration = data?.acceleration {
                let speed = sqrt(pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2))
                
                self.acceleration = speed
                
                if speed < 0.1 { // Adjust the threshold as needed
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.isInFreefall = true
                        self.unlocked = true
                    }
                } else {
                    self.isInFreefall = false
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}

struct ContentView: View {
    var body: some View {
        AccelerationView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
