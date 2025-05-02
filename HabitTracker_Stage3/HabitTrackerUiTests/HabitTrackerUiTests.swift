//
//  HabitTrackerUiTests.swift
//  HabitTrackerUiTests
//
//  Created by Kunal Shete on 11/04/25.
//

import XCTest

final class HabitTrackerUiTests: XCTestCase {

    var app: XCUIApplication!

    override class var runsForEachTargetApplicationUIConfiguration: Bool {
        true
    }

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - UI Test Cases

    @MainActor
    func testHabitTitleEntry() {
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3))

        addHabitButton.tap()

        let titleTextField = app.textFields["habitTitleTextField"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 3))

        titleTextField.tap()
        titleTextField.typeText("Workout")
        XCTAssertEqual(titleTextField.value as? String, "Workout")
    }



    func testColorPickerSelection() {
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3))
        addHabitButton.tap()
        
        let colorToSelect = "Card-3"
        let colorCircle = app.otherElements["colorPicker_\(colorToSelect)"]
        XCTAssertTrue(colorCircle.waitForExistence(timeout: 3), "\(colorToSelect) circle not found")
        colorCircle.tap()

    }


    func testFrequencySelection() {
        // Tap the "Add Habit" button
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "Add Habit button not found")
        addHabitButton.tap()
        
        // Tap on the "Mo" (Monday) frequency button
        let mondayButton = app.staticTexts["Mo"]
        XCTAssertTrue(mondayButton.waitForExistence(timeout: 3), "Monday button not found")
        mondayButton.tap()
    }


    func testReminderToggleAndTextEntryOnly() {
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "Add Habit button not found")
        addHabitButton.tap()

        let toggle = app.switches["remainderToggle"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 3), "Remainder toggle not found")
        toggle.tap()

        let textField = app.textFields["remainderTextField"]
        XCTAssertTrue(textField.waitForExistence(timeout: 3), "Remainder text field not found")
        textField.tap()
        textField.typeText("Drink Water Reminder")

        XCTAssertEqual(textField.value as? String, "Drink Water Reminder")
    }

    func testCancelButton() {
        // Tap the Add Habit button to present the screen
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "Add Habit button not found")
        addHabitButton.tap()

        // Tap the Cancel button
        let cancelButton = app.buttons["cancelButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3), "Cancel button not found")
        cancelButton.tap()
        
        // Optional: Verify the add habit screen is dismissed
        XCTAssertFalse(cancelButton.exists, "Cancel button should not exist after dismissal")
    }

    func testDoneButtonDisabledInitially() {
        // Tap the "Add Habit" button
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "Add Habit button not found")
        addHabitButton.tap()

        // Reference to Done button
        let doneButton = app.buttons["doneButton"]
        XCTAssertTrue(doneButton.exists, "Done button should exist")
        XCTAssertFalse(doneButton.isEnabled, "Done button should be disabled initially")

        // Fill habit title text field
        let titleTextField = app.textFields["habitTitleTextField"]
        XCTAssertTrue(titleTextField.waitForExistence(timeout: 3), "Habit title text field not found")
        titleTextField.tap()
        titleTextField.typeText("Workout")

        // Still should be disabled after only title
        XCTAssertFalse(doneButton.isEnabled, "Done button should still be disabled after only entering title")

        // Select Monday (Mo)
        let mondayButton = app.staticTexts["Mo"]
        XCTAssertTrue(mondayButton.waitForExistence(timeout: 3), "Monday button not found")
        mondayButton.tap()

        // Now done button should be enabled
        XCTAssertTrue(doneButton.isEnabled, "Done button should be enabled after entering title and selecting a frequency")
    }

    func testThemeToggleSwitchesModes() {
        let themeToggleButton = app.buttons["themeToggleButton"]
        
        // Wait until theme toggle button appears
        XCTAssertTrue(themeToggleButton.waitForExistence(timeout: 3), "Theme toggle button not found")
        
        // Capture initial state (light or dark icon)
        let initialIcon = themeToggleButton.label
        
        // Tap to toggle theme
        themeToggleButton.tap()
        sleep(1) // Give UI time to update

        // After toggling, the icon should change
        let updatedIcon = themeToggleButton.label
        XCTAssertNotEqual(initialIcon, updatedIcon, "Theme toggle did not change the icon")
    }
    
    func testAddHabitFlowSuccessfullyAddsHabit() {
        let habitTitle = "Climbing Mount Everest"

        // 1. Tap on 'Add Habit' button
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "Add Habit button not found")
        addHabitButton.tap()
        
        // 2. Enter habit title
        let habitTitleTextField = app.textFields["habitTitleTextField"]
        XCTAssertTrue(habitTitleTextField.waitForExistence(timeout: 3), "Habit title text field not found")
        habitTitleTextField.tap()
        habitTitleTextField.typeText(habitTitle)
        
        // 3. Choose a color (e.g., Card-1)
        let colorToSelect = "Card-3"
        let colorCircle = app.otherElements["colorPicker_\(colorToSelect)"]
        XCTAssertTrue(colorCircle.waitForExistence(timeout: 3), "\(colorToSelect) circle not found")
        colorCircle.tap()


        // 4. Select days (e.g., Mo, Tu, We)
        let mon = app.staticTexts["Mo"]
        let tue = app.staticTexts["Tu"]
        XCTAssertTrue(mon.exists && tue.exists)
        mon.tap()
        tue.tap()

        // 5. Done button should be enabled now
        let doneButton = app.buttons["doneButton"]
        XCTAssertTrue(doneButton.waitForExistence(timeout: 3), "Done button not found")
        XCTAssertTrue(doneButton.isEnabled, "Done button should be enabled when all fields are filled")

        // 6. Tap Done to save the habit
        doneButton.tap()

    }

    func testDeleteHabitDismissesView() {
        // Step 1: Tap the first Habit Card
        let allHabitCards = app.otherElements.matching(identifier: "habitCard")
        XCTAssertGreaterThan(allHabitCards.count, 0, "No habit cards found")
        
        let firstHabitCard = allHabitCards.element(boundBy: 0)
        XCTAssertTrue(firstHabitCard.waitForExistence(timeout: 3), "First habit card not found")
        firstHabitCard.tap()
        
        // Step 2: Tap the delete/trash button
        let deleteButton = app.buttons["deleteHabitButton"]
        XCTAssertTrue(deleteButton.waitForExistence(timeout: 3), "Delete button not found")
        deleteButton.tap()
        
        // Step 3: Wait for the screen to dismiss and Add Habit button to reappear
        let addHabitButton = app.buttons["addHabitButton"]
        XCTAssertTrue(addHabitButton.waitForExistence(timeout: 3), "View did not dismiss after deleting the habit")
    }


}

