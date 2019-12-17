//
//  SwiftLocation - Efficient Location Tracking for iOS
//
//  Created by Daniele Margutti
//   - Web: https://www.danielemargutti.com
//   - Twitter: https://twitter.com/danielemargutti
//   - Mail: hello@danielemargutti.com
//
//  Copyright © 2019 Daniele Margutti. Licensed under MIT License.

import Foundation
import CoreLocation

public class VisitsRequest: ServiceRequest, Hashable {
    
    // MARK: - Typealiases -
    
    public typealias Data = Result<CLVisit,LocationManager.ErrorReason>
    public typealias Callback = ((Data) -> Void)
    
    // MARK: - Public Properties -
    
    /// Unique identifier of the request.
    public var id: LocationManager.RequestID
    
    /// Timeout of the request. Not applicable for visits request.
    public var timeout: Timeout.Mode? = nil
    
    /// State of the request.
    public var state: RequestState = .idle
    
    /// Callbacks called once whether a new visit-related event or error is received.
    public var observers = Observers<VisitsRequest.Callback>()
    
    /// Last obtained valid value for request.
    public internal(set) var value: CLVisit?
    
    // MARK: - Initialization -
    
    internal init() {
        self.id = UUID().uuidString
    }
    
    // MARK: - Public Functions -
    
    public func stop() {
        stop(reason: .cancelled, remove: true)
    }
    
    public func start() {
        self.state = .running
    }
    
    public func pause() {
        self.state = .paused
    }
    
    // MARK: - Protocol Conformances -
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    public static func == (lhs: VisitsRequest, rhs: VisitsRequest) -> Bool {
        return lhs.id == rhs.id
    }
    
    // MARK: - Internal Methods -
    
    /// Stop a request with passed error reason and optionally remvoe it from queue.
    ///
    /// - Parameters:
    ///   - reason: reason of failure.
    ///   - remove: `true` to also remove it from queue. Not applicable for visits request.
    internal func stop(reason: LocationManager.ErrorReason = .cancelled, remove: Bool) {
        dispatch(data: .failure(reason))
    }
    
    internal func complete(visit: CLVisit) {
        guard state.canReceiveEvents else {
            return // ignore events
        }
        
        value = visit
        dispatch(data: .success(visit)) // dispatch to callbacks
    }
    
    /// Dispatch received events to all callbacks.
    ///
    /// - Parameter data: data to pass.
    internal func dispatch(data: Data) {
        observers.list.forEach {
            $0(data)
        }
    }
}
