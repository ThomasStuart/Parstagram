//
//  FeedViewController.swift
//  Parstagram
//
//  Created by Thomas James Stuart on 4/6/19.
//  Copyright © 2019 Thomas James Stuart. All rights reserved.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MessageInputBarDelegate {

    //var refreshControl: UIRefreshControl!
    var posts = [PFObject]()
    @IBOutlet weak var tableView: UITableView!
    var commentBar = MessageInputBar()
    var showsCommentBar = false
    var selecetedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self, selector: #selector(keyboardWillBeHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
       
        let comment = PFObject(className: "Comments")
         comment["text"] = text
         comment["post"] = selecetedPost;
         comment["author"] = PFUser.current()!
         
         selecetedPost.add(comment, forKey: "comments")
         
         selecetedPost.saveInBackground {  (success, error ) in
         
         if( success ){
         print("comment save")
         }
         else{
         print("Error saving comment ")
         }
         }
        
        tableView.reloadData()
         //clear and dissmiss the input
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()

    }
    
    @objc func keyboardWillBeHidden(note: Notification ){
        commentBar.inputTextView.text = nil
        showsCommentBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView?{
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool{
        return showsCommentBar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className:"Posts")
        query.includeKeys( ["author", "comments", "comments.author"] )
        query.limit = 20
        
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil{
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
        
        
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      let post = posts[section]
      let comments = ( post["comments"] as? [PFObject]) ?? []
        
      return comments.count+2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.section]
        let comments = ( post["comments"] as? [PFObject]) ?? []
       
        if (indexPath.row == 0){
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            let user = post["author"] as! PFUser
        
            cell.usernameLabel.text = user.username
            cell.captionLabel.text = post["caption"] as! String
        
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)!
        
            cell.photoView.af_setImage(withURL: url)
        
            return cell
        }
        else if ( indexPath.row <= comments.count ){
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            let comment = comments[indexPath.row - 1]
            
            cell.commentLabel.text = comment["text"] as? String
            
            let user = comment["author"] as! PFUser
            cell.userLabel.text = user.username
            
            return cell;
        }
        else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        let comment = PFObject(className: "Comments")
        let comments = ( post["comments"] as? [PFObject]) ?? []
        
        if( indexPath.row == comments.count + 1 ){
            showsCommentBar = true;
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selecetedPost = post
            
        }
        
        
    }
    
    
    
    
    @IBAction func onLogout(_ sender: Any) {
      PFUser.logOut()
    
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(withIdentifier: "LoginViewController")
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        
        delegate.window?.rootViewController = loginViewController
        
    }
    
    
    /*@objc func onRefresh() {
        refresh()
    }
    
    // Implement the delay method
    func run(after wait: TimeInterval, closure: @escaping () -> Void) {
        let queue = DispatchQueue.main
        queue.asyncAfter(deadline: DispatchTime.now() + wait, execute: closure)
    }
    
    // Call the delay method in your onRefresh() method
    func refresh() {
        run(after: 2) {
            self.refreshControl.endRefreshing()
        }
    }*/

}
