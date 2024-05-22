//
//  VideoCollectionViewCell.swift
//  Lab6
//
//  Created by Admin on 11.11.2023.
//

import UIKit
import AVFoundation
import AVKit

class VideoCollectionViewCell: UICollectionViewCell {
    static let identifier = "VideoCollectionViewCell"
    
    private let VideoView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        return iv
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(VideoView)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        VideoView.frame = contentView.bounds
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        VideoView.image = nil
    }
    func  configure(with url: String){
        guard let url = URL(string: url) else{
            return
        }
        URLSession.shared.dataTask(with: url) {[weak self] data, _, error in
            guard let data = data, error == nil else{
                return
            }
            DispatchQueue.main.sync{
                let image = UIImage(data: data)
                self?.VideoView.image = image
            }
        }.resume()
    }
}
