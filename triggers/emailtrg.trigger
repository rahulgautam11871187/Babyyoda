trigger emailtrg on EmailMessage (before insert) {
    
    EmailMessageHandler.parseEmail(Trigger.new);
	    
}