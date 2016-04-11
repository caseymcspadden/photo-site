BaseView = require './base-view'
templates = require './jst'

module.exports = BaseView.extend

	initialize: (options) ->
		this.template = templates['gallery-photo-view']

	render: ->
		this.$el.html this.template()	
