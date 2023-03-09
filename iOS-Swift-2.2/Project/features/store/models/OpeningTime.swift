//
//  OpeningTime.swift
//  NearbyStores
//
//  Created by Amine on 3/11/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit
import RealmSwift

class OpeningTime: Object {

    @objc dynamic var id: Int = 0
    @objc dynamic var store_id: Int = 0
    @objc dynamic var day: String = ""
    @objc dynamic var opening: String = ""
    @objc dynamic var closing: String = ""
    @objc dynamic var enabled: Int = 0


    override static func primaryKey() -> String? {
        return "id"
    }
}
