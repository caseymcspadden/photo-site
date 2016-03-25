#Gallery View manages a gallery or folder

Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit #addUser form' : 'addUser'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.template = templates['admin-users-view']
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
		#this.listenTo this.collection, 'error', this.error
		this.render()

	addUser: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		val = this.collection.create data , {wait: true}
		if (val.id)
			this.$('#addUser .close-button').trigger('click')
	
	render: ->
		this.$el.html this.template()

	#error: (data) ->
	#	console.log data
  		
	addOne: (user) ->
		console.log "Adding User"
		console.log user

	addAll: ->
		this.collection.each this.addOne, this

