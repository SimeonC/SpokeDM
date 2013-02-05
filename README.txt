This file is part of SpokeDM.

SpokeDM is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

SpokeDM is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the  
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public along with SpokeDM.  
If not, see <http://www.gnu.org/licenses/>.

/*==============================================================================================================*\
											SpokeDM Framework Readme
\*==============================================================================================================*/

SpokeDM is short for Spoke Data Management Framework - named for the imagery of spokes in wheels as this is a framework that leverages CFWheels (1.1.8+) to make visual sense of data with minimal development time.
Allowing developers to work on the more complex "axles" and "Hubs" of the application without worrying about having to code maintenance screens, the maintenance screens could even form part of your application.
Some key features of this framework are:
	Form validation.
	Inbuilt authentication and authorization hooks.
	Automatic Dirty Record checks on save.
	Relationships can be displayed as dropdown types, or as table relationships.
	Links to have custom pages elsewhere in your application loaded for editing a record or viewing multiple records.

/*==============================================================================================================*\
												 Introduction
\*==============================================================================================================*/

SpokeDM ships with some demonstration pages;
	A full working example can be viewed @ <cfwheels base url>/spokes/demoparent/1, To view this you need to do the following steps:
		1.	Setup a datasource for CFWheels, preferably to a blank database (NOTE warning in the Setup Checklist section if using MySQL)
		2.	Setup the tables via the dbmigrate cfwheels plugin, navigate to /rewrite.cfm?controller=wheels&action=wheels&view=plugins&name=dbmigrate to run the setup script (Click "Go" under the Migrate Heading).
		3.	Uncomment the line for your database type in Models/DemoParent.cfc (Most of CFWheels supported databases concatenate strings differently)
	An example of all the available input types can be viewed @ <cfwheels base url>/spokes/test/true; this doesn't require any setup.
	
When using SpokeDM there are 2 URL's you should be aware of:
	<cfwheels base url>/spokes/[modelname]/list		- This will list an (optionally filtered) set of objects that are instantiated on the model.
	<cfwheels base url>/spokes/[modelname]/[key]	- This will load the instance of the model for editing/viewing.

NOTE: if you cannot see any of the pages, try reloading CFWHeels under testing as there was/is a known bug with the development/design modes and ajax calls which would prevent anything from loading.

/*==============================================================================================================*\
												Setup Checklist
\*==============================================================================================================*/

WARNING: SpokeDM makes heavy use of aliases, if you are using Railo and parts do not work, a possible cause may be that you have a mysql database and have not turned on Alias Handling in the Railo datasource settings.

1. Create all the models that you wish to manage through SpokeDM as per a standard CFWheels app with the following changes.
	Every model extends SpokeModel instead of Model.
	In the init function a call to spokeInit() must be made, it is important that this is called before all callback, property and associations calls. spokeInit() takes the following parameters:
		@param name: name			required: No	type: string					The display Name on the front end, defaults to modelName
		@param name: istype			required: No	type: boolean					If this is true we treat this model as a type, defaults to false
		@param name: nameProperty		required: No	type: string					The Name of each instance (can be a composite property or a calculated property), defaults to 'name'
		@param name: DescProperty		required: No	type: string					The Description of each instance (can be a composite property or a calculated property), defaults to ''
		@param name: PropertyOrder	required: No	type: array						An array of property names, the order is the order they appear on the form, if they are omitted from this list then they are not shown - defaults to the database order
		@param name: HiddenFields	required: No	type: string					An list of property names that should NOT be displayed on the front end form.
		@param name: searchProperties	required: No	type: string					a list of properties that are used in searches in addition to name and description. If not set uses name and description only.
		@param name: searchOrderBy	required: No	type: string	a order by clause for sorting search results, only properties on this table are valid, should be formatted the same as orderBy on the findAll CFWheels function
		@param name: hidePrimaryKey	required: No	type: boolean	default: true	Do not show the primary key property on the front end form - note that an enterprising user could still figure it out unless you use obfuscation
		@param name: editorRoute	required: No	type: struct					If this is supplied then this model will be edited/viewed via the page specified instead of in SpokeDM, is passed as params to URLFor()
		@param name: listRoute		required: No	type: struct					If this is supplied then this model will not list it's objects in Spoke DM but provide a link to the page specified, is passed as params to URLFor()
	
	SpokeDM also extends CFWheels property function with the below params, we also make use of CFWheels label param which is what we display on the front end:
		@param name: spokeType		 	required: No	type: string	A string that overrides the type set in the database, can be one of; display, integer, string, datetime, date, time, boolean, float, binary, dropdown. NOTE that binary is currently not supported as a display unless you implement it in the formBase.cfm. the dropdown option must also have the spokeOptions setting included.
		@param name: spokeOptions	 	required: No	type: array		an array of strings that are used as the dropdown options. (If this is defined then the spoketype doesn't need to be set)
		@param name: spokePlaceholder	required: No	type: string	Used as the default/unselected value in dropdowns or as the placeholder value in all other inputs as suitable (some don't support it, like display or checkboxes)
		@param name: spokeTip		 	required: No	type: string	Used as the tip that is displayed next to the label on the form
	
	We also have added a param to the belongsTo() function call that allows us to specify whether the relationship should be treated as a type/lookup and would be displayed as a dropdown on the front end:
		@param name: spokeType			required: No	type: boolean	true will display on the front end as a dropdown not a related table
		@param name: spokeBeforeList	required: No	type: string	the name of a function that returns a string to filter this model when it is shown as a related list, for relating to a new parent.
	
	There is also a custom function called listFilter in the SpokeModel.cfc you can overwrite if you wish to filter what objects are shown in a list, for example; by the currently logged in user. It should return a struct that will be passed to a findAll (essentially).
	
2. If using authentication, permissions or assorted login protocols make sure you look through:
	spokeCheckLogin in controllers/Controller.cfc
	modelPermissions and instPermissions in models/SpokeModel.cfc
	the javascript on the views/Spokes/layout.cfm
	
	NOTE: When using encrypted passwords (and we highly recommend you do), either use an external page to edit the model that contains the password or Use onBeforeValidate and afterFind callbacks in the model to encrypt and unencrypt the password. (We reccomend the former)

3. Update the date/time settings to what you'd like - events/OnApplicationStart.cfm (Default is UK/NZ date time format).
4. Setup the tables that you want to include in the search in events/OnApplicationsStart.cfm.

/*==============================================================================================================*\
											Libraries and Frameworks
\*==============================================================================================================*/

Coffeescript (http://coffeescript.org/)
SASS with Compass (SASS: http://sass-lang.com, Compass: http://compass-style.org/)
AngularJS (http://angularjs.org)
Twitter Bootstrap (http://twitter.github.com/bootstrap/index.html)
Font Awesome (http://fortawesome.github.com/Font-Awesome/)
CFWheels 1.1.8 (http://cfwheels.org/)
jQuery 1.8.3 (http://jquery.com/)
Twitter Bootstrap DateTimePicker Plugin (http://tarruda.github.com/bootstrap-datetimepicker/)
AngularStrap - Bootstrap Directives for AngularJS (http://mgcrea.github.com/angular-strap/)
DBMigrate - for the demo scripts (http://cfwheels.org/plugins/listing/28)

/*==============================================================================================================*\
											Future Features
\*==============================================================================================================*/

These are features I wanted/needed to include but ran out of time to do so.

Unplanned Future Release:

- Double Password validated field, hooked in encryption and security functions.
- Inline AJAX/ng-view loaded custom editors.
- Additional 'peripheral' links on the edit/list forms.
- Additional 'peripheral' AJAX/ng-view loaded views on edit/list forms.
