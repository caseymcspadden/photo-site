Backbone = require 'backbone'
Container = require './container'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit form' : 'doSubmit'

	initialize: (options) ->
		this.defaultData =
			createNew: false
			type: 'folder'
			name: ''
			description: ''
			url: ''
			urlsuffix: ''

		this.template = templates['edit-container-view']
		this.listenTo this.model, 'change:selectedContainer' , this.changingContainer
		if options.hasOwnProperty('containerType')
			this.defaultData.createNew = true
			this.defaultData.type = options.containerType

	doSubmit: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		container = this.model.get 'selectedContainer'	
		if this.defaultData.createNew
			data.type = this.defaultData.type
			this.model.createContainer data
		else
			container.save data
		this.$('.close-button').trigger('click')		

	changingContainer: (vm) ->
		this.render()

	render: ->
		container = this.model.get 'selectedContainer'
		data = this.defaultData
		if container and not this.defaultData.createNew
			data = container.toJSON()
			data.createNew = false
		this.$el.html this.template(data)
		this
