Backbone = require 'backbone'
Product = require './product'
config = require './config'

module.exports = Backbone.Collection.extend
	model: Product

	###
	initialize: (options) ->
		console.log "initializing containerproducts"
		this.url = config.urlBase + '/bamenda/containers/' + options.idcontainer + '/products'
	###
	update: (idcontainer, idphoto) ->
		this.url = config.urlBase + '/bamenda/containers/' + idcontainer + '/photos/' + idphoto + '/products'
		this.fetch {reset: true}