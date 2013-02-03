<!---
	This file is part of SpokeDM.

    SpokeDM is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SpokeDM is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SpokeDM.  If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent extends="Model">
	<cfinclude template="../events/spokefunctions.cfm">
	<!--- init as Tableless in CFWheels 1.2 for better testing--->
	
	<!---
		All externally accessable or settable spokeSystem Variables and Functions are prefixed with 'spoke'
		All internal spokeSystem Variables and Functions are prefixed with '$spoke' - these should not be called/used except by the spoke framework
		modelPermissions and instPermissions break this naming convention as each should be overwritten in each SpokeModel file that uses permissions
		
		Setup Notes: For a dropdown to be loaded you must define the relationship as belongsTo(name="type", spoketype=true); OR use the spokeType variables in a property call.
		belongsTo also takes the argument spokename which is the display name of that relationship when showing this model.
		We have extend the property call from cfwheels to have the additional params as follows:
			property(name="columnname");
				@param name: label				required: No	type: string	defines the label to be used on the front end
				@param name: spokeType:			required: No	type: string	A string that overrides the type set in the database, can be one of; display, integer, string, datetime, date, time, boolean, float, binary, dropdown
									NOTE that binary is currently not supported as a display unless you implement it in the formBase.cfm. the dropdown option must also have the spokeOptions setting included.
				@param name: spokeOptions		required: No	type: string	an array of strings that are used as the dropdown options. (If this is defined then the spoketype doesn't need to be set)
				@param name: spokePlaceholder	required: No	type: string	Used as the default/unselected value in dropdowns or as the placeholder value in all other inputs as suitable (some don't support it, like display or checkboxes)
				@param name: spokeDesc			required: No	type: string	Used as the description that is displayed next to the label on the form
				@param name: spokeTip			required: No	type: string	displayed as a tooltip on the input
			
			belongsTo();
				@param name: spokeType			required: No	type: boolean	true will display on the front end as a dropdown not a related table
				@param name: spokeBeforeList	required: No	type: string	the name of a function that returns a struct to filter this model when it is shown as a related list, for relating to a new parent.
																				the function takes the optional parameter currentKey if being replaced
		
		Properties that are on the spoke model instance are (all should be set through spokeInit()):
			spokeInit()
				@param name: Name			required: No	type: string	The display Name on the front end, defaults to modelName.
				@param name: NameColumn		required: No	type: string	The Name of each instance (can be a composite column or a calculated column), defaults to 'name', errors if no name column.
				@param name: istype			required: No	type: string	If this is true we treat this model as a type, defaults to false
				@param name: DescColumn		required: No	type: string	The Description of each instance (can be a composite column or a calculated column), attempts to default to one of (in order): "description,desc,note,notes" otherwise defaults to ''
				@param name: HiddenFields	required: No	type: string	A list of column names that should NOT be displayed on the front end form, these override the columnorder setting.
				@param name: ColumnOrder	required: No	type: string	An array of column keys that reference elements in the spokesettings.ColumnMap, the order is the order they appear on the form, if they are omitted from this list then they are not shown - defaults to the database order
				@param name: searchColumns	required: No	type: string	a list of columns that are used in searches in addition to name and description. If not set uses name and description only.
				@param name: searchOrderBy	required: No	type: string	a order by clause for sorting search results, only columns on this table are valid, should be formatted the same as orderBy on the findAll CFWheels function
				@param name: hidePrimaryKey	required: No	type: string	if true the primary key will not be shown in the view as a field, defaults to true
				@param name: editorRoute	required: No	type: string	a set of params as in urlFor() used for when you do not wish to allow editing/viewing inside wheels - loading it in SpokeDM will load it in another window.
				@param name: listRoute		required: No	type: string	a set of params as in urlFor() used for when you do not wish to show a list of this model in SpokeDM, will create a link that will load it in another window.
		
		NOTE: for NameColumn and DescColumn if you use a composite/calculated column include the table name!
	--->
	
	<!---
		These two functions should be lightweight - don't do too much processing in them or the application could slow down.
		Both functions are used to decide what buttons are displayed, data send but also we check using the inbuilt wheels callbacks to ensure no-one has tampered with the js.
		My suggestion is to store the needed user variables preloaded in the session so we only are referencing them here not re-loading.
		
		We seperate them as sometimes we need to call permissions on un-instantiated models, eg displaying children which we don't instantiate the model at all.
		On an instantiated model both permissions functions are called
	--->
	<cffunction name="modelPermissions" access="public" returnType="number" output="false" hint="Overwrite this in each model to customise the permissions that a user has on a particular form.">
		<cfscript>
			//this is the SpokeModel we are testing on - a Class not an instantiated object
			//acceptable return values are 0 = no access, 1 = read only, 2 = read/write, 3 = read/write/Add, 4 = read/write/add/Delete
			return 4;//change this to change the default "Everyone" value for ALL Spoke Pages.
		</cfscript>
	</cffunction>
	<cffunction name="instPermissions" access="public" returnType="number" output="false" hint="Overwrite this if individual instances of a model have differing permissions.">
		<cfscript>
			//this is the SpokeModel Instance we are testing on
			//acceptable return values are 0 = no access, 1 = read only, 2 = read/write, 3 = read/write/Add, 4 = read/write/add/Delete
			return 4;//change this to change the default "Everyone" value for ALL Spoke Pages.
		</cfscript>
	</cffunction>
	<cffunction name="listFilter" access="public" returnType="struct" output="false" hint="Overwrite this if you wish to filter the list of the model instances, for example; by the current user, should return a struct that would be included with a findAll and sets the parameters: include, where.">
		<cfscript>
			return {};//in your model overwrite this based on your authentication and model structures, ie return {"where": "userid = #SESSION.userid#"};
		</cfscript>
	</cffunction>
	
	<!---
		setup functions
	--->
	
	<cffunction name="spokeInit" access="public" returnType="void" output="false" hint="initial setup of ALL spokeSetting variables, also includes the callbacks to work with permissions so should ALLWAYS be called">
		<cfargument name="name" required="false" type="string" hint="The display Name on the front end, defaults to modelName">
		<cfargument name="istype" required="false" type="boolean" hint="If this is true we treat this model as a type, defaults to false">
		<cfargument name="nameColumn" required="false" type="string" hint="The Name of each instance (can be a composite column or a calculated column), defaults to 'name'">
		<cfargument name="DescColumn" required="false" type="string" hint="The Description of each instance (can be a composite column or a calculated column), defaults to ''">
		<cfargument name="ColumnOrder" required="false" type="array" hint="An array of column names, the order is the order they appear on the form, if they are omitted from this list then they are not shown - defaults to the database order">
		<cfargument name="HiddenFields" required="false" type="string" default="createdat,deletedat,updatedat" hint="An list of column names that should NOT be displayed on the front end form.">
		<cfargument name="searchColumns" required="false" type="string" hint="a list of columns that are used in searches in addition to name and description. If not set uses name and description only.">
		<cfargument name="searchOrderBy" required="false" type="string" hint="a order by clause for sorting search results, only columns on this table are valid, should be formatted the same as orderBy on the findAll CFWheels function">
		<cfargument name="hidePrimaryKey" required="false" type="boolean" default=true hint="Doesn't show the primary key column on the front end form - note that an enterprising user could still figure it out unless you use obfuscation">
		<cfargument name="editorRoute" required="false" type="struct" hint="If this is supplied then this model will be edited via the page specified instead of in SpokeDM, is passed as params to URLFor()">
		<cfargument name="listRoute" required="false" type="struct" hint="If this is supplied then this model will not list it's objects in Spoke DM but provide a link to the page specified, is passed as params to URLFor()">
		<cfscript>
			//used to do this just by appending arguments to the spokesettings array - but then we end up with a load of NULLs, not that it matters much, I just think it looks ugly.
			variables.wheels.class.spokesettings = {};
			if(StructKeyExists(arguments, "name")) variables.wheels.class.spokesettings.name = arguments.name;
			if(StructKeyExists(arguments, "istype")) variables.wheels.class.spokesettings.istype = arguments.istype;
			if(StructKeyExists(arguments, "nameColumn")) variables.wheels.class.spokesettings.nameColumn = arguments.nameColumn;
			if(StructKeyExists(arguments, "DescColumn")) variables.wheels.class.spokesettings.DescColumn = arguments.DescColumn;
			if(StructKeyExists(arguments, "ColumnOrder")) variables.wheels.class.spokesettings.ColumnOrder = arguments.ColumnOrder;
			variables.wheels.class.spokesettings.HiddenFields = arguments.HiddenFields;
			if(StructKeyExists(arguments, "SearchColumns")) variables.wheels.class.spokesettings.SearchColumns = arguments.SearchColumns;
			if(StructKeyExists(arguments, "searchOrderBy")) variables.wheels.class.spokesettings.searchOrderBy = arguments.searchOrderBy;
			variables.wheels.class.spokesettings.hidePrimaryKey = arguments.hidePrimaryKey;
			if(StructKeyExists(arguments, "listRoute")){
				variables.wheels.class.spokesettings.listRoute = arguments.listRoute;
				StructDelete(variables.wheels.class.spokesettings.listRoute, "key");
			}
			if(StructKeyExists(arguments, "editorRoute")){
				variables.wheels.class.spokesettings.editorRoute = arguments.editorRoute;
				StructDelete(variables.wheels.class.spokesettings.editorRoute, "key");
			}
			//register callbacks
			beforeValidation("$spokeBeforeValidation");
			beforeCreate("$spokeBeforeCreate");
			beforeUpdate("$spokeBeforeUpdate");
			beforeSave("$spokeBeforeSave");
			beforeDelete("$spokeBeforeDelete");
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokeBeforeCreate">
		<cfscript>
			if(model(this.modelname()).modelPermissions() >= 3 && this.instPermissions() >= 3) return true;
			addErrorToBase("You do not have permission to Create a new object.");
			return false;
		</cfscript>
	</cffunction>
	<cffunction name="$spokeBeforeUpdate">
		<cfscript>
			if(model(this.modelname()).modelPermissions() >= 2 && this.instPermissions() >= 2) return true;
			addErrorToBase("You do not have permission to Update this object.");
			return false;
		</cfscript>
	</cffunction>
	<cffunction name="$spokeBeforeSave">
		<cfscript>
			if(StructKeyExists(APPLICATION, "spokeSearchRefresh")) StructDelete(APPLICATION.spokeSearchRefresh, this.modelname());
			if(!(model(this.modelname()).modelPermissions() >= 2 && this.instPermissions() >= 2)){
				addErrorToBase("You do not have permission to Save this object.");
				return false;
			}
			return true;
		</cfscript>
	</cffunction>
	<cffunction name="$spokeBeforeDelete">
		<cfscript>
			if(model(this.modelname()).modelPermissions() >= 4 && this.instPermissions() >= 4) return true;
			addErrorToBase("You do not have permission to Delete this object.");
			return false;
		</cfscript>
	</cffunction>
	<cffunction name="$spokeBeforeValidation">
		<cfscript>
			//remap the type links - the properties are passed back as modelname instead of modelnameid for example
			for(var key in variables.wheels.class.associations){
				if(!StructKeyExists(this, variables.wheels.class.associations[key].modelname)) continue;
				this[this.$foreignKey(key)] = this[variables.wheels.class.associations[key].modelname];
			}
			//create the date objects to save
			var changedProps = ListToArray(this.changedProperties());
			for(var key in changedProps)
				if(StructKeyExists(this, key) && Len(this[key]) && StructKeyExists(variables.wheels.class.properties, key) //check if value exists - if not we don't need to process it
					&& (variables.wheels.class.properties[key].validationType == "datetime"
					|| variables.wheels.class.properties[key].type == 'CF_SQL_DATE'
					|| variables.wheels.class.properties[key].type == 'CF_SQL_TIME'
					|| (
						StructKeyExists(variables.wheels.class.mapping, key)
						&& StructKeyExists(variables.wheels.class.mapping[key], "spoketype")
						&& (variables.wheels.class.mapping[key].spoketype == "datetime"
							|| variables.wheels.class.mapping[key].spoketype == "time"
							|| variables.wheels.class.mapping[key].spoketype == "date"
						)
					)
				)){
					var formatter = CreateObject("java", "java.text.SimpleDateFormat");
					formatter.init(APPLICATION.spokeDateFormat & " " & REReplaceNoCase(APPLICATION.spokeTimeFormat, 'tt', 'a', 'ALL'));
					this[key] = formatter.parse(this[key]);
				}
		</cfscript>
	</cffunction>
	
	<!---
		Instantiated functions
	--->
	
	<cffunction name="spokeDataLoad" access="public" returnType="struct" output="false" hint="returns a struct of DATA to be set for this model, includes types but doesn't include associated parents and children">
		<cfscript>
			var modelPerms = model(this.modelname()).modelPermissions();
			if(modelPerms == 0) return {"errors": [{"message": "You do not have permission to view that."}]};
			var instPerms = this.instPermissions();
			if(instPerms == 0)
				return {
					"name": this.spokeDisplayName(false),
					"warning": "You do not have permissions to view this.",
					"associations": this.spokeAssociations(),
					"errors": []
				};
			return {
				"name": this.spokeDisplayName(false),
				"properties": this.spokeProperties(),
				"associations": this.spokeAssociations(),
				"permissions": Min(modelPerms, instPerms),
				"errors": []
			};
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeNew" access="public" returnType="struct" output="false" hint="returns a new data object">
		<cfargument name="newmodelkey" type="string" required="false" hint="if this is provided then we create a child record off this model, else we create a new instance of this model">
		<cfscript>
			var newInst = {};
			if(StructKeyExists(arguments, "newmodelkey")) newInst = this.$associationMethod(missingMethodName = "new" & Capitalize(arguments.newmodelkey), missingMethodArguments = {});
			else newInst = this.new();
			
			if(newinst.modelPermissions() <= 2) return {"errors": [{"message": "You do not have permission to create a new instance."}]};
			var result = {
				"name": newInst.spokeDisplayName(false),
				"properties": newInst.spokeProperties(),
				"associations": {"parents": []},
				"permissions": 4,//allways able to delete a new object - make sure this is reloaded when saved
				"_invis": [{"name": newInst.$foreignKey(this.modelName()), "value": newInst.$spokeValue(newInst.$foreignKey(this.modelName()))}],
				"errors": []
			};
			//build the parents up so we can search and select which parents to relate it to
			return result; 
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeTypeload" access="public" returnType="struct" output="false" hint="returns a struct of DATA such that this model may be edited as a list of types">
		<cfscript>
			var modelPerms = model(this.modelname()).modelPermissions();
			if(modelPerms == 0) return {"errors": [{"message": "You do not have permission to view that."}]};
			var workingColumnOrder = this.spokeColumns();
			var columns = [];
			for(var col in workingColumnOrder) ArrayAppend(columns, this.$spokeProperty(col));
			return {
				"name": this.spokeDisplayName(),
				"listing": this.spokeList(true),
				"columns": columns,
				"permissions": modelPerms,
				"errors": []
			};
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeListload" access="public" returnType="struct" output="false" hint="returns an array listing all instances viewable">
		<cfscript>
			var modelPerms = model(this.modelname()).modelPermissions();
			if(modelPerms == 0) return {"errors": [{"message": "You do not have permission to view that."}]};
			return {
				"name": this.spokeDisplayName(),
				"listing": this.spokeList(),//use listing so we don't conflict with the list function in the javascript
				"permissions": modelPerms,
				"errors": []
			};
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeRelinkParent" access="public" returnType="struct" output="false" hint="returns an array listing all instances viewable">
		<cfargument name="parentName" required="true" type="string" hint="The name of the RELATIONSHIP we are linking through">
		<cfscript>
			if(!StructKeyExists(variables.wheels.class.associations, arguments.parentName)) return {"errors": [{"message": "You do not have permission to change/view this."}]};//catches people snooping around
			var assoc = variables.wheels.class.associations[arguments.parentName];
			if(assoc.type != "belongsTo") return {"errors": [{"message":"An error has occured, code: SM271, please contact your System Developer."}]};
			var parentModel = model(assoc.modelname);
			var parentPerms = parentModel.modelPermissions();
			var foreignKey = (StructKeyExists(assoc, "foreignKey"))
				?assoc.foreignKey
				:(Singularize(arguments.parentName)&"id");
			if(model(this.modelname()).modelPermissions() <= 1) return {"errors": [{"message": "You do not have permission to change/view this."}]};
			return {
				"name": parentModel.spokeDisplayName(),
				"listing"://use listing so we don't conflict with the list function in the javascript
					(StructKeyExists(assoc, "spokeBeforeList") && assoc.spokeBeforeList != "")
						?parentModel.spokeList(passThrough=$invoke(method=assoc.spokeBeforeList, invokeArgs={"currentKey": this[foreignKey]}))
						:parentModel.spokeList(),
				"propertyname": foreignKey,
				"permissions": parentPerms,
				"errors": []
			};
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeDisplayName" access="public" returnType="string" output="false" hint="returns the calculated display name of the table">
		<cfargument name="plural" type="boolean" required="false" default=true>
		<cfscript>
			var result = "";
			if(StructKeyExists(variables.wheels.class.spokesettings, "name") && Len(variables.wheels.class.spokesettings.name)) result = variables.wheels.class.spokesettings.name;
			else result = this.modelName();
			return Humanize($spokePluralize(result, arguments.plural));
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokePluralize" access="private" returnType="string" output="false" hint="same as the wheels function but works on multi-word strings">
		<cfargument name="string" type="string" required="true">
		<cfargument name="plural" type="boolean" required="false" default=true>
		<cfscript>
			var matches = REFindNoCase("\b\w*$", arguments.string, 1, true).pos;
			if(ArrayLen(matches) && matches[ArrayLen(matches)] GT 1)
				if(arguments.plural) return Left(arguments.string, matches[ArrayLen(matches)] - 1) & Capitalize(Pluralize(Right(arguments.string, Len(arguments.string) - matches[ArrayLen(matches)] + 1)));
				else return Left(arguments.string, matches[ArrayLen(matches)] - 1) & Capitalize(Singularize(Right(arguments.string, Len(arguments.string) - matches[ArrayLen(matches)] + 1)));
			else
				if(arguments.plural) return Pluralize(arguments.string);
				else return Singularize(arguments.string);
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokeValidityCheck" access="private" returnType="void" output="false" hint="enforces the settings that spoke models must have, for now we just check that there is one singular primary key">
		<cfscript>
			if(ListLen(this.primaryKeys()) != 1) throw(type="spokeModelException", message="There was no suitable single primary key on ""#this.modelName()#"", value: #this.primaryKeys()#");
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeList" access="public" returnType="array" output="false" hint="used to return a list of all the instances of the object - used for types mainly">
		<cfargument name="editing" type="boolean" required="false" default="false" hint="whether to show all the fields or just the composites, restricted to types">
		<cfargument name="passThrough" type="struct" required="false" hint="this is passed through to the findAll arguments, where clauses can be passed through this argument">
		<cfscript>
			if(!StructKeyExists(arguments, "passThrough")) arguments.passThrough = {};
			if(arguments.editing && this.spokeIsType()){
				var findArgs = this.$spokeFindAllGenerator(argumentCollection=arguments.passThrough);
				if(Len(this.primaryKey()) && ListFindNoCase(this.columnNames(), this.primaryKey())) findArgs.select = "#this.primaryKey()# as 'key'," & ListDeleteAt(this.columnNames(), ListFindNoCase(this.columnNames(), this.primaryKey()));
				return $spokeQueryToStructs(this.findAll(argumentCollection=findArgs));
			}
			//note that $spokeFindAllGenerator() has the id in the select statement so we should be all good
			if(!StructKeyExists(APPLICATION, "spokeTypesCache")) APPLICATION.spokeTypesCache = {};
			var list = [];
			if(StructKeyExists(APPLICATION.spokeTypesCache, this.modelname()) && this.spokeIsType())
				//if cached list exists, use it!
				list = APPLICATION.spokeTypesCache[this.modelname()];
			else{//no cached list, so load it and then cache it!
				list = $spokeQueryToStructs(this.findAll(argumentCollection=this.$spokeFindAllGenerator(argumentCollection=arguments.passThrough)));
				//cache the list if type
				if(this.spokeIsType()) APPLICATION.spokeTypesCache[this.modelname()] = list;
			}
			return list;
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeColumns" access="public" returnType="array" output="false" hint="returns an ordered list of column names as they should be displayed on the front end">
		<cfscript>
			var properties = this.propertyNames();
			var workingColumnOrder = [];
			if(!StructKeyExists(variables.wheels.class.spokesettings, "ColumnOrder")) workingColumnOrder = ListToArray(properties);
			else workingColumnOrder = variables.wheels.class.spokesettings.columnOrder;
			//remove hidden properties
			if(StructKeyExists(variables.wheels.class.spokesettings, "HiddenFields")) for(var hide in ListToArray(variables.wheels.class.spokesettings.hiddenfields)){
				var index = ArrayFindNoCase(workingColumnOrder, hide);
				if(index) ArrayDeleteAt(workingColumnOrder, index);
			}
			//remove the primary key if set to remove
			if(StructKeyExists(variables.wheels.class.spokesettings, "hidePrimaryKey") && variables.wheels.class.spokesettings.hidePrimaryKey) ArrayDelete(workingColumnOrder, this.primaryKey());
			return workingColumnOrder;
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeProperties" access="public" returnType="array" output="false" hint="returns an ordered array of all settable properties (excludes calculated) that are not part of an association (that isn't a type), each element has: {name, label, value, type, required[, list(for dropdown types)]}">
		<cfscript>
			this.$spokeValidityCheck();
			var properties = this.propertyNames();
			var types = "";
			var uncachedTypes = "";
			var workingColumnOrder = this.spokeColumns();
			//remove all foreign keys in the property list
			for(var key in variables.wheels.class.associations){
				if(StructKeyExists(variables.wheels.class.spokesettings, "hiddenfields") && ListContains(variables.wheels.class.spokesettings.hiddenfields, key)) continue;
				//remove parent records, load the types
				if(variables.wheels.class.associations[key].type == "belongsTo" && (var listindex = ListFindNoCase(properties, this.$foreignKey(key)))){
					if(StructKeyExists(variables.wheels.class.associations[key], "spoketype") && variables.wheels.class.associations[key].spoketype && (!StructKeyExists(variables.wheels.class.spokesettings, "columnOrder") || ArrayContainsNoCase(variables.wheels.class.spokesettings.columnOrder, key))){
						types &= "," & key;
					}else if(var index = ArrayFindNoCase(workingColumnOrder, this.$foreignKey(key))) ArrayDeleteAt(workingColumnOrder, index);
					properties = ListDeleteAt(properties, listindex);
				}
			}
			var results = {};
			if(Len(types)){//load and deal with types if there were any
				types = ListToArray(Right(types, Len(types) - 1));//remove leading comma
				for(var i = 1; i <= ArrayLen(types); i++){
					var typemodel = model(variables.wheels.class.associations[types[i]].modelName);
					if(this.instPermissions() >= 2)
						results[this.$foreignKey(types[i])] = {
							"name": typemodel.modelname(),
							"label": typemodel.spokeDisplayName(false),
							"value": this.$spokeValue(this.$foreignKey(types[i])),
							"listing": typemodel.spokeList(),
							"type": "dropdown",
							"editable": typemodel.modelPermissions() >= 2,
							"required": variables.wheels.class.properties[this.$foreignKey(types[i])].nullable == "NO"//enforce boolean (if not nullable then required)
						};
					else
						results[this.$foreignKey(types[i])] = {
							"name": typemodel.modelname(),
							"label": typemodel.spokeDisplayName(false),
							"value": this.$associationMethod(missingMethodName = types[i], missingMethodArguments = typemodel.$spokeFindAllGenerator()).name,
							"type": "display"
						};
				}
			}
			properties = ListToArray(properties);
			for(var i = 1; i <= ArrayLen(properties); i++){
				if(StructKeyExists(variables.wheels.class.properties, properties[i]) && variables.wheels.class.properties[properties[i]].validationType == "binary") continue;//ignore binary for now
				results[properties[i]] = $spokeProperty(properties[i]);
				results[properties[i]]["value"] = this.$spokeValue(properties[i]);
				if(results[properties[i]].type == "boolean") results[properties[i]].value = ((results[properties[i]].value == "")?false:((results[properties[i]].value)?true:false));//force bits, yes/no etc to be true false values to work with angularjs checkbox settings
				if(results[properties[i]].type == "datetime" || results[properties[i]].type == "date" || results[properties[i]].type == "time") results[properties[i]]["value"] = '#DateFormat(results[properties[i]]["value"], APPLICATION.spokeDateFormat)# #TimeFormat(results[properties[i]]["value"], APPLICATION.spokeTimeFormat)#';
			}
			var returnArray = [];
			for(var i = 1; i <= ArrayLen(workingColumnOrder); i++) if(StructKeyExists(results, workingColumnOrder[i])) ArrayAppend(returnArray, results[workingColumnOrder[i]]);
			return returnArray;
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeChildren" access="public" returnType="array" output="false" hint="returns information on all of the children (hasMany and hasOne associations); keys, names and descriptions only returned from the tables">
		<cfscript>
			return spokeAssociations(true);
		</cfscript>
	</cffunction>
	<cffunction name="spokeParent" access="public" returnType="array" output="false" hint="returns information on all of the parents (belongsTo associations); keys, names and descriptions only returned from the tables">
		<cfscript>
			return spokeAssociations(false);
		</cfscript>
	</cffunction>
	<cffunction name="spokeAssociations" access="public" returnType="any" output="false" hint="returns information on all of the children (hasMany and hasOne associations) or parents (belongsTo associations) as an array or both as 2 arrays in a struct; keys, names and descriptions only returned from the tables">
		<cfargument name="childrenOnly" type="boolean" required="false" hint="True returns children, false parents, exclude for both">
		<cfscript>
			var result = [];
			if(!StructKeyExists(arguments, "childrenOnly")) result = {"children": [], "parents": []};
			for(var key in variables.wheels.class.associations){
				//execute ONLY WHEN NECESSARY - both OR parents only OR children only
				if((StructKeyExists(variables.wheels.class.associations[key], "spoketype") && !variables.wheels.class.associations[key].spoketype)
					|| !StructKeyExists(arguments, "childrenOnly")
					|| (!arguments.childrenOnly && variables.wheels.class.associations[key].type == "belongsTo")
					|| (arguments.childrenOnly
						&& (variables.wheels.class.associations[key].type == "hasOne" || variables.wheels.class.associations[key].type == "hasMany"))){
					if(StructKeyExists(variables.wheels.class.associations[key], "shortcut") && Len(variables.wheels.class.associations[key].shortcut)){
						//setup
						var returnStruct = {"modelkey": Singularize(variables.wheels.class.associations[key].shortcut)};
						var shortcutModel = model(Singularize(variables.wheels.class.associations[key].shortcut));
						returnStruct["permissions"] = shortcutModel.modelPermissions();
						if(returnStruct.permissions == 1) continue;
						//allways hasMany so pluralize
						returnStruct["name"] = (StructKeyExists(variables.wheels.class.associations[key], "spokename"))
							? Capitalize($spokePluralize(variables.wheels.class.associations[key].spokename))
							: shortcutModel.spokeDisplayName();
						
						if(Len(shortcutModel.externalEditorURL())) returnStruct["editor"] = shortcutModel.externalEditorURL();
						if(Len(shortcutModel.externalListURL())){
							returnStruct["listing"] = shortcutModel.externalListURL();
							returnStruct["data"] = [{"name": "Click to view...", "description": ""}];
						}else //the $associationMethod from onMissingMethod quite happily handles all the different types of calls we need - for example a hasMany called people will call in essence model.people()
							returnStruct["data"] = $spokeQueryToStructs(this.$associationMethod(
								missingMethodName = variables.wheels.class.associations[key].shortcut,
								missingMethodArguments = shortcutModel.$spokeFindAllGenerator()
							));
					}else{
						//setup
						var returnStruct = {"modelkey": variables.wheels.class.associations[key].modelname};
						var childModel = model(variables.wheels.class.associations[key].modelname);
						returnStruct["permissions"] = childModel.modelPermissions();
						if(childModel.spokeIsType() || returnStruct.permissions == 0) continue;//types do not show up in associations, also do not show any that the current permissions cannot read
						
						var pluralizeName = !((StructKeyExists(arguments, "childrenOnly") && !arguments.childrenOnly) || variables.wheels.class.associations[key].type == "belongsTo");
						returnStruct["name"] = 
							(StructKeyExists(variables.wheels.class.associations[key], "spokename"))
								?Capitalize($spokePluralize(variables.wheels.class.associations[key].spokename, pluralizeName))
								:childModel.spokeDisplayName(pluralizeName);
						//need some kind of optimisation? different display for REALLY BIG lists - only if someone complains.
						//returnStruct["count"] = model.$associationMethod(missingMethodName = key & "Count", missingMethodArguments = {}); for now angular can handle this part
						if(Len(childModel.externalEditorURL())) returnStruct["editor"] = childModel.externalEditorURL();
						if(Len(childModel.externalListURL())){
							returnStruct["listing"] = childModel.externalListURL();
							returnStruct["data"] = [{"name": "Click to view...", "description": ""}];
						}else //the $associationMethod from onMissingMethod quite happily handles all the different types of calls we need - for example a hasMany called people will call in essence model.people()
							returnStruct["data"] = $spokeQueryToStructs(this.$associationMethod(missingMethodName = key, missingMethodArguments = childModel.$spokeFindAllGenerator()));
					}
					
					if(StructKeyExists(arguments, "childrenOnly")) ArrayAppend(result, returnStruct);
					else if(variables.wheels.class.associations[key].type == "belongsTo") ArrayAppend(result.parents, returnStruct);
					else ArrayAppend(result.children, returnStruct);
				}
			}
			return result;
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeSearch" access="public" returnType="struct" output="false" hint="takes in a search value, an optional record limit and returns an array of spoke set data. The model must have at least ONE column that has a validation type of string - ie text/varchar, usually nameColumn">
		<cfargument name="searchValue" required="true" type="string" hint="the string to search within the fields">
		<cfargument name="maxRows" required="false" type="numeric" default=10 hint="Maximum rows to return, default is based on sensible height of a box and scrollability and just a random number I liked at the time">
		<cfscript>
			if(!Len(arguments.searchValue)) return {"totalcount": 0, "query": []};//return nothing if no search value
			if(!StructKeyExists(SESSION, "spokecache")) SESSION.spokecache = {};
			var whereClause = "";
			if(StructKeyExists(variables.wheels.class.spokesettings, "searchColumns") && Len(variables.wheels.class.spokesettings.searchColumns)){
				var columnArray = ListToArray(variables.wheels.class.spokesettings.searchColumns);
				for(var i = 1; i <= ArrayLen(columnArray); i++){
					if(StructKeyExists(variables.wheels.class.properties, columnArray[i]) && variables.wheels.class.properties[columnArray[i]].validationType == "string"){//only filter on valid, non calculated, string fields.
						whereClause &= " OR #variables.wheels.class.properties[columnArray[i]].column# LIKE '%#arguments.searchValue#%'";
					}
				}
			}
			var modelname = this.modelname();
			if(!StructKeyExists(SESSION.spokecache, modelname)
				|| !StructKeyExists(APPLICATION, "spokeSearchRefresh")//first query call
				|| !StructKeyExists(APPLICATION.spokeSearchRefresh, modelname)//no last refresh time - first time called or model was saved so refreshed
				|| DateDiff("n", APPLICATION.spokeSearchRefresh[modelname], NOW()) >= MAX(5, APPLICATION.spokeSearchTimeout)){//time last refreshed was too long ago
				//cache the user specific query, not in application due to userFilter method
				if(!StructKeyExists(APPLICATION, "spokeSearchRefresh")) APPLICATION.spokeSearchRefresh = {modelname : NOW()};
				else APPLICATION.spokeSearchRefresh[modelname] = NOW();
				SESSION.spokecache[modelname] = this.findAll(argumentCollection=this.$spokeFindAllGenerator(maxRows=arguments.maxRows, orderBy=(StructKeyExists(variables.wheels.class.spokesettings, "searchOrderBy"))?variables.wheels.class.spokesettings.searchOrderBy:""));
			}
			var cachedquery = SESSION.spokecache[modelname];
		</cfscript>
		<cfquery dbtype="query" name="result">
			SELECT * FROM cachedquery
			WHERE false
				<cfif 
					(StructKeyExists(variables.wheels.class.spokesettings, "NameColumn") && StructKeyExists(variables.wheels.class.calculatedProperties, variables.wheels.class.spokesettings.NameColumn))
					OR StructKeyExists(variables.wheels.class.spokesettings, "NameColumn")
					OR ListContainsNoCase(this.propertyNames(), "name")>
					OR name LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#arguments.searchValue#%">
				</cfif>
			<cfif StructKeyExists(variables.wheels.class.spokesettings, "DescColumn")>
				OR description LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#arguments.searchValue#%">
			</cfif>
			<cfif StructKeyExists(variables.wheels.class.spokesettings, "searchColumns") && Len(variables.wheels.class.spokesettings.searchColumns)>
				<cfset var searchColumns = ListToArray(variables.wheels.class.spokesettings.searchColumns)>
				<cfloop index="i" from="1" to="#ArrayLen(searchColumns)#" step="1">
					OR #searchColumns[i]# LIKE <cfqueryparam CFSQLType="CF_SQL_VARCHAR" value="%#arguments.searchValue#%">
				</cfloop>
			</cfif>
		</cfquery>
		<cfreturn {
			"totalcount": result.recordcount,
			"query": $spokeQueryToStructs(result, arguments.maxRows)
		}>
	</cffunction>
	
	<cffunction name="$spokeProperty" access="public" returnType="struct" hint="Calculates all static values about a passed in property">
		<cfargument name="property" type="string" required="true" hint="the name of the property to generate for">
		<cfscript>
			if(this.instPermissions() < 2) return {
				"label": Capitalize(
					(arguments.property == this.primarykey())?"key":
					(StructKeyExists(variables.wheels.class.mapping, arguments.property) && StructKeyExists(variables.wheels.class.mapping[arguments.property], "label"))
					?
						variables.wheels.class.mapping[arguments.property].label
					:
						arguments.property),
				"type": "display",
				"description": (StructKeyExists(variables.wheels.class.mapping, arguments.property) && StructKeyExists(variables.wheels.class.mapping[arguments.property], "spokedesc"))?variables.wheels.class.mapping[arguments.property].spokedesc:"",
				"name": (arguments.property == this.primarykey())?"key":arguments.property,
				"required": false
			};
			var result = {"label": Capitalize((arguments.property == this.primarykey())?"key":arguments.property)};//defaults to the columnname
			
			//set types and inherently anything we need off the class.properties struct
			//types are: display, integer, string, datetime, boolean, float, binary, array(display only), struct(display only)
			if(StructKeyExists(variables.wheels.class.properties, arguments.property)){
				//generate defaults
				if(variables.wheels.class.properties[arguments.property].type == "CF_SQL_DATE") result["type"] = "date";
				else if(variables.wheels.class.properties[arguments.property].type == "CF_SQL_TIME") result["type"] = "time";
				else result["type"] = variables.wheels.class.properties[arguments.property].validationType;
				
				result["required"] = variables.wheels.class.properties[arguments.property].nullable == "NO";//enforce boolean representation of required based on nullable database value - please note that if a boolean field is required it must be checked...
			}else if(StructKeyExists(variables.wheels.class.calculatedProperties, arguments.property)) result["type"] = "display";
			else result["type"] = "string";//default to string representation
			
			//spoke settings set through property call
			if(StructKeyExists(variables.wheels.class.mapping, arguments.property)){
				//set the label
				if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "label")) result["label"] = Capitalize(variables.wheels.class.mapping[arguments.property].label)
				//check for spoke settings
				if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "spokeoptions") && isArray(variables.wheels.class.mapping[arguments.property].spokeoptions)){
					result["listing"] = variables.wheels.class.mapping[arguments.property].spokeoptions;
					result["type"] = "dropdown";
				}else if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "spoketype") && variables.wheels.class.mapping[arguments.property].spoketype != "dropdown") result["type"] = variables.wheels.class.mapping[arguments.property].spoketype;
				if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "spokeplaceholder")) result["placeholder"] = variables.wheels.class.mapping[arguments.property].spokeplaceholder;
				if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "spoketip")) result["tip"] = variables.wheels.class.mapping[arguments.property].spoketip;
				if(StructKeyExists(variables.wheels.class.mapping[arguments.property], "spokedesc")) result["description"] = variables.wheels.class.mapping[arguments.property].spokedesc;
			}
			result["name"] = (arguments.property == this.primarykey())?"key":arguments.property;
			return result;
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokeFindAllGenerator" access="public" returnType="struct" hint="Generates the select sql and other settings for listing all instances of a model, all findall arguments are passed through (except select and returnAs arguments), essentially modifies the arguments struct and returns it">
		<cfargument name="callbacks" type="boolean" required="false" default=false hint="prevent callbacks as these have a tendancy to mess up when we don't return all the correct columns - can be overriden">
		<cfscript>
			this.$spokeValidityCheck();
			var filters = this.listFilter();
			if(StructKeyExists(filters, "where") && StructKeyExists(arguments, "where")) arguments.where = "(#arguments.where#) AND (#filters.where#)";
			StructAppend(arguments, filters, false);//arguments take priority over filter, as all arguments should be internal settings only.
			arguments["returnAs"] = "query";//don't override this one
			if(StructKeyExists(variables.wheels.class.spokesettings, "$selectSQL") && Len(variables.wheels.class.spokesettings.$selectSQL)){//basically won't change during the life of a model, also allows for overriding but make sure key, name and description are present
				arguments["select"] = variables.wheels.class.spokesettings.$selectSQL;
				return arguments;
			}
			arguments["select"] = "#this.tableName()#.#this.primaryKey()# as 'key'";//note that spoke cannot work with composite keys ATM
			//calculate name column
			if(StructKeyExists(variables.wheels.class.spokesettings, "NameColumn") && StructKeyExists(variables.wheels.class.calculatedProperties, variables.wheels.class.spokesettings.NameColumn)) arguments.select &= ",(#variables.wheels.class.calculatedProperties[variables.wheels.class.spokesettings.NameColumn].sql#) as name";
			else if(StructKeyExists(variables.wheels.class.spokesettings, "NameColumn")) arguments.select &= ",(#variables.wheels.class.spokesettings.NameColumn#) as name";
			else if(StructKeyExists(variables.wheels.class.calculatedProperties, "name")) arguments.select &= ",(#variables.wheels.class.calculatedProperties.name.sql#) as name";
			else if(ArrayFindNoCase(this.columns(), "name")) arguments.select &= ",#this.tableName()#.name";
			else throw(type="spokeModelException", message="There was no suitable Name field on the model ""#this.modelName()#"", try setting it manually in spokeInit(). Spoke Settings: #StructKeyList(variables.wheels.class.spokesettings)#");
			
			//calculate description column, if not, set to blank
			if(StructKeyExists(variables.wheels.class.spokesettings, "DescColumn") && StructKeyExists(variables.wheels.class.calculatedProperties, variables.wheels.class.spokesettings.DescColumn)) arguments.select &= ",(#variables.wheels.class.calculatedProperties[variables.wheels.class.spokesettings.DescColumn].sql#) as description";
			else if(StructKeyExists(variables.wheels.class.spokesettings, "DescColumn")) arguments.select &= ",(#variables.wheels.class.spokesettings.DescColumn#) as description";
			else{
				var calcName = StructFindOneOf(variables.wheels.class.calculatedProperties, "description,desc,note,notes");
				if(Len(calcName)) arguments.select &= ",(#variables.wheels.class.calculatedProperties[calcName].sql#) as description";
				else{
					var colName = ArrayFindOneOf(this.columns(), "description,desc,note,notes");
					if(Len(colName)) arguments.select &= ",#this.tableName()#.#colName# AS description";
					else arguments.select &= ",'' as description";
				}
			}
			if(StructKeyExists(variables.wheels.class.spokesettings, "searchColumns") && Len(variables.wheels.class.spokesettings.searchColumns)) arguments.select &= "," & variables.wheels.class.spokesettings.searchColumns;
			variables.wheels.class.spokesettings.$selectSQL = arguments.select;
			return arguments;
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokeQueryToStructs" access="private" returnType="array" output="false" hint="prepares a query to be sent spoke style! Largely includes converting it to an array of structs so it plays nicely with angular">
		<cfargument name="query" required="true" type="query" hint="the query to convert">
		<cfargument name="limit" required="false" type="numeric" hint="an optional limit for the results">
		<cfscript>
			if(arguments.query.recordcount == 0) return [];
			//used to use $serializeQueryToStructs, but we do NOT want to initialise objects
			var result = [];
			for (var i=1; i <= arguments.query.recordCount && (StructKeyExists(arguments, "limit") && arguments.limit > 0 && i <= arguments.limit); i++) ArrayAppend(result, $spokeQueryRowToStruct(arguments.query, i));
			return result;
		</cfscript>
	</cffunction>
	
	<cffunction name="$spokeQueryRowToStruct" access="private" returnType="struct" output="false" hint="converts a query row to a struct with the addition of obscuring the keys if required">
		<cfargument name="query" required="true" type="query" hint="the query that contains the data">
		<cfargument name="row" required="true" type="numeric" hint="the query row to convert">
		<cfscript>
			var columnNames = ListToArray(query.columnList);
			var metadata = GetMetadata(query);
			var row = {};
			for(var i = 1; i <= ArrayLen(columnNames); i++){
				if(columnNames[i] == 'key') row[columnNames[i].toLowerCase()] = arguments.query[columnNames[i]][arguments.row];
				if(metadata[i].typeName == "TIMESTAMP" && isDate(arguments.query[columnNames[i]])) row[columnNames[i].toLowerCase()] = '#DateFormat(arguments.query[columnNames[i]][arguments.row], APPLICATION.spokeDateFormat)# #TimeFormat(arguments.query[columnNames[i]][arguments.row], APPLICATION.spokeTimeFormat)#';//using ISO 8601 format with timezone
				else row[columnNames[i].toLowerCase()] = arguments.query[columnNames[i]][arguments.row];
			}
			return row;
		</cfscript>
	</cffunction>
	
	<!--- convenience functions --->
	
	<cffunction name="$spokeValue" access="public" output="false" returnType="any" hint="Checks if the property is defined and returns it if true">
		<cfargument name="property" required="true" type="string">
		<cfscript>
			if(StructKeyExists(this, arguments.property)) return this[arguments.property];
			else return "";//null value
		</cfscript>
	</cffunction>
	
	<cffunction name="$foreignKey" access="public" returnType="string" output="false" hint="Returns either the foreignkey, if set, or the calculated default">
		<cfargument name="associationname" type="string" required="true" hint="the association that we are calculating the foreignkey name">
		<cfscript>
			var association = variables.wheels.class.associations[arguments.associationname];
			return ((association.foreignKey == "")?association.modelname & "id":association.foreignKey);
		</cfscript>
	</cffunction>
	
	<cffunction name="modelName" access="public" returnType="string" output="false" hint="convenience function that returns the wheels model name">
		<cfscript>
			return variables.wheels.class.modelname;
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeIsType" access="public" returnType="boolean" output="false">
		<cfscript>
			return StructKeyExists(variables.wheels.class.spokesettings, "istype") && variables.wheels.class.spokesettings.istype;
		</cfscript>
	</cffunction>
	
	<cffunction name="externalListURL" access="public" returnType="string" output="false" hint="returns the URL for this to be show as a list externally">
		<cfscript>
			return (StructKeyExists(variables.wheels.class.spokesettings, "listRoute") && isStruct(variables.wheels.class.spokesettings.listRoute))?urlFor(argumentCollection=variables.wheels.class.spokesettings.listRoute, key="spokekeyplaceholder"):"";
		</cfscript>
	</cffunction>
	
	<cffunction name="externalEditorURL" access="public" returnType="string" output="false" hint="returns the URL for this to be edited externally">
		<cfscript>
			return (StructKeyExists(variables.wheels.class.spokesettings, "editorRoute") && isStruct(variables.wheels.class.spokesettings.editorRoute))?urlFor(argumentCollection=variables.wheels.class.spokesettings.editorRoute, key="spokekeyplaceholder"):"";
		</cfscript>
	</cffunction>
	
	<cffunction name="spokeURL" access="public" returnType="string" output="false" hint="returns the URL for this to be edited/viewed in the SpokeDM">
		<cfscript>
			return urlFor(controller="spokes", modelkey=this.modelName(), key=this.key());
		</cfscript>
	</cffunction>
	
	<!--- overriding some cfwheels functions to add functionality --->
	
	<cffunction name="property" returntype="void" access="public" output="false" hint="Use this method to map an object property to either a table column with a different name than the property or to a SQL expression. You only need to use this method when you want to override the default object relational mapping that Wheels performs."
		examples=
		'
			<!--- Tell Wheels that when we are referring to `firstName` in the CFML code, it should translate to the `STR_USERS_FNAME` column when interacting with the database instead of the default (which would be the `firstname` column) --->
			<cfset property(name="firstName", column="STR_USERS_FNAME")>
	
			<!--- Tell Wheels that when we are referring to `fullName` in the CFML code, it should concatenate the `STR_USERS_FNAME` and `STR_USERS_LNAME` columns --->
			<cfset property(name="fullName", sql="STR_USERS_FNAME + '' '' + STR_USERS_LNAME")>
	
			<!--- Tell Wheels that when displaying error messages or labels for form fields, we want to use `First name(s)` as the label for the `STR_USERS_FNAME` column --->
			<cfset property(name="firstName", label="First name(s)")>
	
			<!--- Tell Wheels that when creating new objects, we want them to be auto-populated with a `firstName` property of value `Dave` --->
			<cfset property(name="firstName", defaultValue="Dave")>
		'
		categories="model-initialization,miscellaneous" chapters="object-relational-mapping" functions="columnNames,dataSource,propertyNames,table,tableName">
		<cfargument name="name" type="string" required="true" hint="The name that you want to use for the column or SQL function result in the CFML code.">
		<cfargument name="column" type="string" required="false" default="" hint="The name of the column in the database table to map the property to.">
		<cfargument name="sql" type="string" required="false" default="" hint="A SQL expression to use to calculate the property value.">
		<cfargument name="label" type="string" required="false" default="" hint="A custom label for this property to be referenced in the interface and error messages.">
		<cfargument name="defaultValue" type="string" required="false" hint="A default value for this property.">
		<!--- here are the additional spoke arguments --->
		<cfargument name="spokeType" required="false" type="string" hint="A string that overrides the type set in the database, can be one of; display, integer, string, datetime, date, time, boolean, float, binary, dropdown. NOTE: that binary is currently not supported as a display unless you implement it in the formBase.cfm. the dropdown option must also have the spokeOptions setting included.">
		<cfargument name="spokeOptions" required="false" type="array" hint="an array of strings that function as the options for a dropdown, or an array of {key, name} structs">
		<cfargument name="spokePlaceholder" required="false" type="string" hint="A string that is displayed as the placeholder on the form.">
		<cfargument name="spokeTip" required="false" type="string" hint="A string that is displayed next to the label as a tip on the form.">
		<cfscript>
			// validate setup
			if (Len(arguments.column) and Len(arguments.sql))
				$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="You cannot specify both a column and a sql statement when setting up the mapping for this property.");
			if (Len(arguments.sql) and StructKeyExists(arguments, "defaultValue"))
				$throw(type="Wheels", message="Incorrect Arguments", extendedInfo="You cannot specify a default value for calculated properties.");
	
			// create the key
			if (!StructKeyExists(variables.wheels.class.mapping, arguments.name))
				variables.wheels.class.mapping[arguments.name] = {};
	
			if (Len(arguments.column))
			{
				variables.wheels.class.mapping[arguments.name].type = "column";
				variables.wheels.class.mapping[arguments.name].value = arguments.column;
			}
	
			if (Len(arguments.sql))
			{
				variables.wheels.class.mapping[arguments.name].type = "sql";
				variables.wheels.class.mapping[arguments.name].value = arguments.sql;
			}
	
			if (Len(arguments.label))
				variables.wheels.class.mapping[arguments.name].label = arguments.label;
	
			if (StructKeyExists(arguments, "defaultValue"))
				variables.wheels.class.mapping[arguments.name].defaultValue = arguments.defaultValue;
			
			//spoke logic
			if(StructKeyExists(arguments, "spokeoptions") && ArrayLen(arguments.spokeoptions)){
				if(isStruct(arguments.spokeoptions[1])) variables.wheels.class.mapping[arguments.name].spokeoptions = arguments.spokeoptions;
				else{
					variables.wheels.class.mapping[arguments.name].spokeoptions = [];
					for(var item in arguments.spokeoptions) ArrayAppend(variables.wheels.class.mapping[arguments.name].spokeoptions, {"key": LCase(item), "name": item});
				}
			}
			if(StructKeyExists(arguments, "spoketype")) variables.wheels.class.mapping[arguments.name].spoketype = arguments.spoketype;
			if(StructKeyExists(arguments, "spokeplaceholder")) variables.wheels.class.mapping[arguments.name].spokeplaceholder = arguments.spokeplaceholder;
			if(StructKeyExists(arguments, "spoketip")) variables.wheels.class.mapping[arguments.name].spoketip = arguments.spoketip;
			if(StructKeyExists(arguments, "spokedesc")) variables.wheels.class.mapping[arguments.name].spokedesc = arguments.spokedesc;
		</cfscript>
	</cffunction>
	
	<cffunction name="$initModelClass" returntype="any" access="public" output="false" hint="override here to ensure existence of the spokesettings struct">
		<cfscript>
			var result = super.$initModelClass(argumentCollection=arguments);
			if(!StructKeyExists(variables.wheels.class, "spokesettings")) variables.wheels.class.spokesettings = {};
			return result;
		</cfscript>
	</cffunction>
	
	<!--- Testing - static functions until we can use tableless --->
	
	<cffunction name="spokeTestDisplayProperties" access="public" output="false" returnType="struct">
		<cfargument name="required" type="boolean" required="false" default=true>
		<cfargument name="permissions" type="boolean" required="false" default=4>
		<cfscript>
			return {
				"name": "Test Screen",//each property contains {name, label, value, type[, list(for dropdown types)][, placeholder][, required][, tip]}
				"properties": [//display, integer, string, datetime, date, time, boolean, float, binary(unsupported), array(display only), struct(display only), dropdown, text, email, website, password
					{
						"name": "display",
						"label": "Display",
						"value": "Text to try and display<br/>Should have line break and <b>bold</b>",
						"type": "display",
						"required": arguments.required,
						"placeholder": "Display Placeholder",
						"tip": "Display Tip"
					},
					{
						"name": "integer",
						"label": "Integer",
						"value": 120,
						"type": "integer",
						"required": arguments.required,
						"placeholder": "Integer Placeholder",
						"tip": "Integer Tip"
					},
					{
						"name": "string",
						"label": "String",
						"value": "Test String",
						"type": "string",
						"required": arguments.required,
						"placeholder": "String Placeholder",
						"tip": "String Tip"
					},
					{
						"name": "datetime",
						"label": "Date/Time",
						"value": '#DateFormat(NOW(), APPLICATION.spokeDateformat)# #TimeFormat(NOW(), APPLICATION.spokeTimeformat)#',
						"type": "datetime",
						"required": arguments.required,
						"placeholder": "Date/Time Placeholder",
						"tip": "Date/Time Tip"
					},
					{
						"name": "date",
						"label": "Date",
						"value": '#DateFormat(NOW(), APPLICATION.spokeDateformat)#',
						"type": "date",
						"required": arguments.required,
						"placeholder": "Date Placeholder",
						"tip": "Date Tip"
					},
					{
						"name": "time",
						"label": "Time",
						"value": '#TimeFormat(DateAdd("h", -4, NOW()), APPLICATION.spokeTimeformat)#',
						"type": "time",
						"required": arguments.required,
						"placeholder": "Time Placeholder",
						"tip": "Time Tip"
					},
					{
						"name": "boolean",
						"label": "Boolean",
						"value": true,
						"type": "boolean",
						"required": arguments.required,
						"placeholder": "Boolean Placeholder",
						"tip": "Boolean Tip"
					},
					{
						"name": "float",
						"label": "Float",
						"value": 1.234,
						"type": "float",
						"required": arguments.required,
						"placeholder": "Float Placeholder",
						"tip": "Float Tip"
					},
					{
						"name": "dropdown",
						"label": "Dropdown",
						"value": 2,
						"type": "dropdown",
						"listing": [{"key":1, "name":"Other"},{"key":2, "name":"Test Selected"},{"key":3, "name":"Test Not-Selected"}],
						"editable": true,
						"required": arguments.required,
						"placeholder": "Dropdown Placeholder",
						"tip": "Dropdown Tip"
					},
					{
						"name": "text",
						"label": "Text",
						"value": "Test a whole bunch of text, in theory we should have multi-
line but not sure how well that works.",
						"type": "text",
						"required": arguments.required,
						"placeholder": "Text Placeholder",
						"tip": "Text Tip"
					},
					{
						"name": "email",
						"label": "Email",
						"value": "Test@email.com",
						"type": "email",
						"required": arguments.required,
						"placeholder": "Email Placeholder",
						"tip": "Email Tip"
					},
					{
						"name": "website",
						"label": "Website",
						"value": "http://www.test.com",
						"type": "website",
						"required": arguments.required,
						"placeholder": "Website Placeholder",
						"tip": "Website Tip"
					},
					{
						"name": "password",
						"label": "Password",
						"value": "Test Password",
						"type": "password",
						"required": arguments.required,
						"placeholder": "Password Placeholder",
						"tip": "Password Tip"
					}
				],
				"associations": {},
				"permissions": arguments.permissions,
				"errors": []
			};
		</cfscript>
	</cffunction>
	
</cfcomponent>