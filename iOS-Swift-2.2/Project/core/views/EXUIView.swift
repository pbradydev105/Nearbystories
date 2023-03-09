//
//  EXUIView.swift
//  NearbyStores
//
//  Created by Amine  on 9/7/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit

class EXUIView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
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
    
        self.backgroundColor = Colors.Appearance.whiteGrey
        self.roundedCorners(radius: (25.0))
        self.layoutIfNeeded()
        
    }
}
