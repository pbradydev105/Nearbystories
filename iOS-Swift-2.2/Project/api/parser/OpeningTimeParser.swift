//
//  UserParser.swift
//  NearbyStores
//
//  Created by Amine on 5/20/18.
//  Copyright © 2018 Amine. All rights reserved.
//

//
//  JobParser.swift
//  AppTest
//
//  Created by Amine on 5/15/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit

class OpeningTimeParser: Parser {



    func parse() -> [OpeningTime] {

        var list = [OpeningTime]()


        if let myResult = self.result {


            if myResult.count > 0 {

                let size = myResult.count-1

                for index in 0...size {

                    let object = myResult[ String(index) ]


                    let myObject = OpeningTime()

                    myObject.id = object["id"].intValue

                    myObject.store_id = object["store_id"].intValue
                    myObject.opening = object["opening"].stringValue
                    myObject.closing = object["closing"].stringValue
                    myObject.day = object["day"].stringValue
                    myObject.enabled = object["enabled"].intValue

                    list.append(myObject)


                }


            }


            return list
        }

        return []
    }


}



