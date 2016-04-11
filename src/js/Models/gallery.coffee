Backbone = require 'backbone'
config = require './config'
Photo = require './photo'

module.exports = Backbone.Model.extend
	defaults:
		currentPhoto: null

	initialize: ->
		this.photos = new Backbone.Collection null, {model: Photo}
		self = this
		$.get(config.urlBase + '/services/containerfrompath/' + document.location.pathname.replace(/^.*\/galleries\//,''), (data) ->
			self.set data
			self.photos.url = config.urlBase + '/services/containers/' + data.id + '/photos'
			self.photos.fetch {reset: true}
		)
