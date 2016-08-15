BaseView = require './base-view'
Container = require './container'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'submit form' : 'doSubmit'
		'keyup input[name="name"]' : 'nameChanged'
		'change select[name="access"]' : 'changeAccess'
		'change select[name="downloadgallery"]' : 'changeDownloadGallery'
		'click .tabselector li' : 'selectTab'

	defaultData:
		createNew: false
		type: 'folder'
		name: ''
		description: ''
		url: ''
		urlsuffix: ''
		access: 0
		accesslink: ''
		maxdownloadsize: 1
		downloadgallery: 0
		downloadfee: 0
		idpayment: 0
		buyprints: 0
		markup: 100
		isclient: 0	

	initialize: (options) ->		
		this.accesslink = ''
		this.template = templates['edit-container-view']
		this.listenTo this.model, 'change:selectedContainer' , this.containerChanged
		this.listenTo this.model, 'change:editContainerToggle' , this.open
	
	open: ->
		if this.model.get('newContainerType') != null
			this.defaultData.createNew = true
			this.defaultData.type = this.model.get('newContainerType')
		this.setFormValues()
		this.$('.tabpanel').addClass('hide')
		this.$('#panel-general').removeClass('hide')
		this.$('#panel-general').removeClass('hide')
		this.$('.tabselector li').removeClass('selected')
		this.$('#tab-general').addClass('selected')
		this.$el.foundation 'open'

	selectTab: (e) ->
		e.preventDefault()
		#panelid = e.target.href.replace(/^.*#/,'')
		panelid = e.target.id.replace('tab-','panel-')
		this.$('.tabpanel').addClass('hide')
		this.$('#'+panelid).removeClass('hide')
		this.$('.tabselector li').removeClass('selected')
		$(e.target).addClass('selected')

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
		val = this.$('select[name="access"]').val()
		if val=='2'
			this.$('.access-link').removeClass 'hide'
		else
			this.$('.access-link').addClass 'hide'

	changeDownloadGallery: ->
		val = this.$('select[name="downloadgallery"]').val()
		if val=='2'
			this.$('.download-payment').removeClass 'hide'
		else
			this.$('.download-payment').addClass 'hide'

	containerChanged: (vm) ->
		self = this
		container = vm.get 'selectedContainer'
		return if !container
		$.get(config.servicesBase + '/pathfromcontainer/' + container.id, (json) ->
			container.set 'path' , json.path
			#self.$('.access-path').html json.path + '/' + container.get('urlsuffix')
		)

	setFormValues: ->
		container = this.model.get 'selectedContainer'
		newType = this.model.get('newContainerType')
		data = this.defaultData
		if container and newType == null
			data = container.toJSON()

		console.log data.path
		this.$('.title').html if newType==null then 'Edit ' + container.get('type') else 'New ' + newType
		this.$('input[name="name"]').val data.name
		this.$('input[name="description"]').val data.description
		this.$('input[name="url"]').val data.url
		this.$('select[name="isclient"]').val data.isclient
		this.$('select[name="access"]').val data.access
		this.$('select[name="maxdownloadsize"]').val data.maxdownloadsize
		this.$('select[name="downloadgallery"]').val data.downloadgallery
		this.$('input[name="downloadfee"]').val data.downloadfee
		this.$('input[name="idpayment"]').val data.idpayment
		this.$('select[name="buyprints"]').val data.buyprints
		this.$('input[name="markup"]').val data.markup
		this.$('.access-path').html if newType==null then data.path + '/' + data.urlsuffix else ''
		this.changeAccess()
		this.changeDownloadGallery()
		
		###
		if (data.access==1)
			this.$('.access-link').removeClass 'hide'
		else
			this.$('.access-link').addClass 'hide'

		if (data.access==1)
			this.$('.access-link').removeClass 'hide'
		else
			this.$('.access-link').addClass 'hide'

		this.$('.access-link').html config.urlBase + '/galleries/' + json.path + '/' + container.get('urlsuffix')
		###

	render: ->
		this.$el.html this.template {urlBase: config.urlBase + '/galleries/'}
