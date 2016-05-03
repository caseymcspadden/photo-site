Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	initialize: (options) ->
		this.template = templates['cart-summary-view']
		this.listenTo this.collection, 'add remove reset', this.render
		this.render()

	render: ->
		data = {config: config}
		data.count = this.collection.length
		this.$el.html this.template(data)
