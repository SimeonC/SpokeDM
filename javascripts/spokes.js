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
  var SpokeMain, module;

  module = angular.module('spokes', ['ngResource', 'SpokeUtilities', '$strap.directives']);

  module.factory('DataCache', function() {
    var DataCache;
    DataCache = {};
    DataCache.find = function(modelkey, key) {
      return this[modelkey] && (!key || this[modelkey][key]);
    };
    DataCache.get = function(modelkey, key) {
      return this[modelkey][key];
    };
    DataCache.save = function(modelkey, key, data) {
      if (!this[modelkey]) {
        this[modelkey] = {};
      }
      return this[modelkey][key] = data;
    };
    DataCache["delete"] = function(modelkey, key) {
      this.hasdelete = true;
      if (this[modelkey] && this[modelkey][key]) {
        return this[modelkey][key] = 'delete';
      }
    };
    return DataCache;
  });

  module.factory('LinkSpoke', function($resource, $rootScope) {
    var LinkSpoke;
    LinkSpoke = $resource(spokesLinkDataUrl + '/:modelkey/:key', {
      modelkey: '@modelkey',
      key: '@key',
      parent: '@parent'
    });
    LinkSpoke.prototype.get = function(cb) {
      var _this = this;
      return LinkSpoke.get(this, function(json) {
        if (json.loginerror != null) {
          $rootScope.broadcast("SpokeUserLoggedOut", json);
          return;
        }
        if (!(json.errors != null) || json.errors.length === 0) {
          angular.extend(_this, json);
          return typeof cb === "function" ? cb(json) : void 0;
        }
      });
    };
    return LinkSpoke;
  });

  module.factory('DataSpoke', function($resource, $rootScope, DataCache) {
    var DataSpoke;
    DataSpoke = $resource(spokesBaseDataUrl + '/:modelkey/:key', {
      modelkey: '@modelkey',
      key: '@key'
    }, {
      'get': {
        method: 'GET',
        params: {
          'delete': false
        }
      },
      'delete': {
        method: 'GET',
        params: {
          'delete': true
        }
      },
      'save': {
        method: 'POST'
      },
      'list': {
        method: 'GET',
        params: {
          'list': true
        }
      }
    });
    DataSpoke.prototype.get = function(cb) {
      var params,
        _this = this;
      if (!(this.newmodelkey != null) && DataCache.find(this.modelkey, this.key)) {
        angular.extend(this, DataCache.get(this.modelkey, this.key));
        return;
      }
      params = {
        modelkey: this.modelkey,
        key: this.key
      };
      if (this.newmodelkey != null) {
        params['newkey'] = this.newmodelkey;
      }
      return DataSpoke.get(params, function(json) {
        var i, item, j, option, _i, _j, _len, _len1, _ref, _ref1;
        if ((json.errors != null) && json.errors.length !== 0) {
          return $rootScope.$broadcast('spokeLoadError', json.errors);
        }
        if (json.loginerror != null) {
          $rootScope.broadcast("SpokeUserLoggedOut", json);
          return;
        }
        if (!(json.errors != null) || json.errors.length === 0) {
          if (json.properties) {
            json.properties._invischanged = false;
            _ref = json.properties;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              item = _ref[_i];
              if (item.type === 'dropdown') {
                _ref1 = item.listing;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  option = _ref1[_j];
                  if (item.value === option.key) {
                    item.value = option;
                    break;
                  }
                }
              }
            }
            if (DataCache.hasdelete) {
              for (i in json.associations.parents) {
                if (DataCache.find(json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key && DataCache.get(json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key === 'delete'))) {
                  json.associations.parents.splice(i, 1);
                }
              }
              for (i in json.associations.children) {
                if (DataCache.find(json.associations.children[i].modelkey)) {
                  for (j in json.associations.children[i].data) {
                    if (DataCache.find(json.associations.children[i].data[j].modelkey, json.associations.children[i].data[j].key && DataCache.get(json.associations.children[i].modelkey, json.associations.children[i].data[j].key === 'delete'))) {
                      json.associations.children[i].data.splice(j, 1);
                    }
                  }
                }
              }
            }
          } else if (json.listing) {
            if (DataCache.hasdelete) {
              for (i in json.listing) {
                if (DataCache.find(json.modelkey, json.listing[i].key && DataCache.get(json.modelkey, json.listing[i].key === 'delete'))) {
                  json.listing.splice(i, 1);
                }
              }
            }
          }
          angular.extend(_this, json);
          _this._originalproperties = angular.copy(_this.properties);
        }
        if (_this.key !== 'new') {
          DataCache.save(_this.modelkey, _this.key, _this);
        }
        if (typeof cb === "function") {
          cb(json);
        }
      });
    };
    DataSpoke.prototype.save = function(cb) {
      var data, item, _i, _j, _k, _len, _len1, _len2, _ref, _ref1, _ref2,
        _this = this;
      data = {
        data: {},
        origdata: {}
      };
      _ref = this.properties;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        item = _ref[_i];
        data.data[item.name] = item.type === 'dropdown' ? item.value.key : item.type === 'boolean' && item.value ? 1 : item.type === 'boolean' && !item.value ? 0 : item.value;
      }
      _ref1 = this._originalproperties;
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        item = _ref1[_j];
        data.origdata[item.name] = item.type === 'dropdown' ? item.value.key : item.type === 'boolean' && item.value ? 1 : item.type === 'boolean' && !item.value ? 0 : item.value;
      }
      if ((this._invis != null) && this._invis) {
        _ref2 = this._invis;
        for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
          item = _ref2[_k];
          data.data[item.name] = item.value;
        }
      }
      if (this.dirtyforce) {
        data.dirtyforce = this.dirtyforce;
      }
      return DataSpoke.save({
        modelkey: this.modelkey,
        key: this.key
      }, data, function(json) {
        if (json.loginerror != null) {
          $rootScope.broadcast("SpokeUserLoggedOut", json);
          return;
        }
        if (json.dirtywarnings) {
          if (typeof cb === "function") {
            cb(json);
          }
          return;
        }
        if (!(json.errors != null) || json.errors.length === 0) {
          _this._originalproperties = angular.copy(_this.properties);
          delete _this._invis;
          _this._invischanged = false;
          DataCache.save(_this.modelkey, _this.key, '');
          if (json.key != null) {
            _this.key = json.key;
          }
          return typeof cb === "function" ? cb(json) : void 0;
        }
      });
    };
    DataSpoke.prototype["delete"] = function(cb) {
      var _this = this;
      return DataSpoke["delete"]({
        modelkey: modelkey,
        key: this.key
      }, function(json) {
        if (json.loginerror != null) {
          $rootScope.broadcast("SpokeUserLoggedOut", json);
          return;
        }
        if (!(json.errors != null) || json.errors.length === 0) {
          DataCache["delete"](_this.modelkey, _this.key);
        }
        return typeof cb === "function" ? cb(json) : void 0;
      });
    };
    DataSpoke.prototype.list = function(params, cb) {
      var _this = this;
      return DataSpoke.list(params, function(json) {
        var col, i, option, _i, _j, _len, _len1, _ref, _ref1;
        if (json.loginerror != null) {
          $rootScope.broadcast("SpokeUserLoggedOut", json);
          return;
        }
        if (!(json.errors != null) || json.errors.length === 0) {
          angular.extend(_this, json);
          for (i in _this.listing) {
            _this.listing[i].properties = [];
            _ref = _this.columns;
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              col = _ref[_i];
              _this.listing[i].properties.push(angular.extend({}, col, {
                "value": _this.listing[i][col.name]
              }));
              if (_this.listing[i].type === 'dropdown') {
                _ref1 = _this.listing[i].listing;
                for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
                  option = _ref1[_j];
                  if (object[item].value === option.key) {
                    object[item].value = option;
                    break;
                  }
                }
              }
            }
            _this.listing[i]._originalproperties = [];
            _this.listing[i]._originalproperties = angular.copy(_this.listing[i].properties);
          }
          return typeof cb === "function" ? cb(json) : void 0;
        }
      });
    };
    return DataSpoke;
  });

  module.config(function($routeProvider, $locationProvider) {
    $locationProvider.html5Mode(true);
    return $routeProvider.when(spokesBaseViewUrl + '/:modelkey/:key');
  });

  SpokeMain = (function() {

    SpokeMain.name = 'SpokeMain';

    function SpokeMain($scope, $route, $routeParams, $location, $timeout, $resource, $filter, DataSpoke, LinkSpoke) {
      $scope.geterrors = [];
      $scope.geterrorsplash = false;
      $scope.afterNewCallbacks = [];
      $scope.registerNewCallback = function(scope, cb) {
        return $scope.afterNewCallbacks.push({
          "scope": scope,
          "fire": cb
        });
      };
      $scope.fireNewCallback = function() {
        var callback;
        callback = $scope.afterNewCallbacks.pop();
        angular.extend($scope, callback.scope);
        return callback.fire(json.key);
      };
      $scope.$on("spokeLoadError", function(evt, errors) {
        $scope.geterrors = errors;
        return $scope.geterrorsplash = true;
      });
      $scope.$on("$routeChangeSuccess", function() {
        $scope.geterrors = [];
        $scope.geterrorsplash = false;
        if ($routeParams.key === 'new' && ($scope.spoke.modelkey != null) && ($scope.spoke.key != null)) {
          $scope.spoke.newmodelkey = $routeParams.modelkey;
          if (($scope.spoke.modelkey != null) && ($scope.spoke.key != null) && ($routeParams.modelkey != null) && ($routeParams.key != null)) {
            return $scope.spoke.get(function(json) {
              if (!(json.errors != null) || json.errors.length === 0) {
                $scope.spoke.modelkey = $routeParams.modelkey;
                return $scope.spoke.key = $routeParams.key;
              }
            });
          }
        } else {
          $scope.spoke = new DataSpoke();
          $scope.spoke.modelkey = $routeParams.modelkey;
          $scope.spoke.key = $routeParams.key;
          if (($scope.spoke.modelkey != null) && ($scope.spoke.key != null) && ($routeParams.modelkey != null) && ($routeParams.key != null)) {
            return $scope.spoke.get();
          }
        }
      });
      this.searchLogic($scope, $timeout, $resource, $filter);
      this.alertsLogic($scope);
      this.spokeLogic($scope, $location, DataSpoke);
      this.relinkLogic($scope, LinkSpoke);
      this.typeLogic($scope, DataSpoke);
      $route.reload();
    }

    SpokeMain.prototype.searchLogic = function($scope, $timeout, $resource, $filter) {
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
        }
      };
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
      $scope.search.scrollleft = function() {
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
      };
      $scope.search.scrollright = function() {
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
      };
      $scope.search.scrollnav = function() {
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
      $scope.incTimer = function() {
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
        return setTimeout($scope.incTimer, 750);
      };
      $scope.incTimer();
      $scope.toggleAxel = function(axle) {
        if ($scope.search.searchstring.$ === '') {
          return axle.active = !axle.active;
        }
      };
      return $scope.searchLimit = function() {
        var axle, rows, _i, _len, _ref;
        rows = 0;
        _ref = $scope.search.results;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          axle = _ref[_i];
          rows += axle.rows.length;
        }
        return Math.Min(40, 40 / rows);
      };
    };

    SpokeMain.prototype.alertsLogic = function($scope) {
      $scope.alerts = [];
      $scope.clearAlerts = function() {
        return $scope.alerts = [];
      };
      $scope.removeAlert = function(index) {
        return $scope.alerts.splice(index, 1);
      };
      return $scope.appendAlert = function(type, title, message) {
        return $scope.alerts.push({
          type: type,
          title: title,
          message: message
        });
      };
    };

    SpokeMain.prototype.spokeLogic = function($scope, $location, DataSpoke) {
      $scope.spoke = new DataSpoke();
      $scope.spoke.listing = [];
      $scope.spoke.properties = [];
      $scope.spoke.children = [];
      $scope.spoke.parents = [];
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
          console.log(origSpokeKey);
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
      $scope.isUnchanged = function() {
        return !$scope.spoke._invischanged && angular.equals($scope.spoke.properties, $scope.spoke._originalproperties);
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
      $scope.detailFocus = function(spoke, item, direction) {
        $scope.search.reset();
        $scope.clearAlerts();
        return $location.path(spokesBaseViewUrl + '/' + spoke.modelkey + '/' + item.key);
      };
      return $scope.extDynamicLink = function(baseurl, item) {
        if (!baseurl || baseurl === '') {
          return '';
        }
        if (item.key) {
          return baseurl.replace('spokekeyplaceholder', item.key);
        }
        return baseurl.replace('spokekeyplaceholder', '');
      };
    };

    SpokeMain.prototype.relinkLogic = function($scope, LinkSpoke) {
      $scope.afterNewCallback = function(newkey) {
        $scope.selectParent({
          'key': newkey
        });
        $scope.spoke._invischanged = true;
        return $scope.appendAlert('info', 'Info', 'We have redirected you back to the ' + $scope.spoke.name + ' you were editing and have added the created ' + $scope.linkparents.name + ' to it. Please save the ' + $scope.spoke.name + ' to save the new link.');
      };
      $scope.unlinkParent = function(parent) {
        var linkResource;
        linkResource = new LinkSpoke;
        linkResource.modelkey = $scope.spoke.modelkey;
        linkResource.key = $scope.spoke.key;
        linkResource.parent = parent.modelkey;
        return linkResource.get(function(json) {
          var val;
          val = {
            "name": json.propertyname,
            "value": '',
            "type": "string"
          };
          if ($scope.spoke._invis != null) {
            $scope.spoke._invis.push(val);
          } else {
            $scope.spoke._invis = [val];
          }
          $scope.spoke._originalproperties.push({
            "name": json.propertyname,
            "value": parent.data[0].key
          });
          parent.data = [];
          $scope.spoke._invischanged = true;
          return $scope.appendAlert('info', 'Info', 'We have un-assigned the ' + json.name + ' from the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the un-link.');
        });
      };
      $scope.relinkParent = function(parent) {
        var linkResource;
        linkResource = new LinkSpoke;
        linkResource.modelkey = $scope.spoke.modelkey;
        linkResource.key = $scope.spoke.key;
        linkResource.parent = parent.modelkey;
        $scope._linkparent = parent;
        return linkResource.get(function(json) {
          $scope.linkparents = json;
          return $('#parentLinkModal').modal('show');
        });
      };
      return $scope.selectParent = function(parent) {
        var val;
        val = {
          "name": $scope.linkparents.propertyname,
          "value": parent.key
        };
        if ($scope.spoke._invis != null) {
          $scope.spoke._invis.push(val);
        } else {
          $scope.spoke._invis = [val];
        }
        $scope.spoke._invischanged = true;
        $scope.spoke._originalproperties.push({
          "name": $scope.linkparents.propertyname,
          "value": $scope._linkparent.data.length > 0 ? $scope._linkparent.data[0].key : ''
        });
        $scope._linkparent.data[0] = parent;
        $scope.appendAlert('info', 'Info', 'We have assigned the ' + $scope.linkparents.name + ' to the ' + $scope.spoke.name + '. Please save the ' + $scope.spoke.name + ' to save the link.');
        return $('#parentLinkModal').modal('hide');
      };
    };

    SpokeMain.prototype.typeLogic = function($scope, DataSpoke) {
      var typeSaveProcess;
      $scope.typeEditModal = function(typename) {
        $scope.typealert = '';
        $scope.edittype = new DataSpoke();
        $scope.edittype.modelkey = typename;
        return $scope.edittype.list({
          modelkey: typename,
          list: true
        }, function() {
          return $('#typeEditModal').modal('show');
        });
      };
      $scope.newEditType = function() {
        var column, data, _i, _len, _ref;
        $scope.typealert = '';
        data = {
          key: 'new',
          properties: []
        };
        _ref = $scope.edittype.columns;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          column = _ref[_i];
          data.properties.push(angular.copy(column));
        }
        data._originalproperties = angular.copy(data.properties);
        return $scope.edittype.listing.push(data);
      };
      $scope.dirtySaveType = function(type) {
        var dp;
        $scope.typealert = '';
        $scope.processingtype = type;
        dp = new DataSpoke();
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
        dp = new DataSpoke();
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
        return DataSpoke["delete"]({
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
      return $scope.isTypeUnchanged = function(type) {
        return angular.equals(type.properties, type._originalproperties);
      };
    };

    return SpokeMain;

  })();

  this.SpokeMain = SpokeMain;

}).call(this);
