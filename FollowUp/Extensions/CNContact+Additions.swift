//
//  CNContact+Additions.swift
//  FollowUp
//
//  Created by Aaron Baw on 13/09/2024.
//

import Contacts
import Foundation

extension CNContact {
    func toContact() -> Contact {
        Contact(from: self)
    }
}
