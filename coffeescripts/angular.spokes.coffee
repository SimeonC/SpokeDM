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

module = angular.module 'SpokeUtilities', []

module.directive 'bsDatetimepicker', ($timeout) ->
	restrict: 'A'
	require: '?ngModel'
	link: ($scope, $element, $attrs, controller) ->
		#see http://tarruda.github.com/bootstrap-datetimepicker/
		$scope.options = if $attrs.bsDatetimepicker then $scope.$parent.$eval $attrs.bsDatetimepicker else {}
		if not $scope.options.language? then $scope.options.language = 'en'
		if not $scope.options.pick12HourFormat? then $scope.options.pick12HourFormat = true
		$timeout (-> $element.parent().datetimepicker($scope.options)), 0
		$element.parent().on 'changeDate', (e) ->
			$scope.$apply ->
				controller.$setViewValue $element.val()
		return