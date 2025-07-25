import { LightningElement, track } from 'lwc';
import getPassengerData from '@salesforce/apex/DashboardController.getPassengerData';
import getFlightData from '@salesforce/apex/DashboardController.getFlightData';
import getCrewMemberData from '@salesforce/apex/DashboardController.getCrewMemberData';
import getFlightOptions from '@salesforce/apex/DashboardController.getFlightOptions';
import getCrewMemberOptions from '@salesforce/apex/DashboardController.getCrewMemberOptions';
import { NavigationMixin } from 'lightning/navigation';

export default class FlightData extends NavigationMixin(LightningElement) {
    @track flightNumberOptions = [];
    @track crewMemberNameOptions = []; 
    @track passengerData = []; 
    @track flightData = []; 
    @track crewMemberData = []; 

    @track passengerColumns = [
        { label: 'Passenger Name', fieldName: 'Name' },
        { label: 'Country', fieldName: 'Country__c' },
        { label: 'Passport Number', fieldName: 'Passport__c' }
    ];
    @track flightColumns = [
        { label: 'Flight Number', fieldName: 'Name' },
        { label: 'Origin', fieldName: 'Origin__c' },
        { label: 'Departure', fieldName: 'Departure__c' },
        { label: 'Destination', fieldName: 'Destination__c' },
        { label: 'Arrival', fieldName: 'Arrival__c' },
        { label: 'Passenger Count', fieldName: 'Passenger_Count__c' }

    ];

    @track crewColumns = [
        { label: 'Crew Member Name', fieldName: 'Name' },
        { label: 'Flight Number', fieldName: 'Flight_NumberName' },
        { label: 'Passenger Count', fieldName: 'Passenger_Count__c' }
    ];
    @track flightNumber = '';
    @track crewMemberName = '';

    connectedCallback() {

        

        getFlightOptions().then(result => {
            this.flightNumberOptions = result.map(flight => {
                return { value: flight.Name, label: flight.Name };
            });

        });
        getCrewMemberOptions().then(result => {
            this.crewMemberNameOptions = result.map(crew => {
                return { value: crew.Name, label: crew.Name };
            });
        });

        getCrewMemberData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.crewMemberData = result.map(crew => {
                return { Name: crew.Name, 
                    Flight_NumberName: crew.Flight_Number__r.Name,
                    Passenger_Count__c: crew.Passenger_Count__c,
                    Id: crew.Id
                 };
            });

        });
        getFlightData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.flightData = result;
        });
        getPassengerData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.passengerData = result;

        });
    }
    

    handleFlightNumberChange(event) {

        this.flightNumber = event.detail.value;
        this.crewMemberName='';
    }

    handleCrewMemberNameChange(event) {

        this.crewMemberName = event.detail.value;
        this.flightNumber='';
    }

    handleSearch(){

        getCrewMemberData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.crewMemberData = result.map(crew => {
                return { Name: crew.Name, 
                    Flight_NumberName: crew.Flight_Number__r.Name,
                    Passenger_Count__c: crew.Passenger_Count__c,
                    Id: crew.Id
                 };
            });

        });
        getFlightData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.flightData = result;
        });

        getPassengerData({'flightNumber':this.flightNumber,'crewMemberName': this.crewMemberName}).then(result => {
            this.passengerData = result;
        });
    }

    handleRowSelection(event){
        const selectedRows = event.detail.selectedRows;
        if (selectedRows.length > 0) {
            console.log('selectedRows[0].Id',selectedRows);
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: selectedRows[0].Id,
                    actionName: 'view'
                }
            });
        }
    }

    
}