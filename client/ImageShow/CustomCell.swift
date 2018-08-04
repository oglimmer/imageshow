//
//  CustomCell.swift
//  test
//
//  Created by Oli Zimpasser on 7/1/18.
//  Copyright © 2018 Oli Zimpasser. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    
    var messsage: String?
    var mainImage: UIImage?
    
    var messageView : UITextView = {
        var textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isScrollEnabled = false
        return textView
    }()
    
    var mainImageView : UIImageView = {
        var imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(messageView)
        addSubview(mainImageView)
        
        mainImageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        mainImageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        mainImageView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        mainImageView.bottomAnchor.constraint(equalTo: messageView.topAnchor).isActive = true
        mainImageView.heightAnchor.constraint(lessThanOrEqualToConstant: 200).isActive = true
        
        messageView.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        messageView.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        messageView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
       
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let message = messsage {
            messageView.text = message
        }
        if let mainImage = mainImage {
            mainImageView.image = mainImage
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
