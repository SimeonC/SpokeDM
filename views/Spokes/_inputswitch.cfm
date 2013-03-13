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
<!---
	need to cover display, integer, string, datetime, date, time, boolean, float, binary, array(display only), struct(display only), dropdown, text, email, url, password
	each property contains {name, label, value, type[, list(for dropdown types)[, editable]][, placeholder][, required][, tip]}
	
	Edit this page if you want to use a specific plugin for particular inputs
	To use a plugin add a angularJS directive and make that particular input use the directive
	To add your own custom type displays, add to the custominputs.cfm file which is included herin
--->
<cfoutput>
	<ng-switch on="property.type">
		<input class="#arguments.inputswitchclass# spoke-element spoke-integer"	ng-switch-when="integer"	name="{{property.name}}" ng-pattern="/[0-9]*/" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="number" step="1"/>
		<input class="#arguments.inputswitchclass# spoke-element spoke-float"		ng-switch-when="float"	name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="number"/>
		<input class="#arguments.inputswitchclass# spoke-element spoke-string"	ng-switch-when="string"	name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="text"/>
		<input class="#arguments.inputswitchclass# spoke-element spoke-boolean"	ng-switch-when="boolean"	name="{{property.name}}" ng-model="property.value" ng-required="property.required" bs-tooltip="property.tip" type="checkbox"/>
		<!--- see http://tarruda.github.com/bootstrap-datetimepicker/ and angular.spokes.coffee for details on the following popups --->
		<div ng-switch-when="datetime" class="input-append spoke-element spoke-datetime">
			<input class="#arguments.inputswitchclass#" bs-datetimepicker="{}" data-format="#arguments.dateformat# #arguments.timeformat#" type="text" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip"></input>
			<span class="add-on btn">
				<i data-time-icon="icon-time" data-date-icon="icon-calendar"></i>
			</span>
		</div>
		<div ng-switch-when="time" class="input-append spoke-element spoke-time">
			<input class="#arguments.inputswitchclass#" bs-datetimepicker="{pickDate: false}" data-format="#arguments.timeformat#" type="text" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip"></input>
			<span class="add-on btn">
				<i data-time-icon="icon-time" data-date-icon="icon-calendar"></i>
			</span>
		</div>
		<div ng-switch-when="date" class="input-append spoke-element spoke-date">
			<input class="#arguments.inputswitchclass#" bs-datetimepicker="{pickTime: false}" data-format="#arguments.dateformat#" type="text" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip"></input>
			<span class="add-on btn">
				<i data-time-icon="icon-time" data-date-icon="icon-calendar"></i>
			</span>
		</div>
		<!--- <div ng-switch-when="binary"></div> do not support binary at the start --->
		<div ng-switch-when="dropdown" class="input-append spoke-element spoke-dropdown">
			<select class="#arguments.inputswitchclass#" name="{{property.name}}" ng-model="property.value" ng-required="property.required" ng-options="option.name for option in property.listing" bs-tooltip="property.tip">
				<option ng-show="property.placeholder != ''" value="">{{property.placeholder}}</option>
			</select>
			<a class="add-on btn" ng-show="property.editable" role="button" ng-click="typeEditModal(property.name)">
				<i class="icon-edit"></i> Edit
			</a>
		</div>
		<!---
			email address regex is based off http://net.tutsplus.com/tutorials/other/8-regular-expressions-you-should-know/ with the addition of many more special characters as specified in the W3C specs.
			url regex straight from that site
		--->
		<input class="#arguments.inputswitchclass# spoke-element spoke-email" ng-switch-when="email" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="email"/>
		<input class="#arguments.inputswitchclass# spoke-element spoke-url" ng-switch-when="url" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="url"/>
		<input class="#arguments.inputswitchclass# spoke-element spoke-password" ng-switch-when="password" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip" type="password"/>
		<textarea class="#arguments.inputswitchclass# spoke-element spoke-textarea" ng-switch-when="text" name="{{property.name}}" ng-model="property.value" ng-required="property.required" placeholder="{{property.placeholder}}" bs-tooltip="property.tip"></textarea>
		#includePartial(partial="custominputs", argumentCollection=arguments)#
		<div ng-switch-default class="#arguments.inputswitchclass# spoke-element spoke-password"><p ng-bind-html-unsafe="property.value" bs-tooltip="property.tip"><!--- display generated here ---></p></div>
	</ng-switch>
	<!--- DEBUG LINE <p>{{property.value}}</p> --->
</cfoutput>
