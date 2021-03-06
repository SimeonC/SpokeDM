// Generated by CoffeeScript 1.3.1

/*
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
*/


(function() {
  var module;

  module = angular.module('SpokeUtilities', []);

  module.directive('spSticky', function($timeout) {
    return {
      restrict: 'A',
      link: function($scope, $element, $attrs, $controller) {
        return $timeout(function() {
          return $element.sticky({
            topSpacing: $attrs.topSpacing,
            bottomSpacing: $attrs.bottomSpacing,
            className: $attrs.className,
            wrapperClassName: $attrs.wrapperClassName,
            getWidthFrom: $attrs.getWidthFrom
          });
        }, 10);
      }
    };
  });

  module.directive('bsDatetimepicker', function($timeout) {
    return {
      restrict: 'A',
      require: '?ngModel',
      link: function($scope, $element, $attrs, controller) {
        var options;
        options = $attrs.bsDatetimepicker ? $scope.$parent.$eval($attrs.bsDatetimepicker) : {};
        if (!(options.language != null)) {
          options.language = 'en';
        }
        if (!(options.pick12HourFormat != null)) {
          options.pick12HourFormat = true;
        }
        $timeout((function() {
          return $element.parent().datetimepicker(options);
        }), 0);
        $element.parent().on('changeDate', function(e) {
          return $scope.$apply(function() {
            return controller.$setViewValue($element.val());
          });
        });
      }
    };
  });

  module.directive('ngHasfocus', function() {
    return function($scope, $element, $attrs) {
      $scope.$watch($attrs.ngHasfocus, function(newVal, oldVal) {
        if (newVal) {
          return $element[0].focus();
        }
      });
      $element.bind('blur', function() {
        return $scope.$apply($attrs.ngHasfocus + " = false");
      });
      $element.bind('keydown', function(e) {
        return $scope.$apply($attrs.ngHasfocus + (e.which === 13 ? " = false" : " = true"));
      });
      return $element.bind('focus', function() {
        return $scope.$apply($attrs.ngHasfocus + " = true");
      });
    };
  });

  /*
  All the data functions here
  */


  module.factory('SpokeURLUtility', function() {
    return {
      extDynamicURL: function(baseurl, item) {
        if (!baseurl || baseurl === '') {
          return '';
        }
        if (item.key) {
          return baseurl.replace('spokekeyplaceholder', item.key);
        }
        return baseurl.replace('spokekeyplaceholder', '');
      }
    };
  });

}).call(this);
