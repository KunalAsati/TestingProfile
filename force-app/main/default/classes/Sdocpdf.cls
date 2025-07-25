public class Sdocpdf {

    public static void generateDoc(){

        String jsonResp = SDOC.DocumentSDK.generateDoc('a0B2w00000GLn4hEAD', '0012w000003zDrjAAE');

 
        Map<String, Object> respAsObject = (Map<String, Object>) JSON.deserializeUntyped(jsonResp);
 


        

    }

}