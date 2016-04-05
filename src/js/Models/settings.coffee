Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	urlRoot: -> config.urlBase + '/services/settings/'

	defaults :
		featuredgallery: 0
		portfoliofolder: 0

	initialize: (attributes, options) ->
		this.session = options.session
		this.listenTo this.session, 'change', this.sessionChanged

	sessionChanged: (session) ->
		this.set 'id', session.id
		console.log 'id changed to ' + this.get('id')
		this.fetch()
