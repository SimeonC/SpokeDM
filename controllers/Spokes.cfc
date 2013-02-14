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

You should have received a copy of the GNU Affero General Public along with SpokeDM.  
If not, see <http://www.gnu.org/licenses/>.
--->
<cfcomponent extends="Controller">
	
	<cffunction name="init">
		<cfscript>
			provides("html,json");
		</cfscript>
	</cffunction>
	
	<cffunction name="index">
		<cfscript>
			StructDelete(APPLICATION, "spokeTypesCache");
			//if you want to only allow certain users access to the SpokeDM screens - Do it Here!
		</cfscript>
	</cffunction>
	
	<cffunction name="searchajax">
		<cfscript>
			params.format = 'json';//this function will ALWAYS be called via ajax and should Always return json.
			if(StructKeyExists(APPLICATION, "spokesearch") && ArrayLen(APPLICATION.spokesearch)){
				if(request.cgi.request_method == "POST"){
					var req = toString(getHttpRequestData().content);
					if (isJSON(req)) StructAppend(params, deserializeJSON(req), true);
					if(StructKeyExists(params, "query")){
						var result = {};
						if(StructKeyExists(params, "key") && params.key <= ArrayLen(APPLICATION.spokesearch) && params.key > 0) result = model(APPLICATION.spokesearch[params.key]).spokeSearch(params.query, 20);
						return renderWith(result);
					}
				}
				//default logic, the get/query
				var result = [];
				for(var i = 1; i <= ArrayLen(APPLICATION.spokesearch); i++){
					var axleModel = model(APPLICATION.spokesearch[i]);
					var axle = {'active': true, 'key': i, 'title': axleModel.spokeDisplayName(), 'modelkey': APPLICATION.spokesearch[i]};
					ArrayAppend(result, axle);
				}
				return renderWith(result);
			}
			return RenderWith([]);
		</cfscript>
	</cffunction>
	
	<cffunction name="linkajax">
		<cfscript>
			params.format = 'json';//this function will ALWAYS be called via ajax and should Always return json.
			if(!spokeCheckLogin()){//see base controller
				return renderWith({"loginerror":"You have been logged out."});
			}
			if(!StructKeyExists(params, "modelkey") || !StructKeyExists(params, "key") || !StructKeyExists(params, "parent")) return renderWith({"errors": [{"message": "ERROR!! Cannot compute invalid values, please try again..."}]});
			//default is to return the GET data
			return renderWith(model(params.modelkey).findByKey(params.key).spokeRelinkParent(params.parent));
		</cfscript>
	</cffunction>
	
	<cffunction name="dataajax">
		<cfscript>
			var loc = {};
			params.format = 'json';//this function will ALWAYS be called via ajax and should Always return json.
			if(!spokeCheckLogin()){//see base controller
				return renderWith({"loginerror":"You have been logged out."});
			}
			if(StructKeyExists(params, "modelkey") && params.modelkey == "test") return renderWith(CreateObject("component","/models/Spokemodel").spokeTestDisplayProperties(argumentCollection=params));
			if(!StructKeyExists(params, "modelkey") || (!StructKeyExists(params, "key") && request.cgi.request_method != "GET")) return renderWith({"errors": [{"message": "ERROR!! Cannot compute invalid values, please try again..."}]});
			loc.model = CreateObject("component","/models/Spokemodel").spokeAttemptModel(params.modelkey);
			if(!isStruct(loc.model)) return renderWith({"errors": [{"message": "This is not the spoke you are looking for... (We can't find it)"}]});
			if(StructKeyExists(params, "list") && params.list) return renderWith(loc.model.spokeTypeLoad());
			loc.item = false;
			loc.modelPerms = loc.model.modelPermissions();
			if(request.cgi.request_method == "POST"){
				loc.req = toString(getHttpRequestData().content);	
				if (isJSON(loc.req)) StructAppend(params, deserializeJSON(loc.req), true);
				if(params.key == 'new'){
					if(loc.modelPerms < 3) return renderWith({'errors': [{"message": "You do not have permissions to create a new #model.displayName()#"}]});
					loc.item = loc.model.create(params.data);
				}else{
					loc.item = loc.model.spokeAttemptFindByKey(params.key);
					if(isStruct(loc.item)){
						if(Min(loc.item.instPermissions(), loc.modelPerms) < 2) return renderWith({'errors': [{"message": "You do not have permissions to save this #loc.model.displayName()#"}]});
						loc.item.setProperties(params.origdata);
						if(!loc.item.valid()) return renderWith({'errors': loc.item.allErrors()});
						if(!(StructKeyExists(params, "dirtyforce") && params.dirtyforce) && loc.item.hasChanged()) return renderWith({"dirtywarnings": loc.item.allChanges()});
						loc.item.update(params.data);
					}
					else return renderWith({"errors": [{"message": "This is not the spoke you are looking for... (We can't find it)"}]});
				}
				return renderWith({'errors': loc.item.allErrors(), 'key': loc.item.key()});
			}else if(request.cgi.request_method == "GET"){
				if(loc.modelPerms <= 0) return renderWith({"errors": [{"message": "Maybe you wanted the other moon? (You can't view this)"}]});
				if(!StructKeyExists(params, "key") || params.key == 'list') return renderWith(loc.model.spokeListLoad());
				if(params.key == 'new') return renderWith(loc.model.spokeNew());
				else loc.item = loc.model.spokeAttemptFindByKey(params.key);
				loc.perms = 0;
				if(!isStruct(loc.item) || (loc.perms = Min(loc.modelPerms, loc.item.instPermissions())) <= 0) return renderWith({"errors": [{"message": "This is not the spoke you are looking for... (We can't find it)"}]});
				if(StructKeyExists(params, "delete") && params.delete){
					if(loc.perms < 4) return renderWith({'errors': [{"message": "You do not have permissions to delete this #loc.model.displayName()#"}]});
					try{
						loc.item.delete();
						return renderWith({'errors': loc.item.allErrors()});
					}catch(any e){
						return renderWith({'errors': [{"message": "An error occured deleting the #loc.model.spokeDisplayName(false)# object, try removing all child objects first."}]});	
					}
				}
				if(StructKeyExists(params, "newkey")) return renderWith(loc.item.spokeNew(params.newkey));
			}
			//default is to return the GET data
			return renderWith(loc.item.spokeDataLoad());
		</cfscript>
	</cffunction>
	
	<cffunction name="inputswitch">
		<cfscript>
			//we shouldn't be accessing this as it is essentially an angular template, used for code compartmentalisation
			return redirectTo(action="index");
		</cfscript>
	</cffunction>
	
</cfcomponent>
