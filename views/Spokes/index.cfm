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
<cfoutput>
	<div class="spoke-viewport" ng-controller="SpokeMain">
		<div class="row-fluid" ng-show="geterrorsplash">
			<div class="geterrors span12">
				<h1 ng-repeat="error in geterrors">{{error.message}}</h1>
				<p>Click <a href="javascript: history.go(-1)">Here</a> to go back.</p>
			</div>
		</div>
		<div class="row-fluid" ng-hide="geterrorsplash">
			<div class="spoke-parents span3">
				<div class="parent-element" ng-repeat="parent in spoke.associations.parents" ng-hide="parent.data.length == 0">
					<div class="expander" ng-click="expanderToggle(parent)"><i class="icon-chevron-{{expanderClass(parent)}}" ng-show="parent.data[0].description != ''"></i></div>
					<div class="title" ng-click="detailFocus(parent, parent.data[0], 'left')" ng-hide="parent.editor && parent.editor != ''"><strong>{{parent.name}}</strong> {{parent.data[0].name}} <i class="icon-circle-arrow-right"></i></div>
					<div class="title" ng-show="parent.editor && parent.editor != ''"><a href="{{extDynamicLink(parent.editor, parent.data[0])}}" target="_blank"><strong>{{parent.name}}</strong> {{parent.data[0].name}}</a></div>
					<div class="description" ng-show="expand(parent) && parent.data[0].description != ''">{{parent.data[0].description}}</div>
				</div>
			</div>
			<div class="spoke-details span6">
				<h4>{{spoke.name}}</h4>
				<div ng-show="spoke.listing && spoke.listing.length > 0" class="spoke-list">
					<div class="search-bar input-append">
						<input name="{{spoke.name}}Searchbox" type="text" ng-model="spoke.search.$">
						<button class="btn btn-primary" type="button"><i class="icon-search"></i> Search</button>
						<button class="btn btn-success" type="button" ng-click="createNew(spoke)"><i class="icon-plus-sign"></i> New</button>
					</div>
					<div class="list-element" ng-repeat="element in spoke.listing | filter:spoke.search">
						<div class="expander" ng-click="expanderToggle(element)"><i class="icon-chevron-{{expanderClass(element)}}" ng-show="element.description != ''"></i></div>
						<div class="title" ng-click="detailFocus(spoke, element, 'left')" ng-hide="element.editor && element.editor != ''">{{element.name}} <i class="icon-circle-arrow-right"></i></div>
						<div class="title" ng-show="element.editor && element.editor != ''"><a href="{{extDynamicLink(element.editor, element)}}" target="_blank">{{element.name}}</a></div>
						<div class="description" ng-show="expand(element) && element.description != ''">{{element.description}}</div>
					</div>
				</div>
				<form novalidate="novalidate" ng-show="spoke.properties && spoke.properties.length > 0">
					<div ng-repeat="alert in alerts" class="alert alert-{{alert.type}}">
						<button type="button" class="close" ng-click="removeAlert($index)">×</button>
						<strong>{{alert.title}}</strong> {{alert.message}}.
					</div>
					
					<fieldset>
						<div class="spoke-element control-group spoke-{{property.type}}" ng-class="{'warning': dirtywarnings[property.name]}" ng-repeat="property in spoke.properties">
							<div class="alert pull-right" ng-show="dirtywarnings[property.name] && property.type != 'password'"><strong>Value In Database:</strong> {{dirtywarnings[property.name].CHANGEDFROM}}</div>
							<label class="control-label">{{property.label}} <i ng-show="property.required" class="icon-asterisk required"></i> <small>{{property.description}}</small></label>
							<cfinclude template="inputswitch.cfm">
						</div>
					</fieldset>
					
					<div id="typeEditModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="typeEditModalLabel" aria-hidden="true">
						<div class="modal-header">
							<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
							<h3 id="typeEditModalLabel">Edit Type {{edittype.name}}</h3>
						</div>
						<div class="modal-body">
							<table class="table table-bordered table-striped table-condensed">
								<thead>
									<tr>
										<th ng-repeat="col in edittype.columns">{{col.label}}</th>
										<td style="width: 36px;"><button class="btn btn-mini btn-primary" ng-click="newEditType()"><i class="icon-plus-sign"></i> New</button></td>
									</tr>
								</thead>
								<tbody ng-repeat="item in edittype.list" ng-form name='typeform'>
									<tr ng-show="item.typewarnings" class="warning alert">
										<td ng-repeat="property in item.properties"><span ng-show="item.typewarnings[property.name]"><strong>Value In Database:</strong> {{item.typewarnings[property.name].CHANGEDFROM}}</span></td>
										<td></td>
									</tr>
									<tr>
										<cfset inputswitchclass = "spoke-table-input">
										<td ng-repeat="property in item.properties">
											<cfinclude template="inputswitch.cfm">
										</td>
										<td class="btn-group">
											<button class="btn btn-mini btn-danger" ng-click="deleteType(item)" ng-show="spoke.permissions == 4">Delete</button>
											<button class="btn btn-mini" ng-disabled="typeform.$invalid || isTypeUnchanged(item)" ng-click="resetType(item)">Cancel</button>
											<button class="btn btn-mini btn-success dropdown-toggle" ng-hide="item.typewarnings" ng-disabled="typeform.$invalid || isTypeUnchanged(item)" ng-click="saveType(item)">Save</button>
											<button class="btn btn-mini btn-warning dropdown-toggle" ng-show="item.typewarnings" ng-disabled="typeform.$invalid || isTypeUnchanged(item)" ng-click="dirtySaveType(item)">Force</button>
										</td>
									</tr>
								</tbody>
							</table>
						</div>
						<div class="popover right typepopover alert alert-{{typealert}}" ng-hide="typealert == ''">
							<div class="arrow"></div>
							<button type="button" class="close" ng-click="typealert = ''" aria-hidden="true" style="right: 3px;">×</button>
							<h3 class="popover-title">{{typealerttitle}}</h3>
							<div class="popover-content">
								<p>{{typealertmessage}}</p>
							</div>
						</div>
						<div class="modal-footer">
							<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
						</div>
					</div>
					<!--- save and cancel buttons --->
					<button ng-show="spoke.permissions >= 2" class="btn btn-success pull-right clearfix" ng-disabled="form.$invalid || isUnchanged()" ng-click="save()"><i class="icon-save"></i> Save</button>
					<button ng-show="spoke.permissions == 4" class="btn btn-danger pull-left" ng-click="delete()"><i class="icon-remove-sign"></i> Delete</button>
					<button ng-show="spoke.permissions >= 2" class="btn btn-link pull-right" ng-disabled="form.$invalid || isUnchanged()" ng-click="reset()"><i class="icon-undo"></i> Cancel</button>
					<button ng-show="spoke.permissions >= 2 && dirtywarnings" class="btn btn-warning pull-right clearfix" ng-disabled="form.$invalid || isUnchanged()" ng-click="dirtySave()"><i class="icon-paste"></i> Force Save</button>
				</form>
			</div>
			<div class="spoke-children span3">
				<div ng-repeat="childclass in spoke.associations.children">
					<div ng-show="childclass.list && childclass.list != ''">
						<div class="expander"><span class="badge">+</div>
						<div class="title"><a href="{{extDynamicLink(childclass.list, childclass)}}" target="_blank"><strong>{{childclass.name}}</strong> {{childclass.data[0].name}}</a></div>
					</div>
					<div ng-hide="childclass.list && childclass.list != ''">
						<div class="expander" ng-click="expanderToggle(childclass)"><span class="badge">{{childclass.data.length}}  <i class="icon-chevron-{{expanderClass(childclass)}}" ng-show="childclass.data.length > 0"></i></div>
						<div class="title"><strong>{{childclass.name}}</strong></div>
						<div class="children-list" ng-show="expand(childclass)">
							<div class="search-bar input-append">
								<input name="{{childclass.name}}Searchbox" type="text" ng-model="childclass.search.$">
								<button class="btn btn-primary" type="button"><i class="icon-search"></i> Search</button>
								<button class="btn btn-success" type="button" ng-click="createNew(childclass)"><i class="icon-plus-sign"></i> New</button>
							</div>
							<div class="list-details">
								<div class="child-element" ng-repeat="childdata in childclass.data | filter:childclass.search">
									<div class="expander" ng-click="expanderToggle(childdata)"><i class="icon-chevron-{{expanderClass(childdata)}}" ng-show="childdata.description != ''"></i></div>
									<div class="title" ng-click="detailFocus(childclass, childdata, 'right')" ng-hide="childclass.editor && childclass.editor != ''"><i class="icon-circle-arrow-left"></i> {{childdata.name}}</div>
									<div class="title" ng-show="childclass.editor && childclass.editor != ''"><a href="{{extDynamicLink(childclass.editor, childdata)}}" target="_blank">{{childdata.name}}</a></div>
									<div class="description" ng-show="expand(childdata)">{{childdata.description}}</div>
								</div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
		<div class="row-fluid" style="position: absolute; bottom: 0;">
			<!--- Attribution Section, we ask that you leave this in place --->
			<div class="span9">
				<p class="pull-right"><small>Powered by <a href="http://www.spokedm.com">SpokeDM</a><small></p>
			</div>
		</div>
	</div>
</cfoutput>