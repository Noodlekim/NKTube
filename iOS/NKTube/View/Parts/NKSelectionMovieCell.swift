//
//  NKSelectionMovieCell.swift
//  NKTube
//
//  Created by NoodleKim on 2016/05/13.
//  Copyright © 2016年 GibongKim. All rights reserved.
//

import UIKit

class NKSelectionMovieCell: UITableViewCell {

    @IBOutlet weak var olThumbnail: UIImageView!
    @IBOutlet weak var olTitle: UILabel!

    var video: CachedVideo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setData(_ video: CachedVideo) {
        
        self.video = video
        olTitle.text = video.title!

        if let url = video.thumbMedium, let imageUrl = URL(string: url) {
            self.olThumbnail.sd_setImage(with: imageUrl, placeholderImage: NKImage.defaultThumbnail)
        }
    }
}
