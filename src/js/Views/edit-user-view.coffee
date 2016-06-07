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

		this.template= templates['edit-user-view']

	open: (model) ->
		this.model = model
		this.render()
		this.$el.foundation 'open'

	doSubmit: (e) ->
		e.preventDefault()		
		arr = $(e.target).serializeArray()
		console.log e
		console.log arr
		
		###
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		if this.model
			this.model.save data
		else
			this.collection.create data, {wait: true}
		###
		this.$el.foundation 'close'

	render: ->
		data = if this.model then this.model.toJSON() else this.defaultData 
		this.$el.html this.template(data)
