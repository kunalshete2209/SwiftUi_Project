//
//  HabitTrackerTests.swift
//  HabitTrackerTests
//
//  Created by Kunal Shete on 02/04/25.
//

import XCTest
@testable import HabitTracker
import CoreData
import UserNotifications

class HabitTrackerTests: XCTestCase {
    var viewModel: HabitViewModel!
    var mockContext: NSManagedObjectContext!

    override func setUp() {
        super.setUp()
        
        let container = NSPersistentContainer(name: "HabitTracker")
        let description = NSPersistentStoreDescription()
        description.type = NSInMemoryStoreType
        container.persistentStoreDescriptions = [description]
        container.loadPersistentStores { _, error in
            XCTAssertNil(error, "Failed to load in-memory store")
        }
        mockContext = container.viewContext
        viewModel = HabitViewModel()
    }

    override func tearDown() {
        viewModel = nil
        mockContext = nil
        super.tearDown()
    }
    

    func testAddHabit() async {
        viewModel.title = "Morning Exercise"
        viewModel.habitColor = "Red"
        viewModel.weekDays = ["Monday", "Wednesday"]
        viewModel.isRemainderOn = true
        viewModel.remainderText = "Exercise Reminder"
        viewModel.remainderDate = Date()
        
        let success = await viewModel.addHabbit(context: mockContext)
        XCTAssertTrue(success, "Habit should be added successfully")
    }
    
    func testDeleteHabit() {
        let habit = Habit(context: mockContext)
        habit.title = "Test Habit"
        habit.isRemainderOn = true
        habit.notificationIDs = ["test_notification"]
        viewModel.editHabit = habit
        
        let success = viewModel.deleteHabit(context: mockContext)
        XCTAssertTrue(success, "Habit should be deleted successfully")
    }
    
    func testResetData() {
        viewModel.title = "Some Title"
        viewModel.habitColor = "Blue"
        viewModel.weekDays = ["Friday"]
        viewModel.isRemainderOn = true
        
        viewModel.resetData()
        
        XCTAssertEqual(viewModel.title, "", "Title should be reset")
        XCTAssertEqual(viewModel.habitColor, "Card-1", "Color should be reset")
        XCTAssertTrue(viewModel.weekDays.isEmpty, "Weekdays should be reset")
        XCTAssertFalse(viewModel.isRemainderOn, "Reminder should be turned off")
    }
    
    func testRestoreEditData() {
        let habit = Habit(context: mockContext)
        habit.title = "Edited Habit"
        habit.color = "Green"
        habit.weekDays = ["Tuesday"]
        habit.isRemainderOn = true
        habit.remainderText = "Test Reminder"
        habit.notificationDate = Date()
        
        viewModel.editHabit = habit
        viewModel.restoreEditData()
        
        XCTAssertEqual(viewModel.title, "Edited Habit")
        XCTAssertEqual(viewModel.habitColor, "Green")
        XCTAssertEqual(viewModel.weekDays, ["Tuesday"])
        XCTAssertTrue(viewModel.isRemainderOn)
        XCTAssertEqual(viewModel.remainderText, "Test Reminder")
    }
    
    func testDoneStatus() {
        viewModel.title = "Workout"
        viewModel.weekDays = ["Monday"]
        viewModel.isRemainderOn = true
        viewModel.remainderText = "Gym Reminder"
        
        XCTAssertTrue(viewModel.doneStatus(), "Done status should be true for a valid habit")
        
        viewModel.remainderText = ""
        XCTAssertFalse(viewModel.doneStatus(), "Done status should be false when reminder text is empty")
    }
    
    //markHabitAsDone
    func createMockHabit(title: String, weekDays: [String], lastCompletedDate: Date? = nil, streakCount: Int = 0) -> Habit {
          let habit = Habit(context: mockContext)
          habit.title = title
          habit.weekDays = weekDays
          habit.lastCompletedDate = lastCompletedDate
          habit.streakCount = Int16(streakCount)
          return habit
      }
      
      func testMarkHabitAsDone_Success() {
          let todayWeekday = Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1]
          let habit = createMockHabit(title: "Test Habit", weekDays: [todayWeekday])
          
          viewModel.markHabitAsDone(habit: habit)
          
          XCTAssertNotNil(habit.lastCompletedDate, "lastCompletedDate should not be nil")
          XCTAssertEqual(habit.streakCount, 1, "streakCount should be incremented")
      }
      
      func testMarkHabitAsDone_AlreadyCompletedToday() {
          let today = Calendar.current.startOfDay(for: Date())
          let todayWeekday = Calendar.current.weekdaySymbols[Calendar.current.component(.weekday, from: today) - 1]
          let habit = createMockHabit(title: "Test Habit", weekDays: [todayWeekday], lastCompletedDate: today, streakCount: 1)
          
          viewModel.markHabitAsDone(habit: habit)
          
          XCTAssertEqual(habit.streakCount, 1, "streakCount should not increment if already completed today")
      }
      
      func testMarkHabitAsDone_NotScheduledToday() {
          let habit = createMockHabit(title: "Test Habit", weekDays: ["Monday"])
          
          viewModel.markHabitAsDone(habit: habit)
          
          XCTAssertNil(habit.lastCompletedDate, "lastCompletedDate should remain nil")
          XCTAssertEqual(habit.streakCount, 0, "streakCount should not increment if not scheduled today")
      }
    
    
    
    
    // MARK: - Test UI Initialization
    func test_AddNewHabitView_InitialState() {
        XCTAssertEqual(viewModel.title, "", "Title should be empty initially")
        XCTAssertEqual(viewModel.weekDays.count, 0, "No weekdays should be selected initially")
        XCTAssertFalse(viewModel.isRemainderOn, "Reminder should be off initially")
    }
    
    // MARK: - Test Habit Color Selection
    func test_SelectHabitColor_ShouldChangeColor() {
        let color = "Card-3"
        viewModel.habitColor = color
        XCTAssertEqual(viewModel.habitColor, color, "Habit color should update correctly")
    }
    
    // MARK: - Test Weekday Selection
    func test_SelectWeekday_ShouldUpdateSelection() {
        let selectedDay = Calendar.current.weekdaySymbols.first ?? "Monday"
        viewModel.weekDays.append(selectedDay)
        
        XCTAssertTrue(viewModel.weekDays.contains(selectedDay), "Selected weekday should be added")
        
        // Deselect the day
        if let index = viewModel.weekDays.firstIndex(of: selectedDay) {
            viewModel.weekDays.remove(at: index)
        }
        XCTAssertFalse(viewModel.weekDays.contains(selectedDay), "Deselected weekday should be removed")
    }
    
    // MARK: - Test Reminder Toggle
    func test_ToggleReminder_ShouldUpdateState() {
        viewModel.isRemainderOn = true
        XCTAssertTrue(viewModel.isRemainderOn, "Reminder should be enabled")
        
        viewModel.isRemainderOn = false
        XCTAssertFalse(viewModel.isRemainderOn, "Reminder should be disabled")
    }
    
    // MARK: - Test Reminder Time Selection
    func test_UpdateReminderTime_ShouldSetNewTime() {
        let newDate = Calendar.current.date(byAdding: .hour, value: 2, to: Date())!
        viewModel.remainderDate = newDate
        XCTAssertEqual(viewModel.remainderDate, newDate, "Reminder date should update correctly")
    }
    
    // MARK: - Test Done Button Disabled When Required Fields Are Empty
    func test_DoneButton_ShouldBeDisabled_WhenTitleIsEmpty() {
        viewModel.title = ""
        XCTAssertFalse(viewModel.doneStatus(), "Done button should be disabled when title is empty")
        
    }
    
    //MARK: - Test Edge Case: Habit Scheduled on No Days
    func testMarkHabitAsDone_WithNoScheduledDays_ShouldNotUpdate() {
        let habit = createMockHabit(title: "Edge Habit", weekDays: [])
        
        viewModel.markHabitAsDone(habit: habit)
        
        XCTAssertNil(habit.lastCompletedDate, "Should not mark as done if no days scheduled")
        XCTAssertEqual(habit.streakCount, 0)
    }
    
    //MARK: - Test RestoreEditData for a Nil Habit
    func testRestoreEditData_WhenNil_ShouldNotCrash() {
        viewModel.editHabit = nil
        viewModel.restoreEditData()
        
        XCTAssertEqual(viewModel.title, "", "Should stay default if editHabit is nil")
    }

}
