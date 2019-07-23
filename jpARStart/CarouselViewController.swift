//
//  ViewController.swift
//  taskCollectionFlowLayout
//
//  Created by Yogesh Patel on 21/04/18.
//  Copyright © 2018 Yogesh Patel. All rights reserved.
//

import UIKit
struct ModelCollectionFlowLayout {
    var title:String = ""
    var jpTxt = ""
    var image:UIImage!
}
class CarouselViewController: UIViewController {
    @IBOutlet weak var funFacts: UILabel!
       let funFactes = ["Nigiri is meant to be eaten upside down for the best sushi dining experience.","Avocado, cucumber, and carrots are the most popular veggies used in sushi.","Gunkan sushi is also called battleship sushi or Gundam sushi."]
    
    var arrData = [ModelCollectionFlowLayout]()
    
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var jpnTxt: UILabel!
    @IBOutlet weak var lblItemName: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        confPageControl()
        collectData()
        //setButton()
        self.collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "Cell")
        
        let floawLayout = UPCarouselFlowLayout()
        floawLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width - 60.0, height: collectionView.frame.size.height)
        floawLayout.scrollDirection = .horizontal
        floawLayout.sideItemScale = 0.7
        floawLayout.sideItemAlpha = 0.7
        floawLayout.spacingMode = .fixed(spacing: 10.0)
        collectionView.collectionViewLayout = floawLayout
        
    }

    func confPageControl(){
        pageControl.numberOfPages = 3
    
    }
    func collectData(){
        arrData = [
            ModelCollectionFlowLayout(title: "NIGIRI SUSHI",jpTxt: "にぎり寿司", image: #imageLiteral(resourceName: "Nigiri")),
            ModelCollectionFlowLayout(title: "ROLL SUSHI",jpTxt: "巻き寿司", image: #imageLiteral(resourceName: "RollCs")),
            ModelCollectionFlowLayout(title: "GUNKAN SUSHI", jpTxt: "群れ寿司", image: #imageLiteral(resourceName: "GunkanCs"))
        ]
    }
    
    /*
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }*/
    fileprivate var currentPage: Int = 0 {
        didSet {
            
            print("page at centre = \(currentPage)")
            if(currentPage >= 0 && currentPage < 3){
                lblItemName.text = arrData[currentPage].title
                jpnTxt.text = arrData[currentPage].jpTxt
            }
        }
    }
    
  /*  func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let xVelo = -collectionView.panGestureRecognizer.translation(in: collectionView.superview).x
        var xVeloMax : CGFloat = 0
        if (xVelo>xVeloMax){
            xVeloMax = xVelo
        }
        
        if(xVelo > 0 && xVelo==xVeloMax){
            if(currentPage == 0){
                currentPage = 1
            }else if(currentPage == 1){
                currentPage = 2
            }
        }
        else if(xVelo < 0){
            if(currentPage == 2){
                currentPage = 1
            }else if(currentPage == 1){
                currentPage = 0
            }
        }
    }
*/
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
            currentPage = Int(floor((offset - pageSide / 2) / pageSide) + 1)
        
        if(currentPage != 0){
            btnStart.isEnabled = false
        }else{
            btnStart.isEnabled = true
        }
        pageControl.currentPage = currentPage
        
        funFacts.text = funFactes[currentPage]
    }


    
    fileprivate var pageSize: CGSize {
        let layout = self.collectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        return pageSize
    }
}

extension CarouselViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! CollectionViewCell
        cell.layer.cornerRadius = 90
        cell.img.image = arrData[indexPath.row].image
        cell.lblTitle.text = arrData[indexPath.row].title
        cell.lblTitle.textColor = UIColor(displayP3Red: 1, green: 1, blue: 1, alpha: 0)
        return cell
    }
    
    @IBAction func myUnwindAction(unwindSegue: UIStoryboardSegue) {
        
    }
    
    
    
}
