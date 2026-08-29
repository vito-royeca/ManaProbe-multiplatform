//
//  TestView.swift
//  Manaprobe
//
//  Created by Vito Royeca on 4/15/26.
//

import SwiftUI
import ManaKit

struct TimeDisplayTestView: View {
    // Dates
    @State var startDate = Date.now
    var futureDate = Date.now.addingTimeInterval(3000)
    
    // Formatters
    let dateFormatter = Date.FormatStyle(date: .omitted,
                                         time: .standard)
    var offsetFormatter: SystemFormatStyle.DateOffset {
        .offset(to: futureDate)
    }
    var referenceFormatter: SystemFormatStyle.DateReference {
        .reference(to: futureDate)
    }
    var stopwatchStyle: SystemFormatStyle.Stopwatch {
        .stopwatch(startingAt: startDate)
    }
    var timerUpStyle: SystemFormatStyle.Timer {
        .timer(countingUpIn: startDate..<futureDate)
    }
    var timerDownStyle: SystemFormatStyle.Timer {
        .timer(countingDownIn: startDate..<futureDate)
    }

    var body: some View {
        
        TimelineView(.periodic(from: startDate, by: 1.0)) { context in
            List {
                VStack(alignment: .leading) {
                    Text(context.date, format: dateFormatter)
                        .font(.headline)
                    Text("Current Date")
                        .font(.subheadline)
                }

                VStack(alignment: .leading) {
                    Text(context.date, format: offsetFormatter)
                        .font(.headline)
                    Text("Date offset style on text")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text(context.date, format: referenceFormatter)
                        .font(.headline)
                    Text("Date reference style on text")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text(context.date, format: stopwatchStyle)
                        .font(.headline)
                    Text("Stopwatch style on text")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text(context.date, format: timerUpStyle)
                        .font(.headline)
                    Text("Timer going up style on text")
                        .font(.subheadline)
                }
                
                VStack(alignment: .leading) {
                    Text(context.date, format: timerDownStyle)
                        .font(.headline)
                    Text("Timer going down style on text")
                        .font(.subheadline)
                }
                
                
            }
            
        }
    }
}

#Preview {
    TimeDisplayTestView()
}
