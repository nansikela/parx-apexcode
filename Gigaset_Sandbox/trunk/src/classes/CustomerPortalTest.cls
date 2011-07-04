@isTest
private class CustomerPortalTest{

    static testMethod void myUnitTest() {
        CustomerPortalTestController ctrl = new CustomerPortalTestController();
        
        ctrl.sortField1 = 'Name';
        ctrl.SortProducts();
        ctrl.SortProducts();
        
        ctrl.sortField2 = 'Name';
        ctrl.SortCases();
        ctrl.SortCases();
     
        ctrl.sortField3= 'SolutionName';
        ctrl.SortSolutions();
        ctrl.SortSolutions();
        
        ctrl.sortField4 = 'Name';
        ctrl.SortIdeas();
        ctrl.SortIdeas();
    }
}