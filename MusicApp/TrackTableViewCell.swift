//
//  TrackTableViewCell.swift
//  MusicApp
//
//  Created by MSS on 23/11/20.
//  Copyright © 2020 Ankit Bansal. All rights reserved.
//

import UIKit

class TrackTableViewCell: UITableViewCell {
    
    // MARK: Cell Interface Builder Outlets
    
    @IBOutlet weak var trackImageVw: UIImageView!
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var artistName: UILabel!
    
    // MARK: Helper Functions
    
    func setCellData(trackDetail: TrackInfo) {
        trackName.text = trackDetail.trackName
        trackImageVw?.image = trackDetail.trackImage
    }
}
