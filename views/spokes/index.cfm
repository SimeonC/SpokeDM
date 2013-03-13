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
	<!--- include the spokesearch partial --->
	#includePartial("spokesearch")#
	<div class="row-fluid spoke-content" ng-show="geterrorsplash">
		<div class="geterrors span12">
			<h1 ng-repeat="error in geterrors" ng-bind-html-unsafe="error.message"></h1>
			<p>Click <a href="javascript: history.go(-1)">Here</a> to go back.</p>
		</div>
	</div>
	<div class="row-fluid spoke-content" ng-hide="geterrorsplash">
		<div class="spoke-parents span3">
			<div class="parent-element clearfix" ng-repeat="parent in spoke.associations.parents">
				<button ng-click="relinkParent(parent)" type="button" class="parent-link btn btn-mini pull-right" ng-class="{'btn-primary': parent.data.length != 0, 'btn-success': parent.data.length == 0}" ng-show="parent.permissions > 1"><i ng-class="{'icon-exchange': parent.data.length != 0, 'icon-plus-sign': parent.data.length == 0}"></i><span ng-show="parent.data.length != 0">Re-</span>Link<span ng-show="parent.data.length == 0"> To</span> Parent</button>
				<button ng-click="unlinkParent(parent)" type="button" class="parent-unlink btn btn-mini btn-danger only-icon pull-right" ng-show="parent.data.length != 0 && parent.permissions == 4"><i class="icon-remove-sign"></i></button>
				<div	ng-click="spokeDetailFocus(parent, parent.data[0], 'left')" class="title" ng-hide="parent.editor && parent.editor != ''"><strong>{{parent.name}}</strong> {{parent.data[0].name}} <i class="icon-circle-arrow-right"></i></div>
				<div class="title" ng-show="parent.editor && parent.editor != ''"><a href="{{extDynamicLink(parent.editor, parent.data[0])}}" target="_blank"><strong>{{parent.name}}</strong> {{parent.data[0].name}} <i class="icon-external-link"></i></a></div>
				<div	ng-click="expanderToggle(parent)" class="expander"><i class="icon-chevron-{{expanderClass(parent)}}"></i></div>
				<div class="description clearfix" ng-show="expand(parent) && parent.data[0].description != ''" ng-bind-html-unsafe="parent.data[0].description"></div>
			</div>
			<div id="parentLinkModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="parentLinkModalLabel" aria-hidden="true">
				<div class="modal-header">
					<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
					<h3 id="parentLinkModalLabel"><span ng-show="_linkparent.data.length > 0">Re-</span>Link To {{linkparents.name}}</h3>
				</div>
				<div class="modal-body">
					<table class="table table-bordered table-striped table-condensed">
						<thead>
							<tr>
								<td colspan="3" class="search-bar input-append">
									<input name="{{linkparents.name}}Searchbox" type="text" ng-model="parentLinkModal.search.$">
									<button class="btn btn-primary" type="button"><i class="icon-search"></i> Search</button>
									<button class="btn btn-success" type="button" ng-show="linkparents.permissions >= 3" ng-click="createNew(linkparents, linkedAfterNew)"><i class="icon-plus-sign"></i> New</button>
								</td>
							</tr>
							<tr>
								<th>Name</th>
								<th>Description</th>
								<th style="width: 75px;"></th>
							</tr>
						</thead>
						<tbody ng-repeat="item in linkparents.listing | filter:parentLinkModal.search">
							<tr>
								<td>{{item.name}}</td>
								<td ng-bind-html-unsafe="item.description"></td>
								<td>
									<button class="btn btn-primary" ng-click="selectParent(item)"><i ng-class="{'icon-exchange': _linkparent.data.length != 0, 'icon-plus-sign': _linkparent.data.length == 0}"></i> Link</button>
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
						<p ng-bind-html-unsafe="typealertmessage"></p>
					</div>
				</div>
				<div class="modal-footer">
					<button class="btn" data-dismiss="modal" aria-hidden="true">Close</button>
				</div>
			</div>
		</div>
		<div class="spoke-details span6 well">
			<h4>{{spoke.name}}</h4>
			<div ng-show="spoke.listing && spoke.listing.length > 0" class="spoke-list">
				<div class="search-bar input-append">
					<input name="{{spoke.name}}Searchbox" type="text" ng-model="spoke.search.$">
					<button class="btn btn-primary" type="button"><i class="icon-search"></i></button>
					<button class="btn btn-success" type="button" ng-show="spoke.permissions >= 2" ng-click="createNew(spoke)"><i class="icon-plus-sign"></i> New</button>
				</div>
				<div class="list-element" ng-repeat="element in spoke.listing | filter:spoke.search">
					<div class="expander" ng-click="expanderToggle(element)"><i class="icon-chevron-{{expanderClass(element)}}"></i></div>
					<div class="title" ng-click="spokeDetailFocus(spoke, element, 'left')" ng-hide="spoke.editor && spoke.editor != ''">{{element.name}} <i class="icon-circle-arrow-right"></i></div>
					<div class="title" ng-show="spoke.editor && spoke.editor != ''"><a href="{{extDynamicLink(spoke.editor, element)}}" target="_blank">{{element.name}} <i class="icon-external-link"></i></a></div>
					<div class="description" ng-show="expand(element) && element.description != ''" ng-bind-html-unsafe="element.description"></div>
				</div>
			</div>
			<form name="mainform" novalidate="novalidate" ng-show="spoke.properties && spoke.properties.length > 0"><!--- save and cancel buttons --->
				<div class="sticky-wrap" sp-sticky top-spacing="60" get-width-from="fieldset">
					<div class="row-fluid main-button-wrap">
						<div ng-show="spoke.permissions >= 2">
							<button class="btn btn-success pull-right clearfix" ng-disabled="mainform.$invalid || spoke.isUnchanged()" ng-click="save()"><i class="icon-save"></i> Save</button>
							<button class="btn btn-link pull-right" ng-disabled="mainform.$invalid || spoke.isUnchanged()" ng-click="reset()"><i class="icon-undo"></i> Cancel</button>
							<button ng-show="dirtywarnings" class="btn btn-warning pull-right clearfix" ng-disabled="mainform.$invalid || spoke.isUnchanged()" ng-click="dirtySave()"><i class="icon-paste"></i> Force Save</button>
						</div>
						<button class="btn btn-danger" ng-show="spoke.permissions == 4" ng-click="delete()"><i class="icon-trash"></i> Delete</button>
					</div>
					<div id="alerts-wrapper">
						<div ng-repeat="alert in alerts" class="alert alert-{{alert.type}}">
							<button type="button" class="close" ng-click="removeAlert($index)">×</button>
							<strong>{{alert.title}}</strong> <span ng-bind-html-unsafe="alert.message"></span>.
						</div>
					</div>
				</div>
				<div id="alerts-padding"></div><!--- this element is used to push everything below the alerts that show. --->
				<fieldset>
					<div class="spoke-element control-group spoke-{{property.type}}" ng-class="{'warning': dirtywarnings[property.name]}" ng-repeat="property in spoke.properties">
						<div class="alert pull-right" ng-show="dirtywarnings[property.name] && property.type != 'password'"><strong>Value In Database:</strong> {{dirtywarnings[property.name].CHANGEDFROM}}</div>
						<label class="control-label">{{property.label}} <i ng-show="property.required" class="icon-asterisk required"></i> <small ng-bind-html-unsafe="property.description"></small></label>
						#includePartial("inputswitch")#
					</div>
				</fieldset>
				
				<div ng-include src="spoke.formurl"></div>
				
				<div id="typeEditModal" class="modal hide fade" tabindex="-1" role="dialog" aria-labelledby="typeEditModalLabel" aria-hidden="true">
					<div class="modal-header">
						<button type="button" class="close" data-dismiss="modal" aria-hidden="true">×</button>
						<h3 id="typeEditModalLabel">Edit Type {{edittype.name}}</h3>
					</div>
					<div class="modal-body">
						<table class="table table-bordered table-striped table-condensed">
							<thead>
								<tr>
									<th ng-repeat="prop in edittype.properties">{{prop.label}}</th>
									<td style="width: 52px;"><button class="btn btn-mini btn-primary" ng-click="newEditType()" ng-show="edittype.permissions >= 2"><i class="icon-plus-sign"></i> New</button></td>
								</tr>
							</thead>
							<tbody ng-repeat="item in edittype.listing" ng-form name='typeform'>
								<tr ng-show="item.typewarnings" class="warning alert">
									<td ng-repeat="property in item.properties"><span ng-show="item.typewarnings[property.name]"><strong>Value In Database:</strong> {{item.typewarnings[property.name].CHANGEDFROM}}</span></td>
									<td></td>
								</tr>
								<tr>
									<td ng-repeat="property in item.properties">
										#includePartial(partial="inputswitch", inputswitchclass="spoke-table-input")#
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
			</form>
		</div>
		<div class="spoke-children span3">
			<div ng-repeat="childclass in spoke.associations.children">
				<div ng-show="childclass.listing && childclass.listing != ''">
					<div class="expander"><span class="badge">+</div>
					<div class="title"><a href="{{extDynamicLink(childclass.listing, childclass)}}" target="_blank"><strong>{{childclass.name}}</strong> {{childclass.data[0].name}} <i class="icon-external-link"></i></a></div>
				</div>
				<div ng-hide="childclass.listing && childclass.listing != ''">
					<div class="expander" ng-click="expanderToggle(childclass)"><span class="badge">{{childclass.data.length}}  <i class="icon-chevron-{{expanderClass(childclass)}}"></i></div>
					<div class="title"><strong>{{childclass.name}}</strong></div>
					<div class="children-list" ng-show="expand(childclass)">
						<div class="search-bar input-append">
							<input name="{{childclass.name}}Searchbox" type="text" ng-model="childclass.search.$">
							<button class="btn btn-primary" type="button"><i class="icon-search"></i></button>
							<button class="btn btn-success" type="button" ng-click="createNew(childclass)" ng-show="childclass.permissions >= 2">
								<ng-switch on="childclass.shortcut">
									<span ng-switch-when="true"><i class="icon-cogs"></i> Manage</span>
									<span ng-switch-default><i class="icon-plus-sign"></i> New</span>
								</ng-switch>
							</button>
						</div>
						<div class="list-details">
							<div class="child-element" ng-repeat="childdata in childclass.data | filter:childclass.search">
								<div class="expander" ng-click="expanderToggle(childdata)"><i class="icon-chevron-{{expanderClass(childdata)}}"></i></div>
								<div class="title" ng-click="spokeDetailFocus(childclass, childdata, 'right')" ng-hide="childclass.editor && childclass.editor != ''"><i class="icon-circle-arrow-left"></i> {{childdata.name}}</div>
								<div class="title" ng-show="childclass.editor && childclass.editor != ''"><a href="{{extDynamicLink(childclass.editor, childdata)}}" target="_blank">{{childdata.name}} <i class="icon-external-link"></i></a></div>
								<div class="description" ng-show="expand(childdata)" ng-bind-html-unsafe="childdata.description"></div>
							</div>
						</div>
					</div>
				</div>
			</div>
		</div>
	</div>
	<div class="row-fluid spoke-footer">
		<!--- Attribution Section, we ask that you leave this in place --->
		<div class="span9">
			<p class="pull-right"><small>Powered by <a href="http://www.spokedm.com">SpokeDM</a></small></p>
		</div>
	</div>
</div>
</cfoutput>
