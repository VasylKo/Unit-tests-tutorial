//
//  PeopleListViewControllerTests.swift
//  Birthdays
//
//  Created by Vasyl Kotsiuba on 10/30/15.
//  Copyright © 2015 Dominik Hauser. All rights reserved.
//

import XCTest
import UIKit
import CoreData
import AddressBookUI
@testable import Birthdays



class PeopleListViewControllerTests: XCTestCase {
    
    class MockDataProvider: NSObject, PeopleListDataProviderProtocol {
        
        var managedObjectContext: NSManagedObjectContext?
        weak var tableView: UITableView!
        var addPersonGotCalled = false
        
        func addPerson(personInfo: PersonInfo) { addPersonGotCalled = true}
        func fetch() { }
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 1 }
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            return UITableViewCell()
        }
    }
    
    class MockUserDefaults: NSUserDefaults {
        var sortWasChanged = false
        override func setInteger(value: Int, forKey defaultName: String) {
            if defaultName == "sort" {
                sortWasChanged = true
            }
        }
    }
    
    class MockAPICommunicator: APICommunicatorProtocol {
        var allPersonInfo = [PersonInfo]()
        var postPersonGotCalled = false
        
        // 2
        func getPeople() -> (NSError?, [PersonInfo]?) {
            return (nil, allPersonInfo)
        }
        
        // 3
        func postPerson(personInfo: PersonInfo) -> NSError? {
            postPersonGotCalled = true
            return nil
        }
    }

    
    var viewController: PeopleListViewController!
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        //viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
        
        viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("PeopleListViewController") as! PeopleListViewController
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    
    func testDataProviderHasTableViewPropertySetAfterLoading() {
        // given
        // 1
        let mockDataProvider = MockDataProvider()
        
        viewController.dataProvider = mockDataProvider
        
        // when
        // 2
        XCTAssertNil(mockDataProvider.tableView, "Before loading the table view should be nil")
        
        // 3
        let _ = viewController.view
        
        // then
        // 4
        XCTAssertTrue(mockDataProvider.tableView != nil, "The table view should be set")
        XCTAssert(mockDataProvider.tableView === viewController.tableView,
            "The table view should be set to the table view of the data source")
    }
    
    func testCallsAddPersonOfThePeopleDataSourceAfterAddingAPersion() {
        // given
        let mockDataSource = MockDataProvider()
        
        // 1
        viewController.dataProvider = mockDataSource
        
        // when
        // 2
        let record: ABRecord = ABPersonCreate().takeRetainedValue()
        ABRecordSetValue(record, kABPersonFirstNameProperty, "TestFirstname", nil)
        ABRecordSetValue(record, kABPersonLastNameProperty, "TestLastname", nil)
        ABRecordSetValue(record, kABPersonBirthdayProperty, NSDate(), nil)
        
        // 3
        viewController.peoplePickerNavigationController(ABPeoplePickerNavigationController(),
            didSelectPerson: record)
        
        // then
        // 4
        XCTAssert(mockDataSource.addPersonGotCalled, "addPerson should have been called")
    }
    
    func testSortingCanBeChanged() {
        // given
        // 1
        let mockUserDefaults = MockUserDefaults(suiteName: "testing")!
        viewController.userDefaults = mockUserDefaults
        
        // when
        // 2
        let segmentedControl = UISegmentedControl()
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(viewController, action: "changeSorting:", forControlEvents: .ValueChanged)
        segmentedControl.sendActionsForControlEvents(.ValueChanged)
        
        // then
        // 3
        XCTAssertTrue(mockUserDefaults.sortWasChanged, "Sort value in user defaults should be altered")
    }
    
    func testFetchingPeopleFromAPICallsAddPeople() {
        // given
        // 1
        let mockDataProvider = MockDataProvider()
        viewController.dataProvider = mockDataProvider
        
        // 2
        let mockCommunicator = MockAPICommunicator()
        mockCommunicator.allPersonInfo = [PersonInfo(firstName: "firstname", lastName: "lastname",
            birthday: NSDate())]
        viewController.communicator = mockCommunicator
        
        // when
        viewController.fetchPeopleFromAPI()
        
        // then
        // 3
        XCTAssert(mockDataProvider.addPersonGotCalled, "addPerson should have been called")
    }
    
}
