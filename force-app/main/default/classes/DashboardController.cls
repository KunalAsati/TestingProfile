public with sharing class DashboardController {

    
    @AuraEnabled(cacheable=true)
    public static List<Passenger__c> getPassengerData(String flightNumber, String crewMemberName){

        List<Passenger__c> pass = new List<Passenger__c>();
        List<Assignment__c> assignment = new List<Assignment__c>();
        List<Booking__c> booking = new List<Booking__c>();
        if (Schema.sObjectType.Passenger__c.isAccessible() ){
            if(flightNumber != ''){
                booking = [SELECT Passenger__c from Booking__c where Flight__r.Name =:flightNumber];
                Set<Id> bookingSet = new Set<Id>();
                for(Booking__c book : booking){
                    bookingSet.add(book.Passenger__c);
                }
                pass = [SELECT Name, Country__c, Address__c, Passport__c from Passenger__c where Id in :bookingSet order by Name asc];
            }
            else if(crewMemberName != ''){
                assignment = [SELECT Passenger__c from Assignment__c where Crew_Member__r.Name=:crewMemberName];

                Set<Id> assignmentSet = new Set<Id>();
                for(Assignment__c assign : assignment){
                    assignmentSet.add(assign.Passenger__c);
                }
                pass = [SELECT Name, Country__c, Address__c, Passport__c from Passenger__c where Id in :assignmentSet order by Name asc];
            }
            else{
                pass = [SELECT Name, Country__c, Address__c, Passport__c from Passenger__c order by Name asc];
            }
        }
        return pass;
    }

    @AuraEnabled(cacheable=true)
    public static List<Flight__c> getFlightData(String flightNumber, String crewMemberName){

        List<Flight__c> flight = new List<Flight__c>();
        if (Schema.sObjectType.Flight__c.isAccessible() && Schema.sObjectType.Crew_Member__c.isAccessible()){
            if(flightNumber != ''){
                flight = [SELECT Name,Origin__c,Departure__c, Destination__c, Arrival__c, Passenger_Count__c from Flight__c where Name=:flightNumber order by Name asc];
            }
            else if(crewMemberName != ''){
                flight = [SELECT Name,Origin__c,Departure__c, Destination__c, Arrival__c, Passenger_Count__c from Flight__c where Id in (SELECT Flight_Number__c from Crew_Member__c where Name=:crewMemberName) order by Name asc];
            }
            else{
                flight = [SELECT Name,Origin__c,Departure__c, Destination__c, Arrival__c, Passenger_Count__c from Flight__c order by Name asc];
            }
        }
        return flight;
    }

    @AuraEnabled(cacheable=true)
    public static List<Crew_Member__c> getCrewMemberData(String flightNumber, String crewMemberName){

        List<Crew_Member__c> crewMember = new List<Crew_Member__c>();
        if (Schema.sObjectType.Crew_Member__c.isAccessible() ){
            if(flightNumber != '')
                crewMember = [SELECT Name, Flight_Number__r.Name, Passenger_Count__c from Crew_Member__c where Flight_Number__r.Name=:flightNumber order by Name asc];
            else if(crewMemberName != '')
                crewMember = [SELECT Name, Flight_Number__r.Name, Passenger_Count__c from Crew_Member__c where Name=:crewMemberName order by Name asc];
            else
                crewMember = [SELECT Name, Flight_Number__r.Name, Passenger_Count__c from Crew_Member__c order by Name asc];
        }
        return crewMember;
    }

    @AuraEnabled(cacheable=true)
    public static List<Flight__c> getFlightOptions(){

        List<Flight__c> flight = new List<Flight__c>();
        if (Schema.sObjectType.Flight__c.isAccessible()){
            flight = [Select name from Flight__c order by name asc];
        }
        return flight;
    }

    @AuraEnabled(cacheable=true)
    public static List<Crew_Member__c> getCrewMemberOptions(){

        List<Crew_Member__c> crewMember = new List<Crew_Member__c>();
        if (Schema.sObjectType.Crew_Member__c.isAccessible()){
            crewMember = [Select name from Crew_Member__c order by name asc];
        }
        return crewMember;
    }
}