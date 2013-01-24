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
<cfcomponent extends="wheels.Test" hint="extend this to add the SpokeInitialization test to your testing model - will check the existence of required variables etc">
	
	<!---
		Your setup function must create an object called model, if this doesn't exist SpokeSetup will allways pass as we can't detect what model you are testing on !
	--->
	
	<cffunction name="SpokeSetup">
		<cfscript>
			if(isDefined("model")){
				//is defined so we run the tests
				assert("isInstanceOf(model, 'SpokeModel')");
				assert("ListLen(model.primaryKeys()) EQ 1");
			}
		</cfscript>
	</cffunction>
	
</cfcomponent>