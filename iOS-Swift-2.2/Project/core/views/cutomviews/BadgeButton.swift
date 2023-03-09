//
//  BadgeButton.swift
//  NSApplication1.8
//
//  Created by Amine  on 2/20/20.
//  Copyright © 2020 Amine. All rights reserved.
//

import UIKit
import BadgeSwift

class BadgeButton: UIButton {
    
    var notification = 0
    var badge: BadgeSwift? = nil
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
      func refreshBadge(count: Int) {
          self.notification = count
          if let badge = self.badge {
              if notification == 0 {
                  badge.isHidden = true
              }else{
                  badge.text = "\(notification)"
                  badge.isHidden = false
                  
              }
          }
      }
      
      
    
    func setupBadge() -> BadgeButton {
          
          let badge = BadgeSwift()
          self.addSubview(badge)
        
            badge.isHidden = true
          // Text
          badge.text = "0"
          
          
          // Insets
          badge.insets = CGSize(width: 4, height: 4)
          
          // Font
          badge.font = UIFont.preferredFont(forTextStyle: UIFont.TextStyle.body)
          badge.font = badge.font.withSize(10)
          
          // Text color
          badge.textColor = Colors.Appearance.primaryColor
          
          // Badge color
        badge.badgeColor = UIColor.white
          
          // No shadow
          badge.shadowOpacityBadge = 0
          
          badge.borderWidth = 1
        badge.borderColor = .clear
          
          positionBadge(badge)
        
            self.badge = badge
          
          return self
      }
      
      private func positionBadge(_ badge: UIView) {
          badge.translatesAutoresizingMaskIntoConstraints = false
          var constraints = [NSLayoutConstraint]()
          
          constraints.append(NSLayoutConstraint(
              item: badge,
              attribute: NSLayoutConstraint.Attribute.left,
              relatedBy: NSLayoutConstraint.Relation.equal,
              toItem: self,
              attribute: NSLayoutConstraint.Attribute.right,
              multiplier: 1, constant: -15)
          )
          
          constraints.append(NSLayoutConstraint(
              item: badge,
              attribute: NSLayoutConstraint.Attribute.top,
              relatedBy: NSLayoutConstraint.Relation.equal,
              toItem: self,
              attribute: NSLayoutConstraint.Attribute.top,
              multiplier: 1, constant: 0)
          )
          
          self.addConstraints(constraints)
      }

}
