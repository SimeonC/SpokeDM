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
<cfcomponent extends="SpokeModel">
	
	<cffunction name="init">
		<cfscript>
			spokeInit(name="Spoke Demo Object");
			belongsTo(name="demotype", spoketype=true);
			hasMany(name="demochilds");//note that if the table was 'child' not 'demochild' we would define it as 'demochildren'
			
			property(name="name", sql="CONCAT(name1, ' ', name2)", spokeDesc="Name1 and Name2 concatenated into one display field.");//mysql
			//property(name="name", sql="name1 + ' ' + name2", spokeDesc="Name1 and Name2 concatenated into one display field.");//mssql
			//property(name="name", sql="name1||' '||name2", spokeDesc="Name1 and Name2 concatenated into one display field.");//PostgresSQL, H2 and Oracle
		</cfscript>
	</cffunction>
	
</cfcomponent>
