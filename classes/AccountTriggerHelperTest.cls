/**

Test Case for the AccountTrigger apex trigger and AccountTriggerHelper apex class

**/

@isTest 
public class AccountTriggerHelperTest{
    
    static testMethod void validateAccount() {
    
        Account acc = TestUtils.getCAOwner();
        insert acc;
            
        Contact con = TestUtils.getContact(acc.id);
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CA Contact').getRecordTypeId();
        insert con;
        
        //UserRole urole = [Select PortalType, PortalAccountId From UserRole where PortalType = 'CustomerPortal' and PortalAccountId != null limit 1];
        
        User user = new User();
        //user.UserRoleId = urole.Id;//UserInfo.getUserRoleId();//
        //user.ProfileID = [Select Id From Profile Where UserType = 'PowerCustomerSuccess' LIMIT 1].id;
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User For CCADB' AND UserType = 'PowerCustomerSuccess' LIMIT 1].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@test1234098.com';   
        user.CommunityNickname = 'testUser09887123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = con.Id;
        //user.PortalRole = 'Manager';
        insert user;
        
        AccountShare aShare = new AccountShare();
        aShare.AccountAccessLevel = 'Edit';
        aShare.ContactAccessLevel = 'Edit';
        aShare.OpportunityAccessLevel = 'Edit';
        aShare.RowCause = 'Manual';
        aShare.AccountId = acc.Id;
        aShare.UserOrGroupId = user.Id;
        insert aShare;
        
        System.RunAs(user) {
        
            // create a ROOT CA
            Account rootCA = TestUtils.getRootCertificate(acc.Id); 
            rootCa.X_509_Certificate_PEM__c = 'abc';
            insert rootCa;
            
            Test.startTest(); 
            
            // create intermediate CA
            Account testAccount = TestUtils.getIntermediateCertificate(rootCa.Id);
            testAccount.X_509_Certificate_PEM__c = 'abc';
            insert testAccount;
            
            // create a ROOT CA
            Account rootCA1 = TestUtils.getRootCertificate(acc.Id); 
            rootCa1.X_509_Certificate_PEM__c = 'abc';
            insert rootCa1;
            
            testAccount.X_509_Certificate_PEM__c = 'test';
            testAccount.parentId = rootCa1.id;
            update testAccount;
            
            acc.Name = 'SymantecAccount';
            update acc;
            
            Test.stopTest();
        }
        
        Account accountSo = New Account(name='SymantecAccount');
        insert accountSo;
        
        accountSo.Name = 'NameChanged';
        update accountSo;
    }
    
    static testMethod void TestInternalUserSharing() {
    
        Account acc = TestUtils.getCAOwner();
        insert acc;
            
        Contact con = TestUtils.getContact(acc.id);
        con.Type__c = 'Primary POC';
        con.Is_Community_User__c = true;
        con.recordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('CA Contact').getRecordTypeId();
        insert con;
        
        User user = new User();
        user.ProfileId = [SELECT Id FROM Profile WHERE Name = 'Customer Community Plus Login User For CCADB' AND UserType = 'PowerCustomerSuccess' LIMIT 1].Id;
        user.EmailEncodingKey = 'ISO-8859-1';
        user.LanguageLocaleKey = 'en_US';
        user.TimeZoneSidKey = 'America/New_York';
        user.LocaleSidKey = 'en_US';
        user.FirstName = 'first';
        user.LastName = 'last';
        user.Username = 'test@test1234098.com';   
        user.CommunityNickname = 'testUser09887123';
        user.Alias = 't1';
        user.Email = 'no@email.com';
        user.IsActive = true;
        user.ContactId = con.Id;
        insert user;
        
        // create a ROOT CA
        Account rootCA = TestUtils.getRootCertificate(acc.Id); 
        rootCa.X_509_Certificate_PEM__c = 'abc';
        insert rootCa;
        
        Test.startTest();
        
        rootCa.Name = 'Root 2';
        update rootCa;
        
        // create intermediate CA
        Account testAccount = TestUtils.getIntermediateCertificate(rootCa.Id);
        testAccount.CA_Owner_Id__c = acc.Id;
        testAccount.Audits_Same_as_Parent__c = true;
        insert testAccount;
        
        Test.stopTest();
    }
    
    static testMethod void TestValidateAuditInfo() {
        
        Account acc = TestUtils.getCAOwner();
        insert acc;
        
        CPACanada_File__c objCPACanada = new CPACanada_File__c();
        objCPACanada.Name = '10149';
        objCPACanada.Report_Id__c = '225352';
        objCPACanada.Report_URL__c = 'https://www.cpacanada.ca/generichandlers/aptifyattachmenthandler.ashx?attachmentid=225352';
        objCPACanada.Seal_URL__c = 'https://www.cpacanada.ca/webtrustseal?sealid=10149';
        insert objCPACanada;
            
        // create a ROOT CA
        Account rootCA = TestUtils.getRootCertificate(acc.Id);
        rootCa.X_509_Certificate_PEM__c = 'abc';
        insert rootCa;
        
        // create intermediate CA
        Account testAccount = TestUtils.getIntermediateCertificate(rootCa.Id);
        testAccount.Status__c = 'Removed';
        testAccount.X_509_Certificate_PEM__c = 'abc';
        testAccount.CA_Owner_Id__c = acc.Id;
        insert testAccount;
        
        try {
            testaccount.Standard_Audit__c = '';
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Standard_Audit__c = '';
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'https://www.cpacanada.ca/webtrustseal?sealid=10149';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.Standard_Audit_Period_Start_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Standard_Audit__c = '';
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'https://www.cpacanada.ca/webtrustseal?sealid=10149';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.Standard_Audit_Period_Start_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.Standard_Audit_Period_End_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_End_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.BR_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'https://www.cpacanada.ca/webtrustseal?sealid=10149';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.BR_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.BR_Audit_Period_Start_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.BR_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.BR_Audit_Period_Start_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_End_Date__c = system.today();
            testaccount.BR_Audit_Period_End_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
        
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'https://www.cpacanada.ca/webtrustseal?sealid=10149';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Period_Start_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Period_Start_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Audit_Period_End_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit__c = 'http://google.com';
            testaccount.Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.Code_Signing_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_End_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
        
        
        try {
            testaccount.Standard_Audit__c = '';
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.BR_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.BR_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Standard_Audit__c = '';
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.BR_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_Start_Date__c = system.today();
            testaccount.BR_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.BR_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.BR_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_End_Date__c = system.today();
            testaccount.BR_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.BR_Audit_Period_Start_Date__c = system.today();
            testaccount.BR_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
        
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.EV_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.EV_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.Standard_Audit__c = 'http://google.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google.com';
            testaccount.Standard_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Statement_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.EV_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.EV_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.BR_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.EV_Audit_Statement_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today().addDays(2);
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.EV_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
            
        try {
            testaccount.Code_Signing_Audit__c = '';
            testaccount.BR_Audit__c = '';
            testaccount.EV_Audit__c = '';
            testaccount.EV_Code_Signing_Audit__c = '';
            testaccount.EV_Audit__c = 'http://google1.com';
            testaccount.EV_Code_Signing_Audit__c = 'http://google1.com';
            testaccount.EV_Audit_Period_End_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Period_End_Date__c = system.today().addDays(2);
            testaccount.EV_Code_Signing_Audit_Period_Start_Date__c = system.today();
            testaccount.EV_Code_Signing_Audit_Statement_Date__c = system.today();
            update testAccount;
        } catch (Exception ex){}
        
        try {
            delete rootCa;
        } catch (Exception ex){}
    }
}