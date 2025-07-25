public class AccountSavecls
{
    public Account actObj{
        get;
        set;
    }
    public AccountSavecls(){
    	actObj=new Account ();
    }
    public pagereference saveAccount(){
        insert actObj;
        return new pagereference('/'+actObj.Id);
    }
}