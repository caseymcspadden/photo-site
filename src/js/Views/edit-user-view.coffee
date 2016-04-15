Backbone = require 'backbone'
templates = require './jst'
User = require './user'

module.exports = Backbone.View.extend
	events:
		'submit form' : 'doSubmit'

	initialize: (options) ->
		this.defaultData =
			name: ''
			email: ''
			company: ''
			idcontainer: 0
			isadmin: 0

		this.newTemplate = templates['new-user-view']
		this.editTemplate = templates['new-user-view']
		console.log User

	open: ->
		this.render()
		this.$el.foundation 'open'

	doSubmit: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		if this.model
			this.model.save data
		else
			this.collection.create data, {wait: true}
		this.$('.close-button').trigger('click')

	render: ->
		if this.model 
			this.$el.html this.editTemplate(this.model.toJSON())
		else
			this.$el.html this.newTemplate(this.defaultData)
