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

  module = angular.module('SpokeLogic', []);

  module.factory('SPAlertsLogic', function() {
    var SPAlertsLogic;
    return SPAlertsLogic = (function() {

      SPAlertsLogic.name = 'SPAlertsLogic';

      function SPAlertsLogic($scope, $timeout) {
        var calculateAlerts;
        $scope.alerts = [];
        $scope.clearAlerts = function() {
          $scope.alerts = [];
          return calculateAlerts();
        };
        $scope.removeAlert = function(index) {
          $scope.alerts.splice(index, 1);
          return calculateAlerts();
        };
        $scope.appendAlert = function(type, title, message) {
          $scope.alerts.push({
            type: type,
            title: title,
            message: message
          });
          return calculateAlerts();
        };
        calculateAlerts = function() {
          return $timeout(function() {
            return $("#alerts-padding").height($("#alerts-wrapper").outerHeight(true) + 12);
          }, 1);
        };
      }

      return SPAlertsLogic;

    })();
  });

  module.factory('SPSearchLogic', function() {
    var SPSearchLogic;
    return SPSearchLogic = (function() {

      SPSearchLogic.name = 'SPSearchLogic';

      function SPSearchLogic($scope, $timeout, $resource, $filter, spokeSearchSelect) {
        var searchResource;
        $scope.search = {
          searchstring: {
            '$': ''
          },
          results: [],
          current: {},
          typing: false,
          lastsearched: '',
          title: function() {
            if (this.searchstring.$ === '') {
              return "Options";
            } else {
              return "Results";
            }
          },
          totalcount: function() {
            var axle, sum, _i, _len, _ref;
            sum = 0;
            _ref = this.results;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              sum += axle.count();
            }
            return sum;
          },
          isquerying: function() {
            var axle, _i, _len, _ref;
            _ref = this.results;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              if (axle.loading() && axle.show()) {
                return true;
              }
            }
            return false;
          },
          reset: function() {
            var axle, _i, _len, _ref, _results;
            $scope.search.mouseover = $scope.search.focussed = false;
            $scope.search.searchstring.$ = '';
            _ref = $scope.search.results;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              axle._selected = false;
              axle._active = true;
              axle._primaryload = false;
              _results.push(axle.rows = []);
            }
            return _results;
          },
          deselectAll: function() {
            var axle, _i, _len, _ref, _results;
            _ref = this.results;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              _results.push(axle._active = false);
            }
            return _results;
          },
          selectAll: function() {
            var axle, _i, _len, _ref, _results;
            _ref = this.results;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              _results.push(axle._active = true);
            }
            return _results;
          },
          scrollleft: function() {
            var currentleft, nav, sumleft, total;
            nav = $("div.navbar div.navbar-inner div.scroller ul.nav");
            currentleft = parseInt(nav.css('left'));
            sumleft = total = 0;
            nav.find("li:visible").each(function(index, element) {
              if (currentleft + sumleft <= 0) {
                sumleft += $(element).outerWidth();
              }
              return total += $(element).outerWidth();
            });
            if (total + currentleft > $("div.navbar div.navbar-inner div.scroller").innerWidth()) {
              return nav.css("left", -sumleft + 'px');
            }
          },
          scrollright: function() {
            var currentleft, nav, sumleft, total;
            nav = $("div.navbar div.navbar-inner div.scroller ul.nav");
            currentleft = parseInt(nav.css('left'));
            total = sumleft = 0;
            nav.find("li:visible").each(function(index, element) {
              if (currentleft < total - $(element).outerWidth()) {
                sumleft -= $(element).outerWidth();
              }
              return total -= $(element).outerWidth();
            });
            if (sumleft <= 0) {
              return nav.css("left", sumleft + 'px');
            }
          },
          scrollnav: function() {
            var result, width;
            width = 0;
            $("div.navbar div.navbar-inner div.scroller ul li:visible").each(function(index, element) {
              return width += $(element).outerWidth();
            });
            result = width > $("div.navbar div.navbar-inner div.scroller").innerWidth();
            if (!result) {
              $("div.navbar div.navbar-inner div.scroller ul.nav").css("left", "0px");
            }
            return result;
          },
          incTimer: function() {
            var axle, _i, _len, _ref;
            if ($scope.search.searchstring.$ !== '' && $scope.search.lastsearched !== $scope.search.searchstring.$ && !$scope.search.typing) {
              _ref = $scope.search.results;
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                axle = _ref[_i];
                axle.search();
              }
              if (!$scope.$$phase) {
                $scope.$apply();
              }
            } else if ($scope.search.typing) {
              $scope.search.typing = false;
            }
            return setTimeout($scope.search.incTimer, 750);
          },
          select: spokeSearchSelect
        };
        $scope.$watch("search.searchstring.$", function() {
          var axle, _i, _len, _ref;
          if ($scope.search.searchstring.$ !== '') {
            return $scope.search.typing = true;
          } else {
            $("div.navbar div.navbar-inner div.scroller ul.nav").css("left", "0px");
            _ref = $scope.search.results;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              axle = _ref[_i];
              axle.reset();
            }
            return $scope.search.lastsearched = '';
          }
        });
        $scope.search.incTimer();
        searchResource = $resource(spokesSearchDataUrl, {}, {
          query: {
            method: 'GET',
            isArray: true
          },
          post: {
            method: 'POST',
            isArray: false
          }
        });
        searchResource.query(function(json) {
          var axle, _i, _len, _ref, _results;
          $scope.search.results = json;
          _ref = $scope.search.results;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            axle = _ref[_i];
            axle._selected = false;
            axle._active = true;
            axle._primaryload = false;
            axle.rows = [];
            axle.totalcount = 0;
            axle.loading = function() {
              if ($scope.search.searchstring.$ === '') {
                return false;
              } else {
                return !this._primaryload || this.rows.length !== 0 && this.count() === 0;
              }
            };
            axle.active = function() {
              return this._active && ($scope.search.searchstring.$ === '' ? true : this._selected || $scope.search.totalcount() < 10);
            };
            axle.show = function() {
              if ($scope.search.searchstring.$ === '') {
                return true;
              } else {
                return this._active && (!this._primaryload || this.rows.length > 0);
              }
            };
            axle.click = function() {
              var axle, _j, _len1, _ref1;
              if ($scope.search.searchstring.$ === '') {
                this._active = !this._active;
              } else {
                _ref1 = $scope.search.results;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  axle = _ref1[_j];
                  axle._selected = false;
                }
                this._selected = !this._selected;
              }
              $scope.search.current = this;
              if ($('div.display.navbar-inner div.table-scroller-wrapper').is(":visible")) {
                return $timeout((function() {
                  var headers, i, toprow, _results1;
                  headers = $('div.display.navbar-inner div.table-scroller-wrapper table thead th');
                  toprow = $('div.display.navbar-inner div.table-scroller-wrapper table tbody:visible td');
                  _results1 = [];
                  for (i in headers) {
                    _results1.push(headers.eq(i).css("width", toprow.eq(i).outerWidth() - 8 + "px"));
                  }
                  return _results1;
                }), 5);
              }
            };
            axle.count = function() {
              return Math.max($filter('filter')(this.rows, $scope.search.searchstring).length, this.totalcount);
            };
            axle.search = function() {
              var _this = this;
              if (!$scope.$$phase) {
                $scope.$apply(function() {
                  return this.rows = [];
                });
              } else {
                this.rows = [];
              }
              if (this._active) {
                return searchResource.post({
                  query: $scope.search.searchstring.$,
                  key: this.key
                }, function(json) {
                  _this._primaryload = true;
                  $scope.search.lastsearched = $scope.search.searchstring.$;
                  if (!$scope.$$phase) {
                    $scope.$apply(function() {
                      this.rows = json.query;
                      return this.totalcount = json.totalcount;
                    });
                  } else {
                    _this.rows = json.query;
                    _this.totalcount = json.totalcount;
                  }
                  return _this.click();
                });
              }
            };
            _results.push(axle.reset = function() {
              this.rows = [];
              return this._primaryload = false;
            });
          }
          return _results;
        });
      }

      return SPSearchLogic;

    })();
  });

  module = angular.module('SpokeDataLogic', ['SpokeData']);

  module.factory('SPSpokeLogic', function() {
    var SPSpokeLogic;
    return SPSpokeLogic = (function() {

      SPSpokeLogic.name = 'SPSpokeLogic';

      function SPSpokeLogic($scope, $location, SPDataSpoke) {
        $scope.spoke = new SPDataSpoke();
        $scope.spoke.listing = [];
        $scope.spoke.properties = [];
        $scope.dirtySave = function() {
          $scope.spoke.dirtyforce = true;
          return $scope.save();
        };
        $scope.save = function() {
          var origSpokeKey;
          $scope.clearAlerts();
          origSpokeKey = $scope.spoke.key;
          $scope.spoke.save(function(json) {
            var error, _i, _len, _ref, _results;
            delete $scope.dirtywarnings;
            if (json.dirtywarnings) {
              $scope.dirtywarnings = json.dirtywarnings;
              return $scope.appendAlert('warning', 'Warning!', 'While saving we noticed another user has already saved changes to this object; Please check the changes and click "Force Save" if you wish to overwrite them');
            } else if ((json.errors != null) && json.errors.length !== 0) {
              _ref = json.errors;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                error = _ref[_i];
                _results.push($scope.appendAlert('error', 'Error!', error.message));
              }
              return _results;
            } else if (origSpokeKey === 'new') {
              $scope.appendAlert('success', 'Saved!', 'The new ' + $scope.spoke.modelkey + ' was created successfully');
              $location.path(spokesBaseViewUrl + '/' + $scope.spoke.modelkey + '/' + json.key);
              $location.replace();
              return $scope.fireNewCallback();
            } else {
              return $scope.appendAlert('success', 'Saved!', 'The ' + $scope.spoke.modelkey + ' was saved successfully');
            }
          });
          return delete $scope.spoke.dirtyforce;
        };
        $scope.reset = function() {
          var item, option, _i, _len, _ref, _results;
          $scope.spoke.properties = angular.copy($scope.spoke._originalproperties);
          _ref = $scope.spoke.properties;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            item = _ref[_i];
            if (item.type === 'dropdown') {
              _results.push((function() {
                var _j, _len1, _ref1, _results1;
                _ref1 = item.listing;
                _results1 = [];
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  option = _ref1[_j];
                  if (item.value.key === option.key) {
                    item.value = option;
                    break;
                  } else {
                    _results1.push(void 0);
                  }
                }
                return _results1;
              })());
            }
          }
          return _results;
        };
        $scope["delete"] = function() {
          return $scope.spoke["delete"](function(json) {
            $scope.clearAlerts();
            if ((json.errors != null) && json.errors.length !== 0) {
              return $scope.appendAlert('error', 'Failed To Delete', 'The object failed to be deleted: ' + json.errors[0]);
            } else {
              $scope.appendAlert('success', 'Deleted Successfully', 'Please navigate to another page.');
              $scope.spoke.properties = [];
              $scope.spoke.associations.children = [];
              return $scope.spoke.permissions = 0;
            }
          });
        };
        $scope.expanderClass = function(item) {
          if ((item != null) && 'expanded' in item && item.expanded) {
            return "down";
          } else {
            return "right";
          }
        };
        $scope.expanderToggle = function(item) {
          return item.expanded = !((item.expanded != null) && item.expanded);
        };
        $scope.expand = function(item) {
          return (item != null) && 'expanded' in item && item.expanded;
        };
        $scope.createNew = function(childclass, callback) {
          if (callback) {
            $scope.registerNewCallback(angular.copy($scope), callback);
          }
          return $location.path(spokesBaseViewUrl + '/' + childclass.modelkey + '/new');
        };
        $scope.spokeDetailFocus = function(spoke, item, direction) {
          $scope.search.reset();
          $scope.clearAlerts();
          return $location.path(spokesBaseViewUrl + '/' + spoke.modelkey + '/' + item.key);
        };
      }

      return SPSpokeLogic;

    })();
  });

  module.factory('SPRelinkLogic', [
    'SPLinkSpoke', 'SPSpokeLogic', function() {
      var SPRelinkLogic;
      return SPRelinkLogic = (function() {

        SPRelinkLogic.name = 'SPRelinkLogic';

        function SPRelinkLogic($scope, SPLinkSpoke) {
          $scope.afterNewCallback = function(newkey) {
            $scope.selectParent({
              'key': newkey
            });
            return $scope.appendAlert('info', 'Info', 'We have redirected you back to the ' + $scope.spoke.name + ' you were editing and have added the created ' + $scope.linkparents.name + ' to it. Please save the ' + $scope.spoke.name + ' to save the new link.');
          };
          $scope.unlinkParent = function(parent) {
            var linkResource;
            linkResource = new SPLinkSpoke;
            linkResource.modelkey = $scope.spoke.modelkey;
            linkResource.key = $scope.spoke.key;
            linkResource.parent = parent.modelkey;
            return linkResource.get(function(json) {
              $scope.spoke._invis[json.propertyname] = '';
              $scope.spoke._originalinvis[json.propertyname] = parent.data[0].key;
              parent.data = [];
              return $scope.appendAlert('info', 'Info', 'We have un-assigned the ' + json.name + ' from the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the un-link.');
            });
          };
          $scope.relinkParent = function(parent) {
            var linkResource;
            linkResource = new SPLinkSpoke;
            linkResource.modelkey = $scope.spoke.modelkey;
            linkResource.key = $scope.spoke.key;
            linkResource.parent = parent.assockey;
            $scope._linkparent = parent;
            return linkResource.get(function(json) {
              $scope.linkparents = json;
              return $('#parentLinkModal').modal('show');
            });
          };
          $scope.selectParent = function(parent) {
            if ($scope._linkparent.data.length === 0 || parent.key !== $scope._linkparent.data[0].key) {
              $scope.spoke._invis[$scope.linkparents.propertyname] = parent.key;
              $scope.spoke._originalinvis[$scope.linkparents.propertyname] = $scope._linkparent.data.length > 0 ? $scope._linkparent.data[0].key : '';
              $scope._linkparent.data[0] = parent;
              $scope.appendAlert('info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the link.');
            } else {
              $scope.appendAlert('info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '.');
            }
            return $('#parentLinkModal').modal('hide');
          };
        }

        return SPRelinkLogic;

      })();
    }
  ]);

  module.factory('SPTypeLogic', [
    'SPDataSpoke', function() {
      var SPTypeLogic;
      return SPTypeLogic = (function() {

        SPTypeLogic.name = 'SPTypeLogic';

        function SPTypeLogic($scope, SPDataSpoke) {
          var typeSaveProcess;
          $scope.typeEditModal = function(typename) {
            $scope.typealert = '';
            $scope.edittype = new SPDataSpoke();
            $scope.edittype.modelkey = typename;
            return $scope.edittype.list({
              modelkey: typename,
              list: true
            }, function(json) {
              if (!(json.errors != null) || json.errors.length === 0) {
                return $('#typeEditModal').modal('show');
              }
            });
          };
          $scope.newEditType = function() {
            var data, property, _i, _len, _ref;
            $scope.typealert = '';
            data = {
              key: 'new',
              properties: []
            };
            _ref = $scope.edittype.properties;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              property = _ref[_i];
              data.properties.push(angular.copy(property));
            }
            data._originalproperties = angular.copy(data.properties);
            return $scope.edittype.listing.push(data);
          };
          $scope.dirtySaveType = function(type) {
            var dp;
            $scope.typealert = '';
            $scope.processingtype = type;
            dp = new SPDataSpoke();
            dp.dirtyforce = true;
            angular.extend(dp, type, {
              modelkey: $scope.edittype.modelkey
            });
            return dp.save(typeSaveProcess);
          };
          $scope.saveType = function(type) {
            var dp;
            $scope.typealert = '';
            $scope.processingtype = type;
            dp = new SPDataSpoke();
            angular.extend(dp, type, {
              modelkey: $scope.edittype.modelkey
            });
            return dp.save(typeSaveProcess);
          };
          typeSaveProcess = function(json) {
            var error, type, _i, _len, _ref, _results;
            type = $scope.processingtype;
            delete type.typewarnings;
            if (json.dirtywarnings) {
              return type.typewarnings = json.dirtywarnings;
            } else if ((json.errors != null) && json.errors.length !== 0) {
              _ref = json.errors;
              _results = [];
              for (_i = 0, _len = _ref.length; _i < _len; _i++) {
                error = _ref[_i];
                $scope.typealert = 'error';
                $scope.typealerttitle = 'Error!';
                _results.push($scope.typealertmessage = error.message);
              }
              return _results;
            } else if (type.key === 'new') {
              type._originalproperties = angular.copy(type.properties);
              $scope.resetType(type);
              $scope.typealert = 'success';
              $scope.typealerttitle = 'Saved!';
              $scope.typealertmessage = 'The new ' + $scope.edittype.modelkey + ' was created successfully';
              return type.key = json.key;
            } else {
              type._originalproperties = angular.copy(type.properties);
              $scope.resetType(type);
              $scope.typealert = 'success';
              $scope.typealerttitle = 'Saved!';
              return $scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' was saved successfully';
            }
          };
          $scope.resetType = function(type) {
            var item, option, _i, _len, _ref, _results;
            $scope.typealert = '';
            type.properties = angular.copy(type._originalproperties);
            _ref = type.properties;
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              if (item.type === 'dropdown') {
                _results.push((function() {
                  var _j, _len1, _ref1, _results1;
                  _ref1 = item.listing;
                  _results1 = [];
                  for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                    option = _ref1[_j];
                    if (item.value.key === option.key) {
                      item.value = option;
                      break;
                    } else {
                      _results1.push(void 0);
                    }
                  }
                  return _results1;
                })());
              }
            }
            return _results;
          };
          $scope.deleteType = function(type) {
            $scope.typealert = '';
            return SPDataSpoke["delete"]({
              modelkey: $scope.edittype.modelkey,
              key: type.key
            }, function(json) {
              var index;
              if ((json.errors != null) && json.errors.length !== 0) {
                $scope.typealert = 'error';
                $scope.typealerttitle = 'Error';
                $scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' failed to delete, check that it is not referenced by any other objects.';
                return;
              }
              for (index in $scope.edittype.listing) {
                if (!($scope.edittype.listing[index] === type)) {
                  continue;
                }
                $scope.edittype.listing.splice(index, 1);
                break;
              }
              $scope.typealert = 'success';
              $scope.typealerttitle = 'Deleted!';
              $scope.typealertmessage = 'The ' + $scope.edittype.modelkey + ' was deleted successfully';
            });
          };
          $scope.isTypeUnchanged = function(type) {
            return angular.equals(type.properties, type._originalproperties);
          };
        }

        return SPTypeLogic;

      })();
    }
  ]);

}).call(this);