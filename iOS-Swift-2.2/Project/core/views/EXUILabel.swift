//
//  EXUILabel.swift
//  NearbyStores
//
//  Created by Amine  on 10/2/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit

class EXUILabel: UILabel {


     override func awakeFromNib() {
          super.awakeFromNib()
          setup()
      }

      override func layoutSubviews() {
            setup()
      }
      
      override init(frame: CGRect) {
          super.init(frame: frame)
          setup()
      }
      
      
      required init?(coder aDecoder: NSCoder) {
          super.init(coder: aDecoder)
          setup()
      }
      
      func setup() {
         
          self.roundedCorners(radius: 25)
          
      }
    

}
