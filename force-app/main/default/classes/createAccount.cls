@RestResource(urlMapping='/createAccount/*')

global with sharing class createAccount

{

 @HttpPost

 global static String createAccount(String AccName)

 {

  Account a = new Account();

  a.Name = AccName;

  insert a;

  String returnResponse = JSON.serialize(a);

  return returnResponse;

 }

}