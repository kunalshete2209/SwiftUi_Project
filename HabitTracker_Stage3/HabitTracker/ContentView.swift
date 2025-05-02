//
//  ContentView.swift
//  HabitTracker
//
//  Created by Kunal Shete on 13/03/25.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    var body: some View {
        Home()
            .preferredColorScheme(isDarkMode ? .dark : .light) 
    }
}

#Preview {
    ContentView()
}
