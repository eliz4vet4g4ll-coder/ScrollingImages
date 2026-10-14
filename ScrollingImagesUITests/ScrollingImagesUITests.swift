import XCTest

final class ScrollingImagesUITests: XCTestCase {
    private let email: String = "email"
    private let pass: String = "password"
    private let app = XCUIApplication()

    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так

        app.launch() // запускаем приложение перед каждым тестом
    }

    func testAuth() throws {
        app.buttons[AccessibilityIdentifiers.authenticateButton].tap()

        let webView = app.webViews[AccessibilityIdentifiers.unsplashWebView]

        XCTAssertTrue(webView.waitForExistence(timeout: 5))

        let loginTextField = webView.descendants(matching: .textField).element
        XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))

        loginTextField.tap()
        loginTextField.typeText(email)
        webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)).tap()

        let passwordTextField = webView.descendants(matching: .secureTextField).element
        XCTAssertTrue(passwordTextField.waitForExistence(timeout: 5))

        passwordTextField.tap()
        passwordTextField.typeText(pass)
        webView.swipeUp()

        webView.buttons["Login"].tap()

        let tablesQuery = app.tables
        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)

        XCTAssertTrue(cell.waitForExistence(timeout: 10))
    }

    func testFeed() throws {
        // тестируем сценарий ленты
        let tablesQuery = app.tables

        let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
        cell.swipeUp()

        XCTAssertTrue(tablesQuery.children(matching: .cell).element(boundBy: 1).waitForExistence(timeout: 5))

        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)

        cellToLike.buttons[AccessibilityIdentifiers.likeButtonOff].tap()
        cellToLike.buttons[AccessibilityIdentifiers.likeButtonOn].tap()

        wait(for: [XCTNSPredicateExpectation(predicate: NSPredicate(format: "isHittable == true"), object: cellToLike.buttons[AccessibilityIdentifiers.likeButtonOff])], timeout: 10)

        cellToLike.tap()

        XCTAssertTrue(app.scrollViews.images.element(boundBy: 0).waitForExistence(timeout: 10))

        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)

        let navBackButtonWhiteButton = app.buttons[AccessibilityIdentifiers.navBackButton]
        navBackButtonWhiteButton.tap()
    }

    func testProfile() throws {
        // тестируем сценарий профиля
        let profileTab = app.tabBars.buttons.element(boundBy: 1)
        XCTAssertTrue(profileTab.waitForExistence(timeout: 10))
        profileTab.tap()

        XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.nameLabel].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts[AccessibilityIdentifiers.userNameLabel].exists)
        XCTAssertTrue(app.buttons[AccessibilityIdentifiers.profileImage].exists)

        app.buttons[AccessibilityIdentifiers.logoutButton].tap()
        app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()

        let authenticateButton = app.buttons[AccessibilityIdentifiers.authenticateButton]
        XCTAssertTrue(authenticateButton.waitForExistence(timeout: 5))
    }
}
