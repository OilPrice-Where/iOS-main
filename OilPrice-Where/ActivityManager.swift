//
//  ActivityManager.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/11/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import ActivityKit

@available(iOS 16.1, *)
final class ActivityManager: NSObject {
    // MARK: - Properties
    static let shared = ActivityManager()
    var activity: Activity<StationAttributes>? = nil
    
    // MARK: - Initializer
    private override init() {
        super.init()
    }
    
    func configure() {
        Task {
            await endActivities()
            
            activity = nil
            createActivities()
        }
    }
    
    func createActivities() {
        let attributes = StationAttributes()
        let state = StationAttributes.ContentState()
        
        activity = try? Activity<StationAttributes>.request(attributes: attributes, contentState: state, pushType: nil)
    }
    
    func updateActivity(state: StationAttributes.ContentState) {
        Task {
            await activity?.update(using: state)
        }
    }
    
    func endActivities() async {
        for activity in Activity<StationAttributes>.activities {
            await activity.end(dismissalPolicy: .immediate)
        }
    }
    
    func endActivity() async {
        let state = activity?.contentState
        await activity?.end(using: state, dismissalPolicy: .immediate)
    }
    
    func station() -> FindStation? {
        return activity?.contentState.station
    }
}
