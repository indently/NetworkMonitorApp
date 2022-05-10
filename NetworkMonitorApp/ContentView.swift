//
//  ContentView.swift
//  NetworkMonitorApp
//
//  Created by Federico on 10/05/2022.
//

import SwiftUI
import Network

class NetworkMonitor: ObservableObject {
    private let monitor = NWPathMonitor()
    private let queue = DispatchQueue (label: "Monitor")
    @Published var isActive = false
    @Published var isExpensive = false
    @Published var isConstrained = false
    @Published var connectionType = NWInterface.InterfaceType.other
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isActive = path.status == .satisfied
                self.isExpensive = path.isExpensive
                self.isConstrained = path.isConstrained
                
                let connectionTypes: [NWInterface.InterfaceType] = [.cellular, .wifi, .wiredEthernet]
                self.connectionType = connectionTypes.first(where: path.usesInterfaceType) ?? .other
            }
        }
        monitor.start(queue: queue)
    }
}

struct ContentView: View {
    @StateObject var networkMonitor = NetworkMonitor()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text(verbatim: "Connected: \(networkMonitor.isActive)")
            Text(verbatim: "Low Data Mode: \(networkMonitor.isConstrained)")
            Text(verbatim: "Mobile Data / Hotspot: \(networkMonitor.isExpensive)")
            Text(verbatim: "Type: \(networkMonitor.connectionType)")
                
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
