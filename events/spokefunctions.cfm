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
<cffunction name="ArrayFindOneOf" access="public" returnType="string" output="false" hint="Searches through an array of strings, returns the first element in the array that matches any one of the list of strings, returns empty string if not found">
	<cfargument name="array" type="array" required="true" hint="array of strings to search">
	<cfargument name="searchList" type="string" required="true" hint="a list of strings to find in the array">
	<cfscript>
		arguments.searchArray = ListToArray(arguments.searchList);
		for(var i = 1; i LTE ArrayLen(arguments.array); i++) if(ArrayFindNoCase(arguments.searchArray, arguments.array[i])) return arguments.array[i];
		return "";
	</cfscript>
</cffunction>
<cffunction name="StructFindOneOf" access="public" returnType="string" output="false" hint="checks a struct for the existence of a key, returning it if found, returns empty string if not found">
	<cfargument name="struct" type="struct" required="true" hint="struct to search">
	<cfargument name="searchList" type="string" required="true" hint="a list of strings to find in the array">
	<cfscript>
		return ArrayFindOneOf(StructKeyArray(arguments.struct), arguments.searchList);
	</cfscript>
</cffunction>