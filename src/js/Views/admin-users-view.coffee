#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit #addUser form' : 'newUser'

	initialize: (options) ->
		this.template = templates['admin-users-view']
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
		#this.listenTo this.collection, 'error', this.error
		this.render()

	newUser: (e) ->
		e.preventDefault()
		this.$('.error-message').addClass('hidden')
		arr = this.$('form').serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value

		###
		$.ajax(
			url: this.collection.url
			type: 'POST'
			context: this
			data: data
			success: (result) ->
				json = $.parseJSON(result)
				console.log json
				if json.hasOwnProperty('error')
					this.$('.error-message').html(json.message).removeClass('hidden')
				else
					this.collection.add json
					this.$('#addUser .close-button').trigger('click')
		)
		###
	
	render: ->
		this.$el.html this.template()

	#error: (data) ->
	#	console.log data
  		
	addOne: (user) ->
		console.log "Adding User"

	addAll: ->
		this.collection.each this.addOne, this

