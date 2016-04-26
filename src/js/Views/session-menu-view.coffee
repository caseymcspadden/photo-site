require 'foundation'
Backbone = require 'backbone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend
	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:id' , this.render
		this.render this.model

	render: (m) ->
		console.log "rendering"
		console.log m
		data = 
			uid: m.id
			config: config
			isadmin: m.get('isadmin')

		if m.id==0
			this.$el.html this.template(data)
		else
			self = this
			$.get(config.servicesBase + '/pathfromcontainer/' + m.get('idcontainer'), (json) ->
				data.galleryPath = json.path
				self.$el.html self.template(data)
			)
		this

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()
		document.location = config.urlBase
