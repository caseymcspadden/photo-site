BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['cart-view']
		this.render()
		this.listenTo this.collection, 'reset', this.addAll

	render: ->
		this.$el.html this.template()

	addAll: ->
		console.log "Adding all cart items"
