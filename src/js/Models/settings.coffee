Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend
	url: ->
		config.urlBase + '/services/settings/' + this.id

	defaults :
		featuredGallery: 0
		portfolioFolder: 0

	initialize: (attributes, options) ->
		this.session = options.session
		console.log "Initializind Settings"
		console.log this.session
		this.listenTo this.session, 'change', this.sessionChanged

	sessionChanged: (session) ->
		console.log "session changed"
		this.id = session.id
		console.log this.id
		this.fetch()
		console.log this
