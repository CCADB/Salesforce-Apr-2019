/*
    Test class for AccountMessageInlineController
*/
@isTest
public with sharing class AccountMessageInlineControllerTest {
    
    static testMethod void TestAccountMessage() {
        Account caOwnerAcc = TestUtils.getCAOwner();
        insert caOwnerAcc;
        
        Account rootAccount = TestUtils.getRootCertificate(caOwnerAcc.id);
        rootAccount.Name = 'child root account 1';
        rootAccount.Standard_Audit__c = 'https://std.com';
        rootAccount.Standard_Audit_Type__c = 'WebTrust';
        rootAccount.Standard_Audit_Statement_Date__c = system.today();
        rootAccount.Standard_Audit_Period_Start_Date__c = system.today();
        rootAccount.Standard_Audit_Period_End_Date__c = system.today();
        rootAccount.Certificate_Policy_CP__c = 'https://cp.com';
        rootAccount.Certification_Practice_Statement_CPS__c = 'https://cps.com';
        insert rootAccount;
        
        Account interCertAccount1 = TestUtils.getIntermediateCertificate(rootAccount.id);
        interCertAccount1.Name = 'child Intercert account 1';
        interCertAccount1.Audits_Same_as_Parent__c = true;
        interCertAccount1.CP_CPS_Same_as_Parent__c = true;
        insert interCertAccount1;
        
        Account interCertAccount2 = TestUtils.getIntermediateCertificate(interCertAccount1.id);
        interCertAccount2.Name = 'child Intercert account 2';
        interCertAccount2.Standard_Audit__c = 'https://std.com';
        interCertAccount2.Standard_Audit_Type__c = 'WebTrust';
        interCertAccount2.Standard_Audit_Statement_Date__c = system.today();
        interCertAccount2.Standard_Audit_Period_Start_Date__c = system.today();
        interCertAccount2.Standard_Audit_Period_End_Date__c = system.today();
        insert interCertAccount2;
        
        AccountMessageInlineController controller = new AccountMessageInlineController(new Apexpages.standardcontroller(interCertAccount2));
        
        interCertAccount2.Certificate_Policy_CP__c = 'https://cp.com';
        update interCertAccount2;
        
        controller = new AccountMessageInlineController(new Apexpages.standardcontroller(interCertAccount2));
        
        Account interCertAccount3 = TestUtils.getIntermediateCertificate(interCertAccount2.id);
        interCertAccount3.Name = 'child Intercert account 3';
        insert interCertAccount3;
        
        controller = new AccountMessageInlineController(new Apexpages.standardcontroller(interCertAccount3));
        
        interCertAccount3.Standard_Audit__c = 'https://std.com';
        interCertAccount3.Standard_Audit_Type__c = 'WebTrust';
        interCertAccount3.Standard_Audit_Statement_Date__c = system.today();
        interCertAccount3.Standard_Audit_Period_Start_Date__c = system.today();
        interCertAccount3.Standard_Audit_Period_End_Date__c = system.today();
        interCertAccount3.Certificate_Policy_CP__c = 'https://cp.com';
        update interCertAccount3;
        
        controller = new AccountMessageInlineController(new Apexpages.standardcontroller(interCertAccount3));
    }
}