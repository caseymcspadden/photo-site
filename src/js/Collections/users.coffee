Backbone = require 'backbone'
User = require './user'

module.exports = Backbone.Collection.extend
	model: User
	url: ->
		this.urlBase + '/services/users/'		 

	initialize: (attributes, options) ->
		this.urlBase = options.urlBase
