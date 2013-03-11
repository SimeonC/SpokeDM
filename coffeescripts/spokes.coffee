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

module = angular.module 'spokes', ['ngResource','SpokeData','SpokeLogic','SpokeDataLogic','SpokeUtilities','$strap.directives']
module.config ($routeProvider, $locationProvider) ->
	$locationProvider.html5Mode true
	$routeProvider.when spokesBaseViewUrl+'/:modelkey/:key'

class SpokeMain
	constructor: ($scope, $route, $routeParams, $location, $timeout, $resource, $filter, SPDataSpoke, SPLinkSpoke, SPSearchLogic, SPAlertsLogic, SPSpokeLogic, SPRelinkLogic, SPTypeLogic, SpokeURLUtility) ->
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
			$scope.clearAlerts()
			if $routeParams.key is 'new' and $scope.spoke.modelkey? and $scope.spoke.key?
				$scope.spoke.newmodelkey = $routeParams.modelkey
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get (json) ->
					if not json.errors? or json.errors.length is 0
						$scope.spoke.modelkey = $routeParams.modelkey
						$scope.spoke.key = $routeParams.key
			else
				$scope.spoke = new SPDataSpoke()
				$scope.spoke.modelkey = $routeParams.modelkey
				$scope.spoke.key = $routeParams.key
				if $scope.spoke.modelkey? and $scope.spoke.key? and $routeParams.modelkey? and $routeParams.key? then $scope.spoke.get()
		
		$scope.extDynamicLink = SpokeURLUtility.extDynamicURL
		SPSearchLogic $scope, $timeout, $resource, $filter, (axle, row) ->
			if axle.externalurl then window.location = $scope.extDynamicLink axle.externalurl, row
			else $scope.spokeDetailFocus axle, row, 'center'
		SPAlertsLogic $scope, $timeout
		SPSpokeLogic $scope, $location, SPDataSpoke
		SPRelinkLogic $scope, SPLinkSpoke
		SPTypeLogic $scope, SPDataSpoke
		
		$route.reload()	
	
@SpokeMain = SpokeMain 
