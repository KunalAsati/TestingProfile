public class AccountCalculator {

    @future
    public static void countContacts(List<Id> accIds){
        List<Account> accList = [Select Id, (Select Id from Contacts) from Account where Id IN:accIds];
        for(Account a: accList){
            a.Number_of_Contacts__c = a.Contacts.size();
            System.debug(a);

        }
        
        if(!accList.isEmpty()){
            update accList;
        }
    }
}