//
//  ImageTableViewCell.swift
//  Eventy
//
//  Created by Valentin Varbanov on 17.02.18.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var myImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
