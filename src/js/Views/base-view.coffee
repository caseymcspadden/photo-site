Backbone = require 'backbone'

module.exports = Backbone.View.extend

	assign : (view, selector) ->
		view.setElement(this.$(selector)).render()
