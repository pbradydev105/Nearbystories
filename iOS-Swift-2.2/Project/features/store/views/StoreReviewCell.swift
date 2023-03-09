//
//  StoreReviewView.swift
//  NearbyStores
//
//  Created by Amine on 7/6/18.
//  Copyright © 2018 Amine. All rights reserved.
//

import UIKit
import Cosmos

class StoreReviewCell: UITableViewCell {
    
    
    @IBOutlet weak var user_image: UIImageView!
    @IBOutlet weak var commentLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var ratingContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        
        settings()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    func settings() {
        
        commentLabel.initDefaultFont()
        username.initDefaultFont()
        
        user_image.layer.borderWidth = 2
        user_image.layer.masksToBounds = false
        user_image.layer.borderColor = Utils.hexStringToUIColor(hex: "#eeeeee").cgColor
        user_image.layer.cornerRadius = user_image.frame.height/2
        user_image.clipsToBounds = true
        
        self.backgroundColor = UIColor.white
        
        self.ratingContainer.addSubview(ratingView)
        
        ratingView.translatesAutoresizingMaskIntoConstraints = false
        
        var constraints: [NSLayoutConstraint] = []
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutConstraint.Attribute.right,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutConstraint.Attribute.right,
            multiplier: 1, constant: 0
        ))
        
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutConstraint.Attribute.top,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutConstraint.Attribute.top,
            multiplier: 1, constant: 0
        ))
        
        constraints.append(NSLayoutConstraint(
            item: ratingView,
            attribute: NSLayoutConstraint.Attribute.bottom,
            relatedBy: NSLayoutConstraint.Relation.equal,
            toItem: ratingContainer,
            attribute: NSLayoutConstraint.Attribute.bottom,
            multiplier: 1, constant: 0
        ))
        
        self.ratingContainer.addConstraints(constraints)
    }
    
    func setup(object: Review) {
        
        self.username.text = object.pseudo.capitalizingFirstLetter()
        self.commentLabel.text = object.review
        
        
        if object.image != "" {
            
            let url = URL(string: object.image)
            
            self.user_image.kf.indicatorType = .activity
            if let img = UIImage(named: "profile_placeholder") {
                self.user_image.kf.setImage(with: url, placeholder: img, options: [.transition(.fade(0.2))], progressBlock: nil)
            }
            
        }else{
            if let img = UIImage(named: "profile_placeholder") {
                self.user_image.image = img
            }
        }
        
        self.ratingView.rating = object.rate
        
    }
    
    
    
    let ratingView: CosmosView = {
        
        
        let cosmosView = CosmosView()
        
        cosmosView.rating = 0
        
        // Change the text
        cosmosView.text = ""
        cosmosView.settings.textColor = Colors.black
        cosmosView.settings.updateOnTouch = false
        
        if let font = UIFont(name: AppConfig.Design.Fonts.regular, size: 12) {
            cosmosView.settings.textFont = font
        }
        
        
        // Called when user finishes changing the rating by lifting the finger from the view.
        // This may be a good place to save the rating in the database or send to the server.
        cosmosView.didFinishTouchingCosmos = { rating in }
        
        // A closure that is called when user changes the rating by touching the view.
        // This can be used to update UI as the rating is being changed by moving a finger.
        cosmosView.didTouchCosmos = { rating in }
        
        
        return cosmosView
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}
