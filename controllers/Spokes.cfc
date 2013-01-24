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
	
	<cffunction name="dataajax">
		<cfscript>
			params.format = 'json';//this function will ALWAYS be called via ajax and should Always return json.
			if(!spokeCheckLogin()){//see base controller
				return renderWith({"loginerror":"You have been logged out."});
			}
			if(StructKeyExists(params, "modelkey") AND params.modelkey EQ "test") return renderWith(CreateObject("component","/models/SpokeModel").spokeTestDisplayProperties(argumentCollection=params));
			if(StructKeyExists(params, "modelkey") && StructKeyExists(params, "list") && params.list) return renderWith(model(params.modelkey).spokeTypeLoad());
			if(!StructKeyExists(params, "modelkey") || (!StructKeyExists(params, "key") && request.cgi.request_method NEQ "GET")) return renderWith({"errors": [{"message": "The parameters sent are incorrect, please try again..."}]});
			var model = model(params.modelkey);
			var item = false;
			if(request.cgi.request_method EQ "POST"){
				var req = toString(getHttpRequestData().content);	
				if (isJSON(req)) StructAppend(params, deserializeJSON(req), true);
				if(params.key EQ 'new') item = model.create(params.data);
				else{
					item = model.findByKey(params.key);
					if(isStruct(item)){
						item.setProperties(params.origdata);
						if(!(StructKeyExists(params, "dirtyforce") && params.dirtyforce) && item.hasChanged()) return renderWith({"dirtywarnings": item.allChanges()});
						item.update(params.data);
					}
					else return renderWith({"errors": [{"message": "This is not the spoke you are looking for..."}]});
				}
				return renderWith({'errors': item.allErrors(), 'key': item.key()});
			}else if(request.cgi.request_method EQ "GET"){
				if(!StructKeyExists(params, "key") || params.key EQ 'list') return renderWith(model.spokeListLoad());
				item = model.findByKey(params.key);
				if(!isStruct(item)) return renderWith({"errors": [{"message": "This is not the spoke you are looking for..."}]});
				if(StructKeyExists(params, "delete") && params.delete){
					try{
						item.delete();
						return renderWith({'errors': item.allErrors()});
					}catch(any e){
						return renderWith({'errors': [{"message": "An error occured deleting the #model.spokeDisplayName(false)# object, try removing all child objects first."}]});	
					}
				}
				if(StructKeyExists(params, "newkey")) return renderWith(item.spokeNew(params.newkey));
			}
			//default is to return the GET data
			return renderWith(item.spokeDataLoad());
		</cfscript>
	</cffunction>
	
	<cffunction name="formBase">
		<cfscript>
			//we shouldn't be accessing this as it is essentially an angular template, used for code compartmentalisation
			return redirectTo(action="index");
		</cfscript>
	</cffunction>
	
</cfcomponent>