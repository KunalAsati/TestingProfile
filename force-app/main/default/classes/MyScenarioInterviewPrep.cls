public class MyScenarioInterviewPrep {
    
    void processRecords(){
        
        List<Account> topAccounts = [SELECT Id, Name, (SELECT Id FROM Contacts) FROM Account ORDER BY Name DESC LIMIT 5];
        System.debug(topAccounts);
    }

}