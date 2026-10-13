import XCTest

class Image_FeedUITests: XCTestCase {
    let email: String = "your email"
    let pass: String = "your password"
    private let app = XCUIApplication() // переменная приложения
    
    override func setUpWithError() throws {
        continueAfterFailure = false // настройка выполнения тестов, которая прекратит выполнения тестов, если в тесте что-то пошло не так
        
        app.launch() // запускаем приложение перед каждым тестом
    }
    
func testAuth() throws {
    app.buttons["Authenticate"].tap()
    
    let webView = app.webViews["UnsplashWebView"]
    
    XCTAssertTrue(webView.waitForExistence(timeout: 5))

    let loginTextField = webView.descendants(matching: .textField).element
    XCTAssertTrue(loginTextField.waitForExistence(timeout: 5))
    
    loginTextField.tap()
    loginTextField.typeText(email)
    webView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05)).tap()
    // webView.swipeUp()
    
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
        
        sleep(2)
        
        let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
        
        cellToLike.buttons["like button off"].tap()
        cellToLike.buttons["like button on"].tap()
        
        sleep(2)
        
        cellToLike.tap()
        
        sleep(2)
        
        let image = app.scrollViews.images.element(boundBy: 0)
        // Zoom in
        image.pinch(withScale: 3, velocity: 1) // zoom in
        // Zoom out
        image.pinch(withScale: 0.5, velocity: -1)
        
        let navBackButtonWhiteButton = app.buttons["nav back button white"]
        navBackButtonWhiteButton.tap()
    }
    
    func testProfile() throws {
        // тестируем сценарий профиля
        sleep(3)
            app.tabBars.buttons.element(boundBy: 1).tap()
           
            XCTAssertTrue(app.staticTexts["Name Lastname"].exists)
            XCTAssertTrue(app.staticTexts["@username"].exists)
            
            app.buttons["logout button"].tap()
            
            app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
    }
}
