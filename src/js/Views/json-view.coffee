BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['json-view']

	fetchJSON: (url) ->
		this.$('.content').html ''
		self = this
		$.get(url, (json) ->
			self.$('.content').html JSON.stringify(json,null,4)
		)

	render: ->
		this.$el.html this.template



