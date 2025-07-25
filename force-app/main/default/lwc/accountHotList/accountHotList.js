import { LightningElement , wire} from 'lwc';
import FetchHotAccounts from '@salesforce/apex/AccountController.FetchHotAccounts';


export default class AccountHotList extends LightningElement {

    @wire(FetchHotAccounts) accounts;

}