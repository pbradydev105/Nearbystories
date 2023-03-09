//
//  MyMessageTableViewCell.swift
//  NearbyStores
//
//  Created by Amine on 3/27/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import UIKit

class MyMessageTableViewCell: UITableViewCell {


    override func awakeFromNib() {
        super.awakeFromNib()
        //custom logic goes here
        
      setup()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    
    let messageLabel = UILabel()
    let bubbleBackgroundView = UIView()
    
    var leadingConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    
    
    func setup(){
        
        backgroundColor = .clear
        selectionStyle = .none
        
        bubbleBackgroundView.backgroundColor = .yellow
        bubbleBackgroundView.layer.cornerRadius = 8
        bubbleBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bubbleBackgroundView)
        
        addSubview(messageLabel)
        
        messageLabel.initDefaultFont()
        messageLabel.numberOfLines = 0
    
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // lets set up some constraints for our label
        let constraints = [
            
            messageLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 250),
                           
            bubbleBackgroundView.topAnchor.constraint(equalTo: messageLabel.topAnchor, constant: -10),
            bubbleBackgroundView.leadingAnchor.constraint(equalTo: messageLabel.leadingAnchor, constant: -15),
            bubbleBackgroundView.bottomAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 10),
            bubbleBackgroundView.trailingAnchor.constraint(equalTo: messageLabel.trailingAnchor, constant: 15),
            
        ]
        
        
        
        
        NSLayoutConstraint.activate(constraints)
        
        
        leadingConstraint = messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32)
        leadingConstraint.isActive = false
        
        trailingConstraint = messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32)
        trailingConstraint.isActive = true
        
       
        self.messageLabel.textAlignment = .natural
        self.messageLabel.tintColor = Colors.Appearance.primaryColor
        
        
    }
    
    
    
    var chatMessage: Message! {
        didSet {
            
            bubbleBackgroundView.backgroundColor = chatMessage.type == Message.Values.SENDER_VIEW ? Colors.Appearance.primaryColor : .white
            messageLabel.textColor = chatMessage.type == Message.Values.SENDER_VIEW ? .white : .darkGray
            
            messageLabel.text = chatMessage.message
            
            if chatMessage.type == Message.Values.SENDER_VIEW {
                leadingConstraint.isActive = false
                trailingConstraint.isActive = true
            } else {
                leadingConstraint.isActive = true
                trailingConstraint.isActive = false
            }
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}
