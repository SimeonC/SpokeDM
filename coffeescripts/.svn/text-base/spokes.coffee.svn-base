###
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
###

module = angular.module 'spokes', ['ngResource','SpokeUtilities']
module.factory 'DataCache', () ->
	DataCache = {}#possibly load in future from cookies or something like that
		#uses the format "modelkey:key": json
	DataCache.find = (modelkey, key) ->#key arguments is optional
		return this[modelkey] and (!key or this[modelkey][key])
	DataCache.get = (modelkey, key) ->
		return this[modelkey][key]
	DataCache.save = (modelkey, key, data) ->
		if not this[modelkey]
			this[modelkey] = {}
		this[modelkey][key] = data
	DataCache.delete = (modelkey, key) ->
		this.hasdelete = true
		if this[modelkey] and this[modelkey][key]
			this[modelkey][key] = 'delete'
	return DataCache;
module.factory 'DataSpoke', ($resource, $rootScope, DataCache) ->
	DataSpoke = $resource spokesBaseDataUrl+'/:modelkey/:key', {modelkey:'@modelkey', key:'@key'}, {
		'get':
			method: 'GET'
			params:
				'delete': false
		'delete':
			method: 'GET'
			params:
				'delete': true
		'save':
			method: 'POST'
		'list':
			method: 'GET'
			params:
				'list': true
	}
	processGet = (json, self) ->
		if json.loginerror?
			$rootScope.broadcast "SpokeUserLoggedOut", json
			return
		if json.errors.length is 0
			if json.properties
				for item in json.properties
					if item.type is 'dropdown'
						for option in item.list
							if item.value is option.key
								item.value = option
								break
				if(DataCache.hasdelete)#if no delete occurs don't run this logic - would slow down processing lots
					for i of json.associations.parents when DataCache.find json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key and DataCache.get json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key is 'delete' then json.associations.parents.splice i, 1
					for i of json.associations.children when DataCache.find json.associations.children[i].modelkey
						for j of json.associations.children[i].data when DataCache.find json.associations.children[i].data[j].modelkey, json.associations.children[i].data[j].key and DataCache.get json.associations.children[i].modelkey, json.associations.children[i].data[j].key is 'delete' then json.associations.children[i].data.splice j, 1
			else if json.listing
				if(DataCache.hasdelete)#if no delete occurs don't run this logic - would slow down processing lots
					for i of json.listing when DataCache.find json.modelkey, json.listing[i].key and DataCache.get json.modelkey, json.listing[i].key is 'delete' then json.listing.splice i, 1
			angular.extend self, json
			self._originalproperties = angular.copy self.properties #properties is an array of objects - to maintain an ordering
		return
	
	DataSpoke::get = (cb) ->
		self = this
		#caching logic
		if DataCache.find this.modelkey, this.key
			angular.extend this, DataCache.get(this.modelkey, this.key)
			return
		params = 
			modelkey: this.modelkey
			key: this.key
		if this.newmodelkey? then params.newkey = this.newmodelkey
		return DataSpoke.get params, (json) ->
			if json.errors.length isnt 0 then return $rootScope.$broadcast 'spokeLoadError', json.errors
			processGet json, self
			if params.key isnt 'new' then DataCache.save self.modelkey, self.key, self
			cb? json
			return
	DataSpoke::save = (cb) ->
		self = this
		data = 
			data: {}
			origdata: {}
		for item in this.properties
			data.data[item.name] = if item.type is 'dropdown' then item.value.key else if item.type is 'boolean' and item.value then 1 else if item.type is 'boolean' and not item.value then 0 else item.value
		for item in this._originalproperties
			data.origdata[item.name] = if item.type is 'dropdown' then item.value.key else if item.type is 'boolean' and item.value then 1 else if item.type is 'boolean' and not item.value then 0 else item.value
		if this._invis? and this._invis then for item in this._invis
			data.data[item.name] = item.value
			data.origdata[item.name] = item.value
		if this.dirtyforce then data.dirtyforce = this.dirtyforce
		return DataSpoke.save {modelkey: this.modelkey, key: this.key}, data, (json) ->
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if json.dirtywarnings
				cb? json
				return
			if json.errors.length is 0 then self._originalproperties = angular.copy self.properties
			#update cache
			DataCache.save self.modelkey, self.key, ''#evaluates to false so we reload the object next get process
			
			if json.key? then self.key = json.key
			cb? json
	DataSpoke::delete = (cb) ->
		self = this
		return DataSpoke.delete {modelkey: this.modelkey, key: this.key}, (json) ->
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if json.errors.length is 0 then DataCache.delete self.modelkey, self.key
			cb? json
	DataSpoke::list = (params, cb) ->
		self = this
		return DataSpoke.list params, (json) ->
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if json.errors.length is 0
				angular.extend self, json
				for i of self.list
					self.list[i].properties = []
					for col in self.columns
						self.list[i].properties.push angular.extend {}, col, {"value": self.list[i][col.name]}
						if self.list[i].type is 'dropdown'
							for option in self.list[i].list
								if object[item].value is option.key
									object[item].value = option
									break
					self.list[i]._originalproperties = []
					self.list[i]._originalproperties = angular.copy self.list[i].properties #properties is an array of objects - to maintain an ordering
				cb? json
	return DataSpoke

module.config ($routeProvider, $locationProvider) ->
	$locationProvider.html5Mode true
	$routeProvider.when spokesBaseViewUrl+'/:modelkey/:key'

class SpokeMain
	constructor: ($scope, $route, $routeParams, $location, DataSpoke) ->
		$scope.spoke = new DataSpoke()
		$scope.spoke.listing = []
		$scope.spoke.properties = []
		$scope.spoke.children = []
		$scope.spoke.parents = []
		$scope.alerts = []#{type, title, message}
		$scope.geterrors = []
		$scope.geterrorsplash = false
		
		$scope.$on "spokeLoadError", (evt, errors) ->
			$scope.geterrors = errors
			$scope.geterrorsplash = true
		
		$scope.$on "$routeChangeSuccess", () ->
			$scope.geterrors = []
			$scope.geterrorsplash = false
			if $routeParams.key is 'new' and $scope.spoke.modelkey? and $scope.spoke.key?
				$scope.spoke.newmodelkey = $routeParams.modelkey
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get (json) ->
					if json.errors.length is 0
						$scope.spoke.modelkey = $routeParams.modelkey
						$scope.spoke.key = $routeParams.key
			else
				$scope.spoke = new DataSpoke()
				$scope.spoke.modelkey = $routeParams.modelkey
				$scope.spoke.key = $routeParams.key
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get()
		
		$scope.clearAlerts = ->
			$scope.alerts = []
		$scope.removeAlert = (index) ->
			$scope.alerts.splice index, 1
		$scope.appendAlert = (type, title, message) ->
			$scope.alerts.push {type: type, title: title, message: message}
		
		$scope.dirtySave = () ->
			$scope.spoke.dirtyforce = true
			$scope.save()
		$scope.save = () ->
			$scope.clearAlerts()
			$scope.spoke.save (json) ->
				delete $scope.dirtywarnings
				if json.dirtywarnings
					$scope.dirtywarnings = json.dirtywarnings
					$scope.appendAlert 'warning', 'Warning!', 'While saving we noticed another user has already saved changes to this object; Please check the changes and click "Force Save" if you wish to overwrite them'
				else if json.errors.length isnt 0
					for error in json.errors
						$scope.appendAlert 'error', 'Error!', error.message
				else if $scope.spoke.key is 'new'
					$scope.appendAlert 'success', 'Saved!', 'The new ' + $scope.spoke.modelkey + ' was created successfully'
					$location.path spokesBaseViewUrl + '/' + $scope.spoke.modelkey + '/' + json.key
					$location.replace()
				else
					$scope.appendAlert 'success', 'Saved!', 'The ' + $scope.spoke.modelkey + ' was saved successfully'
			delete $scope.spoke.dirtyforce
		
		$scope.reset = () ->
			$scope.spoke.properties = angular.copy $scope.spoke._originalproperties
			for item in $scope.spoke.properties when item.type is 'dropdown'
				for option in item.list
					if item.value.key is option.key
						item.value = option
						break
		
		$scope.delete = ->
			$scope.spoke.delete (json) ->
				$scope.clearAlerts()
				if json.errors.length isnt 0 then $scope.appendAlert 'error', 'Failed To Delete', 'The object failed to be deleted: ' + json.errors[0] else
					$scope.appendAlert 'success', 'Deleted Successfully', 'Please navigate to another page.'
					$scope.spoke.properties = []
					$scope.spoke.associations.children = []
					$scope.spoke.permissions = 0
		$scope.isUnchanged = -> angular.equals $scope.spoke.properties, $scope.spoke._originalproperties
		$scope.expanderClass = (item) -> if item? and 'expanded' of item and item.expanded then "down" else "right"
		$scope.expanderToggle = (item) -> item.expanded = not (item.expanded? and item.expanded)
		$scope.expand = (item) -> item? and 'expanded' of item and item.expanded
		
		$scope.createNew = (childclass) ->
			$location.path spokesBaseViewUrl + '/' + childclass.modelkey + '/new'
		$scope.detailFocus = (spoke, item, direction) ->
			#loading animations css3
			$scope.clearAlerts()
			$location.path spokesBaseViewUrl + '/' + spoke.modelkey + '/' + item.key
		$scope.extDynamicLink = (baseurl, item) ->
			if not baseurl or baseurl is '' then return ''
			if item.key then return baseurl.replace 'spokekeyplaceholder', item.key
			return baseurl.replace 'spokekeyplaceholder', ''
		
		#type modal logic
		
		$scope.typeEditModal = (typename) ->
			$scope.typealert = ''
			$scope.edittype = new DataSpoke()
			$scope.edittype.modelkey = typename
			$scope.edittype.list {modelkey: typename, list: true}, () ->
				$('#typeEditModal').modal 'show'
		$scope.newEditType = ->
			$scope.typealert = ''
			data = {key: 'new', properties: []}
			data.properties.push(angular.copy column) for column in $scope.edittype.columns
			data._originalproperties = angular.copy data.properties
			$scope.edittype.list.push data
		$scope.dirtySaveType = (type) ->
			$scope.typealert = ''
			$scope.processingtype = type
			dp = new DataSpoke()
			dp.dirtyforce = true
			angular.extend dp, type, {modelkey: $scope.edittype.modelkey}
			dp.save typeSaveProcess
		$scope.saveType = (type) ->
			$scope.typealert = ''
			$scope.processingtype = type
			dp = new DataSpoke()
			angular.extend dp, type, {modelkey: $scope.edittype.modelkey}
			dp.save typeSaveProcess
		typeSaveProcess = (json) ->
			type = $scope.processingtype
			delete type.typewarnings
			if json.dirtywarnings
				type.typewarnings = json.dirtywarnings
			else if json.errors.length isnt 0
				for error in json.errors
					$scope.typealert = 'error'
					$scope.typealerttitle = 'Error!'
					$scope.typealertmessage = error.message
			else if type.key is 'new'
				type._originalproperties = angular.copy type.properties
				$scope.resetType type
				$scope.typealert = 'success'
				$scope.typealerttitle = 'Saved!'
				$scope.typealertmessage = 'The new ' + $scope.edittype.modelkey + ' was created successfully'
				type.key = json.key
			else
				type._originalproperties = angular.copy type.properties
				$scope.resetType type
				$scope.typealert = 'success'
				$scope.typealerttitle = 'Saved!'
				$scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' was saved successfully'
		$scope.resetType = (type) ->
			$scope.typealert = ''
			type.properties = angular.copy type._originalproperties
			for item in type.properties when item.type is 'dropdown'
				for option in item.list
					if item.value.key is option.key
						item.value = option
						break
		$scope.deleteType = (type) ->
			$scope.typealert = ''
			DataSpoke.delete {modelkey: $scope.edittype.modelkey, key: type.key}, (json) ->
				if json.errors.length isnt 0
					$scope.typealert = 'error'
					$scope.typealerttitle = 'Error'
					$scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' failed to delete, check that it is not referenced by any other objects.'
					return
				for index of $scope.edittype.list when $scope.edittype.list[index] is type
					$scope.edittype.list.splice index, 1
					break
				$scope.typealert = 'success'
				$scope.typealerttitle = 'Deleted!'
				$scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' was deleted successfully'
				return
		$scope.isTypeUnchanged = (type) -> angular.equals type.properties, type._originalproperties
		
		$route.reload()
@SpokeMain = SpokeMain 