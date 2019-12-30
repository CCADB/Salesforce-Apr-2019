/*
    Description: Controller is created for Insert Leads for new CA
*/
public with sharing class AccessRequestFormController {
    
    private static String baseUrl = 'https://www.google.com/recaptcha/api/siteverify'; 
    private static String secret = System.Label.Google_Captcha_SecretKey;
    public String sitekey {get; set;}
    public string strConfirmEmail {get; set;}
    
    public boolean isLeadCreated {get; set;}
    
    private Lead objLead;
    
    public String response  { get { return ApexPages.currentPage().getParameters().get('g-recaptcha-response'); } }
    public AccessRequestFormController (Apexpages.standardcontroller controller){
        isLeadCreated = false;
        sitekey = System.Label.Google_Captcha_SiteKey;
        objLead = (Lead)controller.getRecord();
        strConfirmEmail = '';
    }
    
    public void doVerify () { 
        //system.debug('response::: '+response);
        String responseBody = makeRequest(baseUrl,'secret=' + secret +'&response='+ response); 
        //system.debug('responseBody  ::: '+responseBody);
        if(string.isblank(objLead.FirstName)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter First Name.'); 
            ApexPages.addMessage(errorMsg);
            return;
        } 
        if(string.isblank(objLead.Email)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter Email address.'); 
            ApexPages.addMessage(errorMsg);
            return;
        } 
        if(string.isblank(objLead.Salesforce_Terms_of_Service__c)){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please select Salesforce Terms of Services.'); 
            ApexPages.addMessage(errorMsg);
            return;
        } 
        if((string.isnotblank(objLead.Website) && !objLead.Website.startswith('http')) || 
            (string.isnotblank(objLead.CP_CPS_document_URLs__c) && !objLead.CP_CPS_document_URLs__c.startswith('http'))){
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter URL beginning with https://.'); 
            ApexPages.addMessage(errorMsg);
            return;
        }
        if(objLead.Email != null && objLead.Email != '') {
            if(string.isblank(strConfirmEmail)){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Please enter Confirmation Email address.'); 
                ApexPages.addMessage(errorMsg);
                return;
            } else if(string.isnotblank(strConfirmEmail) && objLead.Email != strConfirmEmail){
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error, 'Email and Confirmation Email do not match.'); 
                ApexPages.addMessage(errorMsg);
                return;
            }
        }
        String success = getValueFromJson(responseBody, 'success'); 
        if(success.equalsIgnoreCase('true') || Test.IsRunningTest()) { 
            try {
                insert objLead; 
                isLeadCreated = true;
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.CONFIRM, 'Thank you for submitting your request.'); 
                ApexPages.addMessage(errorMsg);
                return;
            } catch(exception e) { 
                isLeadCreated = false;
                ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage()); 
                ApexPages.addMessage(errorMsg);
                return; 
            } 
        } else { 
            ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Please check the box for reCAPTCHA'); 
            ApexPages.addMessage(errorMsg); 
            return; 
        }
    } 
    private static String makeRequest(string url, string body) { 
        HttpResponse response = null; 
        HttpRequest req = new HttpRequest(); 
        req.setEndpoint(url); 
        req.setMethod('POST'); 
        req.setBody(body); 
        try { 
            Http http = new Http(); 
            if(!Test.IsRunningTest()){
                response = http.send(req); 
                return response.getBody();
            } 
        } catch(System.Exception e) { 
            //System.debug('ERROR: ' + e); 
        } return '{"success":false}'; 
    } 
    public static string getValueFromJson ( String strJson, String field ) { 
        JSONParser parser = JSON.createParser(strJson); 
        while (parser.nextToken() != null) { 
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) { 
                if(parser.getText() == field){ 
                    //Get the value.
                    parser.nextToken(); 
                    return parser.getText(); 
                } 
            } 
        } 
        return null; 
    }
}