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
<cfcomponent extends="plugins.dbmigrate.Migration" hint="Sets up the Demo Tables for SpokeDM">
	<cffunction name="up">
		<cfscript>
			//demomain, demochild, demotype
			var t = createTable("DemoTypes");
			t.string("name");
			t.create();
			var t = createTable("DemoParents");
			t.references("DemoType");
			t.string("name1,name2");
			t.string(columnNames="password", limit=12);
			t.float("amount");
			t.datetime("deliverydue");
			t.create();
			var t = createTable("DemoChilds");
			t.references("DemoParent");
			t.string(columnNames="displayname", null=false);
			t.string("packagetype,website");
			t.create();
			
			addRecord(table="DemoTypes", name="Order");//1
			addRecord(table="DemoTypes", name="Dis-Order");//2
			addRecord(table="DemoTypes", name="Harmony");//3
			addRecord(table="DemoTypes", name="Melody");//4
			addRecord(table="DemoTypes", name="Sauce");//5
			
			addRecord(table="DemoParents", demotypeid=1, name1="First", name2="Demo", password="password", amount=12.35, deliverydue=NOW());//1
			
			addRecord(table="DemoChilds", demoparentid=1, displayname="First Child", packagetype="good", website="www.first.com");
			addRecord(table="DemoChilds", demoparentid=1, displayname="Secord Child", packagetype="tiny", website="");
			addRecord(table="DemoChilds", demoparentid=1, displayname="Favourite Child", packagetype="good", website="");
			addRecord(table="DemoChilds", demoparentid=1, displayname="Runt", packagetype="odd", website="");
		</cfscript>
	</cffunction>
	<cffunction name="down">
		<cfscript>
			dropTable("DemoChild");
			dropTable("DemoMain");
			dropTable("DemoType");
		</cfscript>
	</cffunction>
</cfcomponent>