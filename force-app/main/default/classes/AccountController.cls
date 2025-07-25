public with sharing class AccountController {

    @AuraEnabled(cacheable=true)
    public static List<Account> FetchHotAccounts(){
        return [SELECT Id, Name, Website, Industry FROM Account WHERE Rating='Hot'];

    }
}