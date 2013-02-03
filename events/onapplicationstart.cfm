<!--- Place code here that should be executed on the "onApplicationStart" event. --->
<cfscript>
	APPLICATION.spokeTimeformat = "hh:mm:ss tt";
	APPLICATION.spokeDateformat = "dd/MM/yyyy";
	APPLICATION.spokeSearch = ['demochild','demoparent','demotype'];
	//APPLICATION.spokeSearch = ['A','List','Of','Spoke','Models']; this will be the order you see on the search plugin. see the spokeInit argument searchColumns for more settings.
	APPLICATION.spokeSearchTimeout = 20;//Time in minutes, we minimise this to 5 minute refresh - queries are also refreshed through updates through SpokeModel via callbacks.
</cfscript>