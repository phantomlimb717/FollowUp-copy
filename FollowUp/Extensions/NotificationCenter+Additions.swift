//
//  NotificationCenter+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 18/06/2025.
//

import Combine
import NotificationCenter

extension NotificationCenter {
    func keyboardVisiblePublisher() -> AnyPublisher<Bool, Never> {
        let willShow = NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true }

                let willHide = NotificationCenter.default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false }

                return Publishers.Merge(willShow, willHide)
                    .eraseToAnyPublisher()
    }
}
