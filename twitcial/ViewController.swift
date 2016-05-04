//
//  ViewController.swift
//  twitcial
//
//  Created by Tripathi, Roopesh on 12/04/16.
//  Copyright © 2016 Tripathi, Roopesh. All rights reserved.
//

import UIKit
import Social
import Accounts

struct HomeStatus {
    var text: String?
    var profileImageUrl: String?
    var name: String?
    var screenName: String?
}

var imageCache = NSCache()
let accounts = ACAccount()

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    var imageView: UIImageView!
    var image: UIImage?
    
    var pickerController:UIImagePickerController = UIImagePickerController()
    static let cellId = "cellId"
    
    var homeStatuses: [HomeStatus]?
    
    let twitter = STTwitterAPI.twitterAPIOSWithAccount(accounts)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let memoryCapacity = 500 * 1024 * 1024
        let diskCapacity   = 500 * 1024 * 1024
        
        let urlCache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "myDiskPath")
        
        NSURLCache.setSharedURLCache(urlCache)
        
        navigationItem.title = "Home"
        
        let post = UIBarButtonItem(title: "Tweet", style: .Done, target: self, action:Selector("postTweet") )
        
        
        navigationItem.rightBarButtonItem = post
        
        collectionView?.backgroundColor = UIColor.whiteColor()
        collectionView?.alwaysBounceVertical = true
        collectionView?.registerClass(StatusCell.self, forCellWithReuseIdentifier: ViewController.cellId)
        
        getHomeTimeLine()
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        self.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        postTweet()
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func getHomeTimeLine() {
        
        twitter.verifyCredentialsWithUserSuccessBlock({ (username, userId) -> Void in
            
            self.twitter.getHomeTimelineSinceID(nil, count: 20, successBlock: { (statuses) -> Void in
                
                print("HomeTimeLine",NSThread.isMainThread())
                
                self.homeStatuses = [HomeStatus]()
                
                for status in statuses {
                    let text = status["text"] as? String
                    
                    if let user = status["user"] as? NSDictionary {
                        let profileImage = user["profile_image_url_https"] as? String
                        let screenName = user["screen_name"] as? String
                        let name = user["name"] as? String
                        
                        self.homeStatuses?.append(HomeStatus(text: text, profileImageUrl: profileImage, name: name, screenName: screenName))
                    }
                }
                self.collectionView?.reloadData()
                
                }, errorBlock: { (error) -> Void in
                    print(error)
            })
            
            }) { (error) -> Void in
                print(error)
        }
    }
    
    func postImage() {
        pickerController.delegate = self
        pickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        
        
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    func postTweet() {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
            let twitterSheet:SLComposeViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
            twitterSheet.setInitialText("Share on Twitter")
            // twitterSheet.addImage(self.image!)
            
            twitterSheet.completionHandler = {
                result -> Void in
                
                let getResult = result
                
                switch(getResult.rawValue) {
                    
                case SLComposeViewControllerResult.Cancelled.rawValue:
                    print("Cancelled")
                    
                case SLComposeViewControllerResult.Done.rawValue:
                    self.getHomeTimeLine()
                    
                default:
                    print("Error!")
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            self.presentViewController(twitterSheet, animated: true, completion: nil)
        } else {
            let alert = UIAlertController(title: "Twitter Account ", message: "Please goto device setting and login in twitter account .", preferredStyle: UIAlertControllerStyle.ActionSheet)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let count = homeStatuses?.count {
            return count
        }
        return 0
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let statusCell = collectionView.dequeueReusableCellWithReuseIdentifier(ViewController.cellId, forIndexPath: indexPath) as! StatusCell
        
        if let homeStatus = self.homeStatuses?[indexPath.item] {
            statusCell.homeStatus = homeStatus
        }
        
        return statusCell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        
        if let homeStatus = self.homeStatuses?[indexPath.item] {
            if let name = homeStatus.name, screenName = homeStatus.screenName, text = homeStatus.text {
                let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
                
                attributedText.appendAttributedString(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)]))
                
                attributedText.appendAttributedString(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)]))
                
                let size = attributedText.boundingRectWithSize(CGSizeMake(view.frame.width - 80, 1000), options: NSStringDrawingOptions.UsesFontLeading.union(NSStringDrawingOptions.UsesLineFragmentOrigin), context: nil).size
                
                return CGSizeMake(view.frame.width, size.height + 20)
            }
        }
        
        return CGSizeMake(view.frame.width, 80)
    }
}

class StatusCell: UICollectionViewCell {
    
    var homeStatus: HomeStatus? {
        didSet {
            if let profileImageUrl = homeStatus?.profileImageUrl {
                
                if let name = homeStatus?.name, screenName = homeStatus?.screenName, text = homeStatus?.text {
                    let attributedText = NSMutableAttributedString(string: name, attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)])
                    
                    attributedText.appendAttributedString(NSAttributedString(string: "\n@\(screenName)", attributes: [NSFontAttributeName: UIFont.boldSystemFontOfSize(14)]))
                    
                    attributedText.appendAttributedString(NSAttributedString(string: "\n\(text)", attributes: [NSFontAttributeName: UIFont.systemFontOfSize(14)]))
                    
                    statusTextView.attributedText  = attributedText
                    
                }
                
                let url = NSURL(string: profileImageUrl)
                
                if let profileImageUrl = homeStatus?.profileImageUrl{
                    
                    if let image = imageCache.objectForKey(profileImageUrl) as? UIImage{
                        
                        self.profileImageView.image = image
                    }
                    else{
                        NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: { (data, response, error) -> Void in
                            
                            if error != nil {
                                print(error)
                                return
                            }
                            print(NSThread.isMainThread())
                            
                            let image = UIImage(data: data!)
                            
                            imageCache.setObject(image!, forKey: profileImageUrl)
                            
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.profileImageView.image = image
                                //                                print("loaded image")
                            })
                            
                        }).resume()
                    }
                }
                
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    let statusTextView: UITextView = {
        let textView = UITextView()
        textView.editable = false
        return textView
    }()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .ScaleAspectFit
        return imageView
    }()
    
    let dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        return view
    }()
    
    func setupViews() {
        addSubview(statusTextView)
        addSubview(dividerView)
        addSubview(profileImageView)
        
        // constraints for statusTextView
        addConstraintsWithFormat("H:|-8-[v0(48)]-8-[v1]|", views: profileImageView, statusTextView)
        
        addConstraintsWithFormat("V:|[v0]|", views: statusTextView)
        
        addConstraintsWithFormat("V:|-8-[v0(48)]", views: profileImageView)
        
        // constraints for dividerView
        addConstraintsWithFormat("H:|-8-[v0]|", views: dividerView)
        addConstraintsWithFormat("V:[v0(1)]|", views: dividerView)
    }
}

extension UIView {
    func addConstraintsWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            viewsDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
    }
}

