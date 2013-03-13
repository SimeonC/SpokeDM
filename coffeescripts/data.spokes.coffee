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

module = angular.module 'SpokeData', []

module.factory 'SPDataCache', () ->
	_cache: {}#possibly load in future from cookies or something like that
	#uses the format "modelkey:key": json
	find: (modelkey, key) ->#key arguments is optional
		return @_cache[modelkey] and (!key or @_cache[modelkey][key])
	get: (modelkey, key) ->
		return @_cache[modelkey][key]
	save: (modelkey, key, data) ->
		if key is 'new' then return
		if not @_cache[modelkey]
			@_cache[modelkey] = {}
		@_cache[modelkey][key] = angular.copy data #if we don't copy we get a reference to the object, which is undesirable as children get updated on ALL cache objects, we want to have references to the children of the cached object
	delete: (modelkey, key) ->
		@hasdelete = true
		if @_cache[modelkey] and @_cache[modelkey][key]
			@_cache[modelkey][key] = 'delete'
module.factory 'SPLinkSpoke', ($resource, $rootScope) ->
	SPLinkSpoke = $resource spokesLinkDataUrl+'/:modelkey/:key', {modelkey:'@modelkey', key:'@key', parent:'@parent'}
	SPLinkSpoke::get = (cb) ->
		return SPLinkSpoke.get @, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0
				angular.extend @, json
				cb? json
	return SPLinkSpoke
module.factory 'SPDataSpoke', ($resource, $rootScope, SPDataCache) ->
	SPDataSpoke = $resource spokesBaseDataUrl+'/:modelkey/:key', {modelkey:'@modelkey', key:'@key'}, {
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
	SPDataSpoke::get = (cb) ->
		#caching logic
		if not @newmodelkey? and SPDataCache.find @modelkey, @key
			angular.extend @, SPDataCache.get @modelkey, @key
			#remap dropdown value references and other cache changes
			for item in @properties
				if item.type is 'dropdown'
					if item.value == "" then item.value = null
					for option in item.listing
						if item.value.key is option.key
							item.value = option
							break
			if(SPDataCache.hasdelete)#if no delete occurs don't run this logic - would slow down processing lots
				for i of @associations.parents when SPDataCache.find @associations.parents[i].modelkey, @associations.parents[i].data[0].key and SPDataCache.get @associations.parents[i].modelkey, @associations.parents[i].data[0].key is 'delete' then @associations.parents.splice i, 1
				for i of @associations.children when SPDataCache.find @associations.children[i].modelkey
					for j of @associations.children[i].data when SPDataCache.find @associations.children[i].data[j].modelkey, @associations.children[i].data[j].key and SPDataCache.get @associations.children[i].modelkey, @associations.children[i].data[j].key is 'delete' then @associations.children[i].data.splice j, 1
			cb? {}
			return
		params =
			modelkey: @modelkey
			key: @key
		if @newmodelkey? then params['newkey'] = @newmodelkey
		return SPDataSpoke.get params, (json) =>
			if json.errors? and json.errors.length isnt 0 then return $rootScope.$broadcast 'spokeLoadError', json.errors
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0
				if json.properties
					for item in json.properties
						if item.type is 'dropdown'
							if item.value == "" then item.value = null
							for option in item.listing
								if item.value is option.key
									item.value = option
									break
					if(SPDataCache.hasdelete)#if no delete occurs don't run this logic - would slow down processing lots
						for i of json.associations.parents when SPDataCache.find json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key and SPDataCache.get json.associations.parents[i].modelkey, json.associations.parents[i].data[0].key is 'delete' then json.associations.parents.splice i, 1
						for i of json.associations.children when SPDataCache.find json.associations.children[i].modelkey
							for j of json.associations.children[i].data when SPDataCache.find json.associations.children[i].data[j].modelkey, json.associations.children[i].data[j].key and SPDataCache.get json.associations.children[i].modelkey, json.associations.children[i].data[j].key is 'delete' then json.associations.children[i].data.splice j, 1
				else if json.listing?
					if(SPDataCache.hasdelete)#if no delete occurs don't run this logic - would slow down processing lots
						for i of json.listing when SPDataCache.find json.modelkey, json.listing[i].key and SPDataCache.get json.modelkey, json.listing[i].key is 'delete' then json.listing.splice i, 1
				#RESET the references, s.t. we do not end up with references
				@_invis = {}
				@_originalinvis = {}
				@_originalproperties = []
				@associations = {}
				@errors = []
				@properties = []
				angular.extend @, json
				@_originalproperties = angular.copy @properties #properties is an array of objects - to maintain an ordering
				@_originalinvis = angular.copy @_invis
			if @key isnt 'new' and not json.listing? then SPDataCache.save @modelkey, @key, @
			cb? json
			return
	SPDataSpoke::save = (cb) ->
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
		return SPDataSpoke.save {modelkey: @modelkey, key: @key}, data, (json) =>
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
				SPDataCache.save @modelkey, @key, ''#evaluates to false so we reload the object next get process, we do this so that calculated properties and data edited by callbacks are loaded correctly
			
				if json.key? then @key = json.key
			cb? json
	SPDataSpoke::delete = (cb) ->
		return SPDataSpoke.delete {modelkey: modelkey, key: @key}, (json) =>
			if json.loginerror?
				$rootScope.broadcast "SpokeUserLoggedOut", json
				return
			if not json.errors? or json.errors.length is 0 then SPDataCache.delete @modelkey, @key
			cb? json
	SPDataSpoke::list = (params, cb) ->
		return SPDataSpoke.list params, (json) =>
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
							if @listing[i].value == "" then @listing[i].value = null
							for option in @listing[i].listing
								if object[item].value is option.key
									object[item].value = option
									break
					@listing[i]._originalproperties = []
					@listing[i]._originalproperties = angular.copy @listing[i].properties #properties is an array of objects - to maintain an ordering
			cb? json
	SPDataSpoke::isUnchanged = -> angular.equals(@_invis, @_originalinvis) && angular.equals @properties, @_originalproperties
	return SPDataSpoke

