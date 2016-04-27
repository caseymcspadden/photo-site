BaseView = require './base-view'
Container = require './container'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'submit form' : 'doSubmit'
		'keyup input[name="name"]' : 'nameChanged'
		'change select[name="access"]' : 'changeAccess'
		'click .tabselector a' : 'selectTab'

	initialize: (options) ->
		this.defaultData =
			createNew: false
			type: 'folder'
			name: ''
			description: ''
			url: ''
			urlsuffix: ''
			access: 0
			accesslink: ''
		
		this.accesslink = ''
		this.template = templates['edit-container-view']
		this.listenTo this.model, 'change:selectedContainer' , this.containerChanged
		if options.hasOwnProperty('containerType')
			this.defaultData.createNew = true
			this.defaultData.type = options.containerType

	selectTab: (e) ->
		e.preventDefault()
		panelid = e.target.href.replace(/^.*#/,'')
		this.$('.tabpanel').addClass('hide')
		this.$('#'+panelid).removeClass('hide')
		this.$('.tabselector li').removeClass('selected')
		this.getContainingElement(e.target, 'li').addClass('selected')

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

	changeAccess: ->
		console.log 'change access'
		val = this.$('select[name="access"]').val()
		if val=='1'
			this.$('.access-link').removeClass 'hide'
		else
			this.$('.access-link').addClass 'hide'

	containerChanged: (vm) ->
		self = this
		container = vm.get 'selectedContainer'
		return if !container
		$.get(config.servicesBase + '/pathfromcontainer/' + container.id, (json) ->
			self.accesslink = config.urlBase + '/galleries/' + json.path + '/' + container.get('urlsuffix')
			self.render()
			self.changeAccess()
		)

	render: ->
		container = this.model.get 'selectedContainer'
		data = this.defaultData
		if container and not this.defaultData.createNew
			data = container.toJSON()
			data.accesslink = this.accesslink
			data.createNew = false
		this.$el.html this.template(data)
		this
