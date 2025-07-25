public class AssignClass {

    List<Account> accnt;
    List<Lead> lead;
    List<Contact> contact;
    
    public List<Account> getAccnt(){
        accnt = Database.query('select Name,AccountNumber from Account'); 
        return accnt;
    }
    public List<Lead> getLead(){
        lead = Database.query('select * from Lead'); 
        return lead;
    }
    public List<Contact> getContact(){
        contact = Database.query('select FirstName ,LastName  from Contact'); 
        return contact;
    }
}