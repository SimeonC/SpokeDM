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

You should have received a copy of the GNU Affero General Public along with SpokeDM.  
If not, see <http://www.gnu.org/licenses/>.
###

module = angular.module 'spokes', ['ngResource','SpokeUtilities','$strap.directives']
module.factory 'DataCache', () ->
	DataCache = {}#possibly load in future from cookies or something like that
		#uses the format "modelkey:key": json
	DataCache.find = (modelkey, key) ->#key arguments is optional
		return @[modelkey] and (!key or @[modelkey][key])
	DataCache.get = (modelkey, key) ->
		return @[modelkey][key]
	DataCache.save = (modelkey, key, data) ->
		if key is 'new' then return
		if not @[modelkey]
			@[modelkey] = {}
		@[modelkey][key] = data
	DataCache.delete = (modelkey, key) ->
		@hasdelete = true
		if @[modelkey] and @[modelkey][key]
			@[modelkey][key] = 'delete'
	return DataCache;
module.factory 'LinkSpoke', ($resource, $rootScope) ->
	LinkSpoke = $resource spokesLinkDataUrl+'/:modelkey/:key', {modelkey:'@modelkey', key:'@key', parent:'@parent'}
	LinkSpoke::get = (cb) ->
		return LinkSpoke.get @, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0
				angular.extend @, json
				cb? json
	return LinkSpoke
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
	DataSpoke::get = (cb) ->
		#caching logic
		if not @newmodelkey? and DataCache.find @modelkey, @key
			angular.extend @, DataCache.get(@modelkey, @key)
			return
		params =
			modelkey: @modelkey
			key: @key
		if @newmodelkey? then params['newkey'] = @newmodelkey
		return DataSpoke.get params, (json) =>
			if json.errors? and json.errors.length isnt 0 then return $rootScope.$broadcast 'spokeLoadError', json.errors
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0
				if json.properties
					for item in json.properties
						if item.type is 'dropdown'
							for option in item.listing
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
				angular.extend @, json
				@_originalproperties = angular.copy @properties #properties is an array of objects - to maintain an ordering
				@_originalinvis = angular.copy @_invis
			if @key isnt 'new' then DataCache.save @modelkey, @key, @
			cb? json
			return
	DataSpoke::save = (cb) ->
		data = 
			data: {}
			origdata: {}
		for item in @properties
			data.data[item.name] = if item.type is 'dropdown' then item.value.key else if item.type is 'boolean' and item.value then 1 else if item.type is 'boolean' and not item.value then 0 else item.value
		for item in @_originalproperties
			data.origdata[item.name] = if item.type is 'dropdown' then item.value.key else if item.type is 'boolean' and item.value then 1 else if item.type is 'boolean' and not item.value then 0 else item.value
		for item in @_invis
			data.data[item.name] = item.value
		for item in @_originalinvis
			data.origdata[item.name] = item.value
		if @dirtyforce then data.dirtyforce = @dirtyforce
		return DataSpoke.save {modelkey: @modelkey, key: @key}, data, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if json.dirtywarnings
				cb? json
				return
			if not json.errors? or json.errors.length is 0
				@_originalproperties = angular.copy @properties
				@_originalinvis = angular.copy @_invis
				#update cache
				DataCache.save @modelkey, @key, ''#evaluates to false so we reload the object next get process
			
				if json.key? then @key = json.key
				cb? json
	DataSpoke::delete = (cb) ->
		return DataSpoke.delete {modelkey: modelkey, key: @key}, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0 then DataCache.delete @modelkey, @key
			cb? json
	DataSpoke::list = (params, cb) ->
		return DataSpoke.list params, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0
				angular.extend @, json
				for i of @listing
					@listing[i].properties = []
					for prop in @properties
						@listing[i].properties.push angular.extend {}, prop, {"value": @listing[i][prop.name]}
						if @listing[i].type is 'dropdown'
							for option in @listing[i].listing
								if object[item].value is option.key
									object[item].value = option
									break
					@listing[i]._originalproperties = []
					@listing[i]._originalproperties = angular.copy @listing[i].properties #properties is an array of objects - to maintain an ordering
				cb? json
	return DataSpoke

module.config ($routeProvider, $locationProvider) ->
	$locationProvider.html5Mode true
	$routeProvider.when spokesBaseViewUrl+'/:modelkey/:key'

class SpokeMain
	constructor: ($scope, $route, $routeParams, $location, $timeout, $resource, $filter, DataSpoke, LinkSpoke) ->
		$scope.geterrors = []
		$scope.geterrorsplash = false
		$scope.afterNewCallbacks = []
		$scope.registerNewCallback = (scope, cb) ->
			$scope.afterNewCallbacks.push
				"scope": angular.extend {}, scope
				"fire": cb
		$scope.fireNewCallback = () ->
			callback = $scope.afterNewCallbacks.pop()
			if not callback then return
			angular.extend $scope, callback.scope
			callback.fire json.key
		
		$scope.$on "spokeLoadError", (evt, errors) ->
			$scope.geterrors = errors
			$scope.geterrorsplash = true
		
		$scope.$on "$routeChangeSuccess", () ->
			$scope.geterrors = []
			$scope.geterrorsplash = false
			if $routeParams.key is 'new' and $scope.spoke.modelkey? and $scope.spoke.key?
				$scope.spoke.newmodelkey = $routeParams.modelkey
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get (json) ->
					if not json.errors? or json.errors.length is 0
						$scope.spoke.modelkey = $routeParams.modelkey
						$scope.spoke.key = $routeParams.key
			else
				$scope.spoke = new DataSpoke()
				$scope.spoke.modelkey = $routeParams.modelkey
				$scope.spoke.key = $routeParams.key
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get()
		
		@searchLogic $scope, $timeout, $resource, $filter
		@alertsLogic $scope
		@spokeLogic $scope, $location, DataSpoke
		@relinkLogic $scope, LinkSpoke
		@typeLogic $scope, DataSpoke
		
		$route.reload()
	
	searchLogic: ($scope, $timeout, $resource, $filter) ->
		$scope.search = 
			searchstring:
				'$': ''
			results: []
			current: {}
			typing: false
			lastsearched: ''
			title: -> return if @searchstring.$ is '' then "Options" else "Results"
			totalcount: ->
				sum = 0
				sum += axle.count() for axle in @results
				return sum
			isquerying: ->
				for axle in @results
					if axle.loading() and axle.show() then return true
				return false
			reset: ->
				$scope.search.mouseover = $scope.search.focussed = false
				$scope.search.searchstring.$ = ''
				for axle in $scope.search.results
					axle._selected = false#whether currently shown tab
					axle._active = true#whether used in results or not
					axle._primaryload = false
					axle.rows = []
					
		searchResource = $resource spokesSearchDataUrl, {},
			query:
				method: 'GET'
				isArray: true
			post:
				method: 'POST'
				isArray: false
		searchResource.query (json) ->
			$scope.search.results = json
			for axle in $scope.search.results
				axle._selected = false#whether currently shown tab
				axle._active = true#whether used in results or not
				axle._primaryload = false
				axle.rows = []
				axle.totalcount = 0
				axle.loading = -> return if $scope.search.searchstring.$ is '' then false else not @_primaryload or @rows.length isnt 0 and @count() is 0
				axle.active = ->  @_active and if $scope.search.searchstring.$ is '' then true else @_selected || $scope.search.totalcount() < 10
				axle.show = -> if $scope.search.searchstring.$ is '' then true else @_active and (not @_primaryload or @rows.length > 0)
				axle.click = ->
					if $scope.search.searchstring.$ is '' then @_active = !@_active else
						axle._selected = false for axle in $scope.search.results
						@_selected = !@_selected
					$scope.search.current = @
					if $('div.display.navbar-inner div.table-scroller-wrapper').is(":visible")
						$timeout (->
								headers = $('div.display.navbar-inner div.table-scroller-wrapper table thead th')
								toprow = $('div.display.navbar-inner div.table-scroller-wrapper table tbody:visible td')
								for i of headers
									headers.eq(i).css "width", toprow.eq(i).outerWidth() - 8 + "px"
							), 5
				axle.count = -> Math.max $filter('filter')(@rows, $scope.search.searchstring).length, @totalcount
				axle.search = ->
					if not $scope.$$phase then $scope.$apply -> @rows = []
					else @rows = []
					if @_active
						searchResource.post {query: $scope.search.searchstring.$, key: @key}, (json) =>
							@_primaryload = true
							$scope.search.lastsearched = $scope.search.searchstring.$
							if not $scope.$$phase then $scope.$apply ->
								@rows = json.query
								@totalcount = json.totalcount
							else
								@rows = json.query
								@totalcount = json.totalcount
							@click()
				axle.reset = ->
					@rows = []
					@_primaryload = false
		
		$scope.search.scrollleft = () ->
			nav = $ "div.navbar div.navbar-inner div.scroller ul.nav"
			currentleft = parseInt nav.css 'left'#left is ALLWAYS < 0
			sumleft = total = 0
			nav.find("li:visible").each (index, element) ->
				if currentleft + sumleft <= 0 then sumleft += $(element).outerWidth()
				total += $(element).outerWidth()
			if total + currentleft > $("div.navbar div.navbar-inner div.scroller").innerWidth() then nav.css "left", -sumleft + 'px'
		$scope.search.scrollright = () ->
			nav = $ "div.navbar div.navbar-inner div.scroller ul.nav"
			currentleft = parseInt nav.css 'left'#left is ALLWAYS < 0
			total = sumleft = 0
			nav.find("li:visible").each (index, element) ->
				if currentleft < total - $(element).outerWidth() then sumleft -= $(element).outerWidth()
				total -= $(element).outerWidth()
			if sumleft <= 0 then nav.css "left", sumleft + 'px'
			
		$scope.search.scrollnav = () ->
			width = 0
			$("div.navbar div.navbar-inner div.scroller ul li:visible").each (index, element) -> width += $(element).outerWidth()
			result = width > $("div.navbar div.navbar-inner div.scroller").innerWidth()
			if !result then $("div.navbar div.navbar-inner div.scroller ul.nav").css "left", "0px"
			return result
		
		#wait to ensure typing is stopped
		$scope.$watch "search.searchstring.$", -> if $scope.search.searchstring.$ isnt '' then $scope.search.typing = true else
			$("div.navbar div.navbar-inner div.scroller ul.nav").css "left", "0px"
			axle.reset() for axle in $scope.search.results
			$scope.search.lastsearched = ''
		$scope.incTimer = () ->
			if $scope.search.searchstring.$ isnt '' and $scope.search.lastsearched isnt $scope.search.searchstring.$ and not $scope.search.typing
				axle.search() for axle in $scope.search.results
				if not $scope.$$phase then $scope.$apply()
			else if $scope.search.typing then $scope.search.typing = false
			setTimeout $scope.incTimer, 750
			#$timeout $scope.incTimer, 750# temporary fix until I find the memory leak here...
		$scope.incTimer()
		
		$scope.toggleAxel = (axle) ->
			if $scope.search.searchstring.$ is ''
				axle.active = !axle.active
		$scope.searchLimit = ->
			rows = 0
			rows += axle.rows.length for axle in $scope.search.results
			return Math.Min 40, 40 / rows
	
	alertsLogic: ($scope) ->
		$scope.alerts = []#{type, title, message}
		$scope.clearAlerts = ->
			$scope.alerts = []
		$scope.removeAlert = (index) ->
			$scope.alerts.splice index, 1
		$scope.appendAlert = (type, title, message) ->
			$scope.alerts.push {type: type, title: title, message: message}
		
	spokeLogic: ($scope, $location, DataSpoke) ->
		$scope.spoke = new DataSpoke()
		$scope.spoke.listing = []
		$scope.spoke.properties = []
		$scope.spoke.children = []
		$scope.spoke.parents = []
		$scope.dirtySave = () ->
			$scope.spoke.dirtyforce = true
			$scope.save()
		$scope.save = () ->
			$scope.clearAlerts()
			origSpokeKey = $scope.spoke.key
			$scope.spoke.save (json) ->
				delete $scope.dirtywarnings
				if json.dirtywarnings
					$scope.dirtywarnings = json.dirtywarnings
					$scope.appendAlert 'warning', 'Warning!', 'While saving we noticed another user has already saved changes to this object; Please check the changes and click "Force Save" if you wish to overwrite them'
				else if json.errors? and json.errors.length isnt 0
					for error in json.errors
						$scope.appendAlert 'error', 'Error!', error.message
				else if origSpokeKey is 'new'
					$scope.appendAlert 'success', 'Saved!', 'The new ' + $scope.spoke.modelkey + ' was created successfully'
					$location.path spokesBaseViewUrl + '/' + $scope.spoke.modelkey + '/' + json.key
					$location.replace()
					$scope.fireNewCallback()
				else
					$scope.appendAlert 'success', 'Saved!', 'The ' + $scope.spoke.modelkey + ' was saved successfully'
			delete $scope.spoke.dirtyforce
		
		$scope.reset = () ->
			$scope.spoke.properties = angular.copy $scope.spoke._originalproperties
			for item in $scope.spoke.properties when item.type is 'dropdown'
				for option in item.listing
					if item.value.key is option.key
						item.value = option
						break
		
		$scope.delete = ->
			$scope.spoke.delete (json) ->
				$scope.clearAlerts()
				if json.errors? and json.errors.length isnt 0 then $scope.appendAlert 'error', 'Failed To Delete', 'The object failed to be deleted: ' + json.errors[0] else
					$scope.appendAlert 'success', 'Deleted Successfully', 'Please navigate to another page.'
					$scope.spoke.properties = []
					$scope.spoke.associations.children = []
					$scope.spoke.permissions = 0
		$scope.isUnchanged = -> angular.equals($scope.spoke._invis, $scope.spoke._originalinvis) && angular.equals $scope.spoke.properties, $scope.spoke._originalproperties
		$scope.expanderClass = (item) -> if item? and 'expanded' of item and item.expanded then "down" else "right"
		$scope.expanderToggle = (item) -> item.expanded = not (item.expanded? and item.expanded)
		$scope.expand = (item) -> item? and 'expanded' of item and item.expanded
		
		$scope.createNew = (childclass, callback) ->
			if callback then $scope.registerNewCallback angular.copy($scope), callback
			$location.path spokesBaseViewUrl + '/' + childclass.modelkey + '/new'
		$scope.detailFocus = (spoke, item, direction) ->
			#loading animations css3
			$scope.search.reset()
			$scope.clearAlerts()
			$location.path spokesBaseViewUrl + '/' + spoke.modelkey + '/' + item.key
		$scope.extDynamicLink = (baseurl, item) ->
			if not baseurl or baseurl is '' then return ''
			if item.key then return baseurl.replace 'spokekeyplaceholder', item.key
			return baseurl.replace 'spokekeyplaceholder', ''
	
	relinkLogic: ($scope, LinkSpoke) ->
		#relink logic
		
		$scope.afterNewCallback = (newkey) ->
			$scope.selectParent
				'key': newkey
			$scope.appendAlert 'info', 'Info', 'We have redirected you back to the ' + $scope.spoke.name + ' you were editing and have added the created ' + $scope.linkparents.name + ' to it. Please save the ' + $scope.spoke.name + ' to save the new link.'
		
		$scope.unlinkParent = (parent) ->
			linkResource = new LinkSpoke
			linkResource.modelkey = $scope.spoke.modelkey
			linkResource.key = $scope.spoke.key
			linkResource.parent = parent.modelkey
			linkResource.get (json) ->
				$scope.spoke._invis[json.propertyname] = ''
				$scope.spoke._originalinvis[json.propertyname] = parent.data[0].key
				parent.data = []
				$scope.appendAlert 'info', 'Info', 'We have un-assigned the ' + json.name + ' from the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the un-link.'
		
		$scope.relinkParent = (parent) ->
			linkResource = new LinkSpoke
			linkResource.modelkey = $scope.spoke.modelkey
			linkResource.key = $scope.spoke.key
			linkResource.parent = parent.modelkey
			$scope._linkparent = parent
			linkResource.get (json) ->
				$scope.linkparents = json
				$('#parentLinkModal').modal 'show'
		
		$scope.selectParent = (parent) ->
			$scope.spoke._invis[$scope.linkparents.propertyname] = parent.key
			$scope.spoke._originalinvis[$scope.linkparents.propertyname] = if $scope._linkparent.data.length > 0 then $scope._linkparent.data[0].key else ''
			$scope._linkparent.data[0] = parent
			$scope.appendAlert 'info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the link.'
			$('#parentLinkModal').modal 'hide'
	
	typeLogic: ($scope, DataSpoke) ->
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
			data.properties.push(angular.copy property) for property in $scope.edittype.properties
			data._originalproperties = angular.copy data.properties
			$scope.edittype.listing.push data
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
			else if json.errors? and json.errors.length isnt 0
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
				for option in item.listing
					if item.value.key is option.key
						item.value = option
						break
		$scope.deleteType = (type) ->
			$scope.typealert = ''
			DataSpoke.delete {modelkey: $scope.edittype.modelkey, key: type.key}, (json) ->
				if json.errors? and json.errors.length isnt 0
					$scope.typealert = 'error'
					$scope.typealerttitle = 'Error'
					$scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' failed to delete, check that it is not referenced by any other objects.'
					return
				for index of $scope.edittype.listing when $scope.edittype.listing[index] is type
					$scope.edittype.listing.splice index, 1
					break
				$scope.typealert = 'success'
				$scope.typealerttitle = 'Deleted!'
				$scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' was deleted successfully'
				return
		$scope.isTypeUnchanged = (type) -> angular.equals type.properties, type._originalproperties
	
	
@SpokeMain = SpokeMain 
