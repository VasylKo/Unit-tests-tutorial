//
//  PeopleListDataProviderTests.swift
//  Birthdays
//
//  Created by Vasyl Kotsiuba on 10/30/15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import XCTest
@testable import Birthdays
import CoreData

class PeopleListDataProviderTests: XCTestCase {
    
    var storeCoordinator: NSPersistentStoreCoordinator!
    var managedObjectContext: NSManagedObjectContext!
    var managedObjectModel: NSManagedObjectModel!
    var store: NSPersistentStore!
    
    var dataProvider: PeopleListDataProvider!
    
    var tableView: UITableView!
    var testRecord: PersonInfo!
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        managedObjectModel = NSManagedObjectModel.mergedModelFromBundles(nil)
        storeCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
        
        do {
            try  store = storeCoordinator.addPersistentStoreWithType(NSInMemoryStoreType,
                configuration: nil, URL: nil, options: nil)
        } catch var error1 as NSError {}
       
        
        managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = storeCoordinator
        
        // 2
        dataProvider = PeopleListDataProvider()
        dataProvider.managedObjectContext = managedObjectContext
        
        
        let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
        viewController.dataProvider = dataProvider
        
        tableView = viewController.tableView
        
        testRecord = PersonInfo(firstName: "TestFirstName", lastName: "TestLastName", birthday: NSDate())
    }
    
    
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        managedObjectContext = nil
        

        do {
            try storeCoordinator.removePersistentStore(store)
        } catch let error1 as NSError {
            XCTAssert(true,
                "couldn't remove persistent store: \(error1)")
        }
        super.tearDown()
    }
    
    func testThatStoreIsSetUp() {
        XCTAssertNotNil(store, "no persistent store")
    }
    
    func testOnePersonInThePersistantStoreResultsInOneRow() {
        dataProvider.addPerson(testRecord)
        
        XCTAssertEqual(tableView.dataSource!.tableView(tableView, numberOfRowsInSection: 0), 1,
            "After adding one person number of rows is not 1")
    }
    
}
