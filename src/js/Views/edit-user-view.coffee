BaseView = require './base-view'
templates = require './jst'
User = require './user'

module.exports = BaseView.extend
	events:
		'submit form' : 'doSubmit'

	defaultData:
		id: 0
		name: ''
		email: ''
		company: ''
		idcontainer: 0
		isactive: 1
		isadmin: 0

	initialize: (options) ->
		this.template= templates['edit-user-view']

	open: (collection, model) ->
		this.collection=collection
		this.model = model
		this.render()
		this.$el.foundation 'open'

	doSubmit: (e) ->
		e.preventDefault()		
		arr = $(e.target).serializeArray()
		data = {}
		self = this
		for elem in arr
			data[elem.name]=elem.value
		if this.model
			this.model.save(
				data
				wait: true
				error: (model, response, options) ->
					self.$('.error-message').html response.responseJSON.message
					self.$('.error-message').removeClass('hide')
				success: (model, response, options) ->
					self.$el.foundation 'close'
			)
		else
			this.collection.create(
				data
				wait: true
				error: (model, response, options) ->
					self.$('.error-message').html response.responseJSON.message
					self.$('.error-message').removeClass('hide')
				success: (model, response, options) ->
					response['password'] = response['repeat-password'] = ''
					model.set response
					self.$el.foundation 'close'
			)
		this

	render: ->
		data = if this.model then this.model.toJSON() else this.defaultData 
		this.$el.html this.template(data)
