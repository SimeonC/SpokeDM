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

module = angular.module 'SpokeLogic', []

module.factory 'SPAlertsLogic', ->
	class SPAlertsLogic
		constructor: ($scope, $timeout) ->
			$scope.alerts = []#{type, title, message}
			$scope.clearAlerts = ->
				$scope.alerts = []
				calculateAlerts()
			$scope.removeAlert = (index) ->
				$scope.alerts.splice index, 1
				calculateAlerts()
			$scope.appendAlert = (type, title, message) ->
				$scope.alerts.push {type: type, title: title, message: message}
				calculateAlerts()
			calculateAlerts = ->
				$timeout ->
					$("#alerts-padding").height $("#alerts-wrapper").outerHeight(true) + 12
				, 1

module.factory 'SPSearchLogic', ->
	class SPSearchLogic
		constructor: ($scope, $timeout, $resource, $filter, spokeSearchSelect) ->
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
				deselectAll: ->
					for axle in @results
						axle._active = false
				selectAll: ->
					for axle in @results
						axle._active = true
				scrollleft: ->
					nav = $ "div.navbar div.navbar-inner div.scroller ul.nav"
					currentleft = parseInt nav.css 'left'#left is ALLWAYS < 0
					sumleft = total = 0
					nav.find("li:visible").each (index, element) ->
						if currentleft + sumleft <= 0 then sumleft += $(element).outerWidth()
						total += $(element).outerWidth()
					if total + currentleft > $("div.navbar div.navbar-inner div.scroller").innerWidth() then nav.css "left", -sumleft + 'px'
				scrollright: ->
					nav = $ "div.navbar div.navbar-inner div.scroller ul.nav"
					currentleft = parseInt nav.css 'left'#left is ALLWAYS < 0
					total = sumleft = 0
					nav.find("li:visible").each (index, element) ->
						if currentleft < total - $(element).outerWidth() then sumleft -= $(element).outerWidth()
						total -= $(element).outerWidth()
					if sumleft <= 0 then nav.css "left", sumleft + 'px'
				scrollnav: ->
					width = 0
					$("div.navbar div.navbar-inner div.scroller ul li:visible").each (index, element) -> width += $(element).outerWidth()
					result = width > $("div.navbar div.navbar-inner div.scroller").innerWidth()
					if !result then $("div.navbar div.navbar-inner div.scroller ul.nav").css "left", "0px"
					return result
				incTimer: ->
					if $scope.search.searchstring.$ isnt '' and $scope.search.lastsearched isnt $scope.search.searchstring.$ and not $scope.search.typing
						axle.search() for axle in $scope.search.results
						if not $scope.$$phase then $scope.$apply()
					else if $scope.search.typing then $scope.search.typing = false
					setTimeout $scope.search.incTimer, 750
					#$timeout $scope.search.incTimer, 750# temporary fix until I find the memory leak here...
				select: spokeSearchSelect
			
			#wait to ensure typing is stopped
			$scope.$watch "search.searchstring.$", -> if $scope.search.searchstring.$ isnt '' then $scope.search.typing = true else
				$("div.navbar div.navbar-inner div.scroller ul.nav").css "left", "0px"
				axle.reset() for axle in $scope.search.results
				$scope.search.lastsearched = ''
			#start timer
			$scope.search.incTimer()
			
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

module = angular.module 'SpokeDataLogic', ['SpokeData']

module.factory 'SPSpokeLogic', ->
	class SPSpokeLogic
		constructor: ($scope, $location, SPDataSpoke) ->
			$scope.spoke = new SPDataSpoke()
			$scope.spoke.listing = []
			$scope.spoke.properties = []
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
			$scope.expanderClass = (item) -> if item? and 'expanded' of item and item.expanded then "down" else "right"
			$scope.expanderToggle = (item) -> item.expanded = not (item.expanded? and item.expanded)
			$scope.expand = (item) -> item? and 'expanded' of item and item.expanded
			
			$scope.createNew = (childclass, callback) ->
				if callback then $scope.registerNewCallback angular.copy($scope), callback
				$location.path spokesBaseViewUrl + '/' + childclass.modelkey + '/new'
			$scope.spokeDetailFocus = (spoke, item, direction) ->
				#loading animations css3
				$scope.search.reset()
				$scope.clearAlerts()
				$location.path spokesBaseViewUrl + '/' + spoke.modelkey + '/' + item.key
	
module.factory 'SPRelinkLogic', ['SPLinkSpoke','SPSpokeLogic', ->
	class SPRelinkLogic
		constructor: ($scope, SPLinkSpoke) ->
			#relink logic
			
			$scope.afterNewCallback = (newkey) ->
				$scope.selectParent
					'key': newkey
				$scope.appendAlert 'info', 'Info', 'We have redirected you back to the ' + $scope.spoke.name + ' you were editing and have added the created ' + $scope.linkparents.name + ' to it. Please save the ' + $scope.spoke.name + ' to save the new link.'
			
			$scope.unlinkParent = (parent) ->
				linkResource = new SPLinkSpoke
				linkResource.modelkey = $scope.spoke.modelkey
				linkResource.key = $scope.spoke.key
				linkResource.parent = parent.modelkey
				linkResource.get (json) ->
					$scope.spoke._invis[json.propertyname] = ''
					$scope.spoke._originalinvis[json.propertyname] = parent.data[0].key
					parent.data = []
					$scope.appendAlert 'info', 'Info', 'We have un-assigned the ' + json.name + ' from the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the un-link.'
			
			$scope.relinkParent = (parent) ->
				linkResource = new SPLinkSpoke
				linkResource.modelkey = $scope.spoke.modelkey
				linkResource.key = $scope.spoke.key
				linkResource.parent = parent.assockey
				$scope._linkparent = parent
				linkResource.get (json) ->
					$scope.linkparents = json
					$('#parentLinkModal').modal 'show'
			
			$scope.selectParent = (parent) ->
				#else we just set the parent to be the same parent
				if $scope._linkparent.data.length is 0 or parent.key isnt $scope._linkparent.data[0].key
					$scope.spoke._invis[$scope.linkparents.propertyname] = parent.key
					$scope.spoke._originalinvis[$scope.linkparents.propertyname] = if $scope._linkparent.data.length > 0 then $scope._linkparent.data[0].key else ''
					$scope._linkparent.data[0] = parent
					$scope.appendAlert 'info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the link.'
				else
					$scope.appendAlert 'info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '.'
				$('#parentLinkModal').modal 'hide'
]
module.factory 'SPTypeLogic', ['SPDataSpoke', ->
	class SPTypeLogic
		constructor: ($scope, SPDataSpoke) ->
			#type modal logic
			
			$scope.typeEditModal = (typename) ->
				$scope.typealert = ''
				$scope.edittype = new SPDataSpoke()
				$scope.edittype.modelkey = typename
				$scope.edittype.list {modelkey: typename, list: true}, (json) -> if not json.errors? or json.errors.length is 0 then $('#typeEditModal').modal 'show'
			$scope.newEditType = ->
				$scope.typealert = ''
				data = {key: 'new', properties: []}
				data.properties.push(angular.copy property) for property in $scope.edittype.properties
				data._originalproperties = angular.copy data.properties
				$scope.edittype.listing.push data
			$scope.dirtySaveType = (type) ->
				$scope.typealert = ''
				$scope.processingtype = type
				dp = new SPDataSpoke()
				dp.dirtyforce = true
				angular.extend dp, type, {modelkey: $scope.edittype.modelkey}
				dp.save typeSaveProcess
			$scope.saveType = (type) ->
				$scope.typealert = ''
				$scope.processingtype = type
				dp = new SPDataSpoke()
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
				SPDataSpoke.delete {modelkey: $scope.edittype.modelkey, key: type.key}, (json) ->
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
]
