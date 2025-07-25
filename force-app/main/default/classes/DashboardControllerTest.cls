@isTest
public class DashboardControllerTest {
    @isTest
    static void testDashboardController() {

        Flight__c testFlight = new Flight__c(Origin__c='Delhi - DEL', Destination__c='Hyderabad - HYD', Departure__c=DateTime.valueOf('2024-06-06 06:30:00'), Arrival__c=DateTime.valueOf('2024-06-06 08:00:00'));

        insert testFlight;

        Crew_Member__c testCrewMember = new Crew_Member__c(Name='TestCrewMember', Flight_Number__c=testFlight.Id);
        insert testCrewMember;

        Passenger__c testPassenger = new Passenger__c(Name='TestPassenger');
        insert testPassenger;

        Booking__c testBooking = new Booking__c(Flight__c=testFlight.Id, Passenger__c=testPassenger.Id);
        insert testBooking;

        Assignment__c testAssignment = new Assignment__c(Crew_Member__c=testCrewMember.Id, Passenger__c=testPassenger.Id);
        insert testAssignment;

        Test.startTest();
        Flight__c fc = [Select Name from Flight__c where Id = :testFlight.Id];
        List<Passenger__c> passengers1 = DashboardController.getPassengerData(fc.Name, '');
        System.assertEquals(1, passengers1.size());

        List<Passenger__c> passengers2 = DashboardController.getPassengerData('', 'TestCrewMember');
        System.assertEquals(1, passengers2.size());

        List<Passenger__c> passengers3 = DashboardController.getPassengerData('', '');
        System.assertEquals(1, passengers3.size());

        // Test getFlightData method
        List<Flight__c> flights1 = DashboardController.getFlightData(fc.Name, '');
        System.assertEquals(1, flights1.size());

        List<Flight__c> flights2 = DashboardController.getFlightData('', 'TestCrewMember');
        System.assertEquals(1, flights2.size());

        List<Flight__c> flights3 = DashboardController.getFlightData('', '');
        System.assertEquals(1, flights3.size());
        // Test getCrewMemberData method
        List<Crew_Member__c> crewMembers1 = DashboardController.getCrewMemberData(fc.Name, '');
        System.assertEquals(1, crewMembers1.size());

        List<Crew_Member__c> crewMembers2 = DashboardController.getCrewMemberData('', 'TestCrewMember');
        System.assertEquals(1, crewMembers2.size());

        List<Crew_Member__c> crewMembers3 = DashboardController.getCrewMemberData('', '');
        System.assertEquals(1, crewMembers3.size());
        // Test getFlightOptions method
        List<Flight__c> flightOptions = DashboardController.getFlightOptions();
        System.assertEquals(1, flightOptions.size());

        // Test getCrewMemberOptions method
        List<Crew_Member__c> crewMemberOptions = DashboardController.getCrewMemberOptions();
        System.assertEquals(1, crewMemberOptions.size());

        //Test Bookingtrigger
        Flight__c f = [Select Passenger_Count__c from Flight__c where Id=:testFlight.Id];
        System.assertEquals(1, f.Passenger_Count__c);

        
        //Test Assignmenttrigger
        Crew_Member__c c = [Select Passenger_Count__c from Crew_Member__c where Id=:testCrewMember.Id];
        System.assertEquals(1, c.Passenger_Count__c);

        Test.stopTest();

    }
}