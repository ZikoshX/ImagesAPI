//
//  ImageCollectionViewCell.swift
//  labka6
//
//  Created by Admin on 10.11.2023.
//

import UIKit
struct UrlResponse: Codable{
    let total:Int
    let totalHits: Int
    let hits: [Hits]
}
struct Hits: Codable{
    let id: Int
    let webformatURL: String
}

class ViewController: UIViewController, UICollectionViewDataSource, UISearchBarDelegate {
        
    private var collectionView: UICollectionView?
    private let segmentControl: UISegmentedControl = {
            let sc = UISegmentedControl(items: ["1x1", "2x2", "3x3"])
            sc.selectedSegmentIndex = 0
            sc.translatesAutoresizingMaskIntoConstraints = false
            sc.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
            return sc
        }()
    var hits: [Hits] = []
    
    let searchBar = UISearchBar()
    let butt = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.delegate = self
        view.addSubview(searchBar)
        view.addSubview(segmentControl)
        view.addSubview(butt)
        view.backgroundColor = .white
        butt.backgroundColor = .systemBlue
        butt.setTitle(">", for: .normal)
        butt.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.width)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ImageCollectionViewCell.self, forCellWithReuseIdentifier: ImageCollectionViewCell.identifier)
        collectionView.dataSource = self
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        self.collectionView = collectionView
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        searchBar.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.frame.size.width-70, height: 50)
        butt.frame = CGRect(x: 340, y: 63, width: 40, height: 40)
        segmentControl.frame = CGRect(x: 10, y: searchBar.frame.maxY + 10, width: view.frame.size.width-20, height: 30)
        collectionView?.frame = CGRect(x: 0, y: segmentControl.frame.maxY + 10, width: view.frame.size.width, height: view.frame.size.height - segmentControl.frame.maxY - 10)
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        hits = []
        collectionView?.reloadData()
        if let text = searchBar.text{
            fetchPhoto(query: text)
        }
    }
    @objc func buttonTapped(_ button: UIButton) {
        button.isHidden = false
        let VC = SecondViewController()
        present(VC, animated: true)
        
//        VC.modalPresentationStyle = .fullScreen
//        self.navigationController?.pushViewController(VC, animated: true)
       }
    
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        _ = sender.selectedSegmentIndex
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        switch sender.selectedSegmentIndex {
        case 0:
            layout.itemSize = CGSize(width: view.frame.size.width, height: view.frame.size.width)
            break
        case 1:
            layout.itemSize = CGSize(width: view.frame.size.width/2, height: view.frame.size.width/2)
            break
        case 2:
            layout.itemSize = CGSize(width: view.frame.size.width/3, height: view.frame.size.width/3)
            break
        default:
            break
        }
    
        collectionView?.setCollectionViewLayout(layout, animated: true)
                
    }
    
    func fetchPhoto(query: String){
        let urlString = "https://pixabay.com/api/?key=40600056-917c9a5bb66e0fdb62859c265&per_page=20&q=\(query)&image_type=photo&pretty=true"

        guard let url = URL(string: urlString) else{
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else{
                return
            }
            do {
                let jsonresult = try JSONDecoder().decode(UrlResponse.self, from: data)
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
        let result = hits[indexPath.row].webformatURL
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCollectionViewCell.identifier, for: indexPath) as? ImageCollectionViewCell else{
            return ImageCollectionViewCell()
        }
        cell.configure(with: result)
        return cell
    }
}
