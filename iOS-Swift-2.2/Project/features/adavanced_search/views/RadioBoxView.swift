//
//  RadioBoxView.swift
//  NearbyStores
//
//  Created by Amine  on 8/22/19.
//  Copyright © 2019 Amine. All rights reserved.
//

import Foundation
import UIKit

protocol RadioBoxDelegate {
    func onChange(key: String, activeView: UIButton, views: [String: UIButton])
}

class RadioBoxView: UIView {
    
    var values:[String:Bool] = [:]
    var style = RadioBoxStyle()
    var perLine: Int? = 5
    var selectedKey: String = ""
    
    override init(frame: CGRect) {
       super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        //fatalError("init(coder:) has not been implemented")
    }
    
    
    var stackView: UIStackView? = nil

    var list_buttons: [String: UIButton] = [:]
    
    
    func setup(items: [RadioObject]) {
        self.style = RadioBoxStyle()
        setup(size: 50, items: items)
    }
    
    func setup(style: RadioBoxStyle,items: [RadioObject]) {
        self.style = style
        setup(size: 50, items: items)
    }
    
    func setup(size: CGFloat,style: RadioBoxStyle,items: [RadioObject]) {
        self.style = style
        setup(size: size, items: items)
    }
    
    func setup(size: CGFloat,items: [RadioObject]){
        attachViews(size: size, items: items)
    }
    
    func attachViews(size: CGFloat,items: [RadioObject]){
        

        let container = UIView()
        container.backgroundColor = .clear
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(container)
        
        stackView = UIStackView()
        stackView?.axis = .horizontal
        stackView?.alignment = .center
        stackView?.distribution = .fillEqually
        stackView?.spacing = CGFloat(5)
        stackView?.backgroundColor = .clear
        stackView?.translatesAutoresizingMaskIntoConstraints = false
       
        
        container.addSubview(stackView!)
        
        
        let leading = NSLayoutConstraint(item: stackView!, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1, constant: 20)
        let trailing = NSLayoutConstraint(item: stackView!, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1, constant: -20)
        let height = NSLayoutConstraint(item: stackView!, attribute: .height, relatedBy: .equal, toItem: container, attribute: .height, multiplier: 0.8, constant: size)
        let alignInCenter = NSLayoutConstraint(item: stackView!, attribute: .centerX, relatedBy: .equal, toItem: container, attribute: .centerX, multiplier: 1, constant: 0)
        let alignInCenterY = NSLayoutConstraint(item: stackView!, attribute: .centerY, relatedBy: .equal, toItem: container, attribute: .centerY, multiplier: 1, constant: 0)
        
        NSLayoutConstraint.activate([alignInCenter,alignInCenterY,leading, trailing, height])

        for index in 0...(items.count-1){
            
            let object = items[index]
            
            let view = addView(size: size,key: object.key!, value: object.state!)
            
            stackView?.addArrangedSubview(view)
            
        }

        
        addConstraintsWithFormat(format: "H:|[v0]|", views: container)
        addConstraintsWithFormat(format: "V:|[v0]|", views: container)
        
        self.layoutIfNeeded()
        
    }
    
    //perLine
    
    let list: [UIView] = []
    func addView(size: CGFloat,key:String, value: Bool) -> UIView {
        
        let view = UIView()
        view.backgroundColor  = .clear
        //view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false

        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.setTitle(key.localized.uppercased(), for: .normal)
        
        let constraints = [
            button.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
            button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        ]
        
        
        
        button.initDefaultFont(size: 12)
        button.setTitleColor(style.disabledText, for: .normal)
        
       
        
        NSLayoutConstraint.activate(constraints)

        view.heightAnchor.constraint(equalToConstant: size).isActive = true
        
        list_buttons[key] = button
        
        button.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
        
        return view
    }
    
    
    func focus(key: String) {
        
        for (_,button) in self.list_buttons{
             desactive(view: button)
        }
        
        for (_key,button) in self.list_buttons{
            if key == _key{
                
                selectedKey = key
                active(view: button)
                
                //click
                if let _del = self.delegate{
                    
                    for (key,_button) in list_buttons{
                        if button == _button{
                            _del.onChange(key: key, activeView: button, views: list_buttons)
                        }
                    }
                    
                }
                
            }else{
                desactive(view: button)
            }
        }
        
        
    }
    
    
    func focusSilence(key: String) {
        
        for (_,button) in self.list_buttons{
            desactive(view: button)
        }
        
        for (_key,button) in self.list_buttons{
            if key == _key{
                
                selectedKey = key
                active(view: button)
                
            }else{
                desactive(view: button)
            }
        }
        
        
    }
    
    var delegate: RadioBoxDelegate? = nil
    
    
    @objc func buttonClicked(sender : UIButton){
       
        if let _del = self.delegate{
            
            for (key,button) in list_buttons{
                if sender == button{
                   
                     selectedKey = key
                     change(key: key)
                   
                    _del.onChange(key: key, activeView: sender, views: list_buttons)
                }
            }
            
        }
        
    }
    
    func change(key: String){
        
        for (_,button) in self.list_buttons{
            desactive(view: button)
        }
        
        for (_key,button) in self.list_buttons{
            if key == _key{
                
                active(view: button)

                
            }else{
                desactive(view: button)
            }
        }
    }
    
    private func active(view: UIButton){
       
        
        view.backgroundColor = style.enabledBackground
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = style.enabledBorder?.cgColor
        view.setTitleColor(style.enabledText, for: .normal)
        view.backgroundColor = style.enabledBackground
        
        /*UIView.animate(withDuration: 0.3, animations: {
           self.layoutIfNeeded()
        })*/
    }
    
    private func desactive(view: UIButton){
        
        view.backgroundColor = style.disabledBackground
        view.layer.cornerRadius = 5
        view.layer.borderWidth = 1
        view.layer.borderColor = style.disabledBorder?.cgColor
        view.setTitleColor(style.disabledText, for: .normal)
        view.backgroundColor = style.disabledBackground
        
        /*UIView.animate(withDuration: 0.3, animations: {
            
            
            self.layoutIfNeeded()
        })*/
    }
    

}

struct RadioObject {
    
    var key: String? = nil
    var state: Bool? = nil
    
    init(key: String) {
        self.key = key
        self.state = false
    }
    
    init(key: String,state: Bool) {
        self.key = key
        self.state = state
    }
}


struct RadioBoxStyle {
    
    
    var disabledBorder: UIColor? = .clear
    var disabledBackground: UIColor? = .white
    var disabledText: UIColor? = Colors.Appearance.primaryColor
    
    var enabledBorder: UIColor? = Colors.Appearance.primaryColor
    var enabledBackground: UIColor? = .white
    var enabledText: UIColor? = Colors.Appearance.primaryColor
    
    
}
