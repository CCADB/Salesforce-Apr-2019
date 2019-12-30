/*
    Description: Controller class is for Inline Account page. This is specifically to check
     Audit urls, Audit Same As Parent, CP/CPS urls, CP/CPS Same As Parent fields.
    
    -> only the non blank urls (audit/cp/cps) are ckecked 
    -> When CP and CPS Link is blank and 'CP/CPS Same As Parent' is not True then it display error message.
    -> When CP or CPS link is populated and Parent Cert's 'CP/CPS Same As Parent' is not True then check if they have same CP and CPS. 
       If they match then display message to check CP/CPS Same As Parent checkbox.
    -> When CP or CPS link is populated and Parent Cert's 'CP/CPS Same As Parent' is True then we are checking parent's Parent and compare CP and CPS. 
       If match then display message to check CP/CPS Same As Parent checkbox.
    
    Same logic is used for Audits (Std, Code Sign, BR, EV SSL only)
    
    Updated: 2/2/2019 Check for 'Audit Same as Parent'
    3/5/2019 Updated code to check only populated CP or CPS or all audit urls. We are not comparing blank audit urls.
        
*/
public with sharing class AccountMessageInlineController {
    
    public string strAuditSameAsParent {get; set;}
    public string strCPCPSSameAsParent {get; set;}
    
    public AccountMessageInlineController(Apexpages.standardcontroller controller){
        strAuditSameAsParent = '';
        strCPCPSSameAsParent = '';
        
        Id accId = controller.getId();
        
        List<Account> lstAcc = new List<Account>([select Id, ParentId, 
                        Certificate_Policy_CP__c, Certification_Practice_Statement_CPS__c,
                        Parent.Certificate_Policy_CP__c, Parent.Certification_Practice_Statement_CPS__c,
                        Standard_Audit__c, Parent.Standard_Audit__c, Code_Signing_Audit__c, Parent.Code_Signing_Audit__c,
                        BR_Audit__c, Parent.BR_Audit__c, EV_Audit__c, Parent.EV_Audit__c, 
                        Audits_Same_as_Parent__c, Parent.Audits_Same_as_Parent__c,
                        CP_CPS_Same_as_Parent__c, Parent.CP_CPS_Same_as_Parent__c
                        from Account Where RecordType.Name = 'Intermediate Certificate' and Id =: accId]);
        if(lstAcc.size() > 0){
            Account objAcc = lstAcc[0];
            //if cp/cps are blank then it should check cp/cps same as parent
            if(string.isblank(objAcc.Certificate_Policy_CP__c) && string.isblank(objAcc.Certification_Practice_Statement_CPS__c) && !objAcc.CP_CPS_Same_as_Parent__c){
                strCPCPSSameAsParent = 'Please fill in Policies and Practices Information section or mark the checkbox "CP/CPS Same as Parent"';
            }
            //check if cp/cps are same as parent and parent cert cp/cps is not same as parent
            if((string.isnotblank(objAcc.Certificate_Policy_CP__c) || string.isnotblank(objAcc.Certification_Practice_Statement_CPS__c)) && 
                !objAcc.CP_CPS_Same_as_Parent__c && !objAcc.Parent.CP_CPS_Same_as_Parent__c && (string.isblank(objAcc.Certificate_Policy_CP__c) || 
                (string.isnotblank(objAcc.Certificate_Policy_CP__c) && objAcc.Certificate_Policy_CP__c == objAcc.Parent.Certificate_Policy_CP__c)) &&
                (string.isblank(objAcc.Certification_Practice_Statement_CPS__c) || (string.isnotblank(objAcc.Certification_Practice_Statement_CPS__c) && 
                objAcc.Certification_Practice_Statement_CPS__c == objAcc.Parent.Certification_Practice_Statement_CPS__c))){
                strCPCPSSameAsParent = 'Policies and Practices Information fields are same as parent. Please clear the fields and check "CP/CPS Same as Parent".';
            }
            
            //check if cp/cps are populate and parent intermediate is also same as parent
            if((string.isnotblank(objAcc.Certificate_Policy_CP__c) || string.isnotblank(objAcc.Certification_Practice_Statement_CPS__c)) 
                && !objAcc.CP_CPS_Same_as_Parent__c && objAcc.Parent.CP_CPS_Same_as_Parent__c){
                boolean isFound = false;
                Id accParentId = objAcc.ParentId;
                while(!isFound){
                    Account objParentAccount = GetParentAccount(accParentId);
                    if(objParentAccount != null && (objParentAccount.RecordType.Name == 'Root Certificate' || !objParentAccount.CP_CPS_Same_as_Parent__c)) {
                        isFound = true;
                        if((string.isblank(objAcc.Certificate_Policy_CP__c) || 
                            (string.isnotblank(objAcc.Certificate_Policy_CP__c) && objAcc.Certificate_Policy_CP__c == objParentAccount.Certificate_Policy_CP__c)) &&
                            (string.isblank(objAcc.Certification_Practice_Statement_CPS__c) || (string.isnotblank(objAcc.Certification_Practice_Statement_CPS__c) && 
                            objAcc.Certification_Practice_Statement_CPS__c == objParentAccount.Certification_Practice_Statement_CPS__c))){
                            strCPCPSSameAsParent = 'Policies and Practices Information fields are same as parent. Please clear the fields and check "CP/CPS Same as Parent".';
                        }  
                    } else if(objParentAccount == null) {
                        isFound = true;
                    }
                    if(objParentAccount != null) accParentId = objParentAccount.ParentId;
                }
            }
            
            //if audits are blank then check Audit Same as Parent
            if(string.isblank(objAcc.Standard_Audit__c) && string.isblank(objAcc.Code_Signing_Audit__c) && string.isblank(objAcc.BR_Audit__c) &&
                string.isblank(objAcc.EV_Audit__c) && !objAcc.Audits_Same_as_Parent__c){
                strAuditSameAsParent = 'Please fill in Audit Information section or mark the checkbox "Audits Same as Parent"';    
            }
            //check if audits are same as parent and parent intermediate is not same as parent
            if((string.isnotblank(objAcc.Standard_Audit__c) || string.isnotblank(objAcc.Code_Signing_Audit__c) || 
                string.isnotblank(objAcc.BR_Audit__c) || string.isnotblank(objAcc.EV_Audit__c)) && !objAcc.Audits_Same_as_Parent__c &&
                !objAcc.Parent.Audits_Same_as_Parent__c && 
                (string.isblank(objAcc.Standard_Audit__c) || (string.isnotblank(objAcc.Standard_Audit__c) && objAcc.Standard_Audit__c == objAcc.Parent.Standard_Audit__c)) &&
                (string.isblank(objAcc.Code_Signing_Audit__c) || (string.isnotblank(objAcc.Code_Signing_Audit__c) && objAcc.Code_Signing_Audit__c == objAcc.Parent.Code_Signing_Audit__c)) &&
                (string.isblank(objAcc.BR_Audit__c) || (string.isnotblank(objAcc.BR_Audit__c) && objAcc.BR_Audit__c == objAcc.Parent.BR_Audit__c)) &&
                (string.isblank(objAcc.EV_Audit__c) || (string.isnotblank(objAcc.EV_Audit__c) && objAcc.EV_Audit__c == objAcc.Parent.EV_Audit__c))){
                strAuditSameAsParent = 'All provided Audits are same as parent. Please clear the Audit fields and check "Audits Same as Parent".';
            }
            
            //check if audits are populated and parent intermediate is also same as parent
            if((string.isnotblank(objAcc.Standard_Audit__c) || string.isnotblank(objAcc.Code_Signing_Audit__c) || string.isnotblank(objAcc.BR_Audit__c) || 
                string.isnotblank(objAcc.EV_Audit__c)) && !objAcc.Audits_Same_as_Parent__c && objAcc.Parent.Audits_Same_as_Parent__c){
                boolean isFound = false;
                Id accParentId = objAcc.ParentId;
                while(!isFound){
                    Account objParentAccount = GetParentAccount(accParentId);
                    if(objParentAccount != null && (objParentAccount.RecordType.Name == 'Root Certificate' || !objParentAccount.Audits_Same_as_Parent__c)) {
                        isFound = true;
                        if((string.isblank(objAcc.Standard_Audit__c) || (string.isnotblank(objAcc.Standard_Audit__c) && objAcc.Standard_Audit__c == objParentAccount.Standard_Audit__c)) &&
                            (string.isblank(objAcc.Code_Signing_Audit__c) || (string.isnotblank(objAcc.Code_Signing_Audit__c) && objAcc.Code_Signing_Audit__c == objParentAccount.Code_Signing_Audit__c)) &&
                            (string.isblank(objAcc.BR_Audit__c) || (string.isnotblank(objAcc.BR_Audit__c) && objAcc.BR_Audit__c == objParentAccount.BR_Audit__c)) &&
                            (string.isblank(objAcc.EV_Audit__c) || (string.isnotblank(objAcc.EV_Audit__c) && objAcc.EV_Audit__c == objParentAccount.EV_Audit__c))){
                            strAuditSameAsParent = 'All provided Audits are same as parent. Please clear the Audit fields and check "Audits Same as Parent".';
                        }
                    } else if(objParentAccount == null) {
                        isFound = true;
                    }
                    if(objParentAccount != null) accParentId = objParentAccount.ParentId;
                }
            }
        }
    }
    
    public Account GetParentAccount(string accId){
        List<Account> lstAcc = new List<Account>([select Id, ParentId, RecordType.Name,
                        Certificate_Policy_CP__c, Certification_Practice_Statement_CPS__c,
                        Parent.Certificate_Policy_CP__c, Parent.Certification_Practice_Statement_CPS__c,
                        Standard_Audit__c, Parent.Standard_Audit__c, Code_Signing_Audit__c, Parent.Code_Signing_Audit__c,
                        BR_Audit__c, Parent.BR_Audit__c, EV_Audit__c, Parent.EV_Audit__c, 
                        Audits_Same_as_Parent__c, Parent.Audits_Same_as_Parent__c,
                        CP_CPS_Same_as_Parent__c, Parent.CP_CPS_Same_as_Parent__c
                        from Account Where Id =: accId]);
        if(lstAcc.size() > 0){
            return lstAcc[0];
        }
        return null;
    }
}