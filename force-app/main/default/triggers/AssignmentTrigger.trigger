trigger AssignmentTrigger on Assignment__c (after insert) {

    Set<Id> crewMemberIds = new Set<Id>();

    for (Assignment__c assigment : Trigger.new) {
        crewMemberIds.add(assigment.Crew_Member__c);
    }

    List<Crew_Member__c> crewMemberToUpdate = [SELECT Id, (SELECT Id FROM Assignments__r) FROM Crew_Member__c WHERE Id IN :crewMemberIds];

    for (Crew_Member__c crewMember : crewMemberToUpdate) {
        crewMember.Passenger_Count__c = crewMember.Assignments__r.size();
    }

    update crewMemberToUpdate;
}