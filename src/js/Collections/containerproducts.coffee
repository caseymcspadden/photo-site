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
	update: (id) ->
		this.url = config.urlBase + '/bamenda/containers/' + id + '/products'
		this.fetch {reset: true}