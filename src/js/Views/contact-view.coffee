BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	###
	events:
		'click .add-user' : 'addUser'
	###
	
	initialize: (options) ->
		this.template = templates['contact-view']
	
	render: ->
		this.$el.html this.template()
