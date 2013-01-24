<!---
	Here you can add routes to your application and edit the default one.
	The default route is the one that will be called on your application's "home" page.
	
	NOTE: remember that the routes are evaluated in order - so please try not to override the spoke routes, if you need to for a specific situation, put the route after the spoke section
--->
<cfscript>
	addRoute(name="home", pattern="", controller="wheels", action="wheels");
	
	//spoke specific routes - DO NOT CHANGE (unless you are sure you know what you're doing, then go for it!)
	addRoute(name="spokeData", pattern="/spokes/[modelkey]/[key]", controller="spokes", action="index");
	addRoute(name="spokeDataAjax", pattern="/spokedata/[modelkey]/[key]", controller="spokes", action="dataajax");
	addRoute(name="spokeList", pattern="/spokes/[modelkey]", controller="spokes", action="index");
	addRoute(name="spokeListAjax", pattern="/spokedata/[modelkey]", controller="spokes", action="dataajax");
	addRoute(name="spoke", pattern="/spokes", controller="spokes", action="index");
	addRoute(name="spokeAjax", pattern="/spokedata", controller="spokes", action="dataajax");
</cfscript>