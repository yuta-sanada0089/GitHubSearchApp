//
//  MasterViewController.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/02.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var objects = [Any]()
    var repositories: [Repository] = []{
        didSet{
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        LogUtil.traceFunc()
    
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(insertNewObject(_:)))
        
        navigationItem.rightBarButtonItem = addButton
        
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
        }
        
        let _ = SearchRepositories(searchQuery: "Hatena", page: 0).request(session: URLSession.shared) { (result) in
            switch result {
                case .Success(let searchResult):
                    LogUtil.debug("Success ---------")
                    for item in searchResult.items{
                        LogUtil.debug(item.description ?? "<description not set>")
                    }
                
                    DispatchQueue.main.async {
                        LogUtil.debug("going to append \(searchResult.items).")
                        self.repositories.append(contentsOf: searchResult.items)
                    }
            case .Failure(let error):
                LogUtil.debug("Failure---------")
                LogUtil.error(error)
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        LogUtil.traceFunc()
        
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    override func didReceiveMemoryWarning() {
        LogUtil.traceFunc()
        
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    func insertNewObject(_ sender: Any) {
        LogUtil.traceFunc()
        
        objects.insert(NSDate(), at: 0)
        let indexPath = IndexPath(row: 0, section: 0)
        tableView.insertRows(at: [indexPath], with: .automatic)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        LogUtil.traceFunc(params: ["segue" : segue.identifier!, "sender": sender!])
        
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let repository = repositories[indexPath.row]
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                
                controller.repository = repository
                
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        LogUtil.traceFunc()
        LogUtil.debug("always 1")
        
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LogUtil.traceFunc(params: ["section": section])
        LogUtil.debug(objects.count.description)
        
        return repositories.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        LogUtil.traceFunc(params: ["cellForRowAt": indexPath])
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)

        let repository = repositories[indexPath.row]
        cell.textLabel!.text = repository.name
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        LogUtil.traceFunc(params: ["canEditRowAt" : indexPath])
        LogUtil.debug("always return true")
        
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            LogUtil.debug("EditingStyle : delete")
            objects.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            LogUtil.debug("EditingStyle : insert")
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }


}

