Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.Model.extend

	initialize: ->
		this.containers = new Backbone.Collection
		this.urlBase = config.urlBase + '/galleries/' + document.location.pathname.replace(/^.*\/galleries\//,'')
		self = this
		$.get(config.urlBase + '/services/containerfrompath/' + document.location.pathname.replace(/^.*\/galleries\//,''), (data) ->
			self.set data
			self.containers.url = config.urlBase + '/services/containers/' + data.id + '/containers'
			self.containers.fetch {reset: true}
		)

