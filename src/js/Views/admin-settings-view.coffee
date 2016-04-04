Backbone = require 'backbone'
Session = require './session'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit form' : 'saveSettings'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.session = options.session
		console.log this.session
		this.template = templates['admin-settings-view']

	saveSettings: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {remember: 0}
		for elem in arr
			data[elem.name] =  elem.value
		this.model.login data

	render: ->
		this.$el.html this.template()
		this
