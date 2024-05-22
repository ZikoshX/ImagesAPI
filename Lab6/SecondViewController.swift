//
//  ViedoViewController.swift
//  Lab6
//
//  Created by Admin on 11.11.2023.
//

import UIKit
struct APIResponse: Codable{
    let total:Int
    let totalHits: Int
    let hits: [Hit]
}
struct Hit: Codable{
    let id: Int
    let videos: Videos
}
struct Videos: Codable{
    let meduim: Meduim
}
struct Meduim: Codable{
    let url: String
}
class SecondViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UISearchBarDelegate {

  
        private var collectionView: UICollectionView?
        
        var hits: [Hit] = []
        
        let searchBar = UISearchBar()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            searchBar.delegate = self
            view.backgroundColor = .gray
            view.addSubview(searchBar)
            let layout = UICollectionViewFlowLayout()
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 0
            layout.minimumInteritemSpacing = 0
            layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
            let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
            collectionView.register(VideoCollectionViewCell.self, forCellWithReuseIdentifier: VideoCollectionViewCell.identifier)
            collectionView.dataSource = self
            view.addSubview(collectionView)
            collectionView.backgroundColor = .systemBackground
            self.collectionView = collectionView
        }
        
        override func viewDidLayoutSubviews() {
            super.viewDidLayoutSubviews()
            searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-20, height: 50)
            collectionView?.frame = CGRect(x: 0, y: view.safeAreaInsets.top+55, width: view.frame.size.width, height: view.frame.size.height-55)
        }
        
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
            hits = []
            collectionView?.reloadData()
            if let text = searchBar.text{
                fetchPhoto(query: text)
            }
        }
        
        func fetchPhoto(query: String){
            let urlString = "https://pixabay.com/api/videos/?key=40600056-917c9a5bb66e0fdb62859c265&per_page=20&q=\(query)"

            guard let url = URL(string: urlString) else{
                return
            }
            let task = URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, error == nil else{
                    return
                }
                do {
                    let jsonresult = try JSONDecoder().decode(APIResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.hits = jsonresult.hits
                        self.collectionView?.reloadData()
                    }
                    
                }
                catch {
                    print(error)
                }
            }
                task.resume()
        }
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            hits.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let result = hits[indexPath.row].videos.meduim.url
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoCollectionViewCell.identifier, for: indexPath) as? VideoCollectionViewCell else{
                return VideoCollectionViewCell()
            }
            cell.configure(with: result)
            return cell
        }
    }

    


