@isTest
private class WebSeminarKategorieControllerTest {

    static testMethod void myUnitTest() {
       WebSeminarKategorieController w = new WebSeminarKategorieController();
       WebSeminarKategorieController.portfolioKategorienList = WebSeminarKategorieController.getAllRegister();
    }
}