trigger BookingTrigger on Booking__c (after insert) {
    Set<Id> flightIds = new Set<Id>();

    for (Booking__c booking : Trigger.new) {
        flightIds.add(booking.Flight__c);
    }

    List<Flight__c> flightsToUpdate = [SELECT Id, (SELECT Id FROM Bookings__r) FROM Flight__c WHERE Id IN :flightIds];

    for (Flight__c flight : flightsToUpdate) {
        flight.Passenger_Count__c = flight.Bookings__r.size();
    }

    update flightsToUpdate;
}