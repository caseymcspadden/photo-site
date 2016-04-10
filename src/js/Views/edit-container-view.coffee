Backbone = require 'backbone'
Container = require './container'
templates = require './jst'

module.exports = Backbone.View.extend
	events:
		'submit form' : 'doSubmit'
		'keyup input[name="name"]' : 'nameChanged'

	initialize: (options) ->
		this.defaultData =
			createNew: false
			type: 'folder'
			name: ''
			description: ''
			url: ''
			urlsuffix: ''
			access: 0

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

	nameChanged: (e) ->
		if this.defaultData.createNew
			this.$('input[name="url"]').val e.target.value.toLowerCase().replace(/ /g,'-')

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
