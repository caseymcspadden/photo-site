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
		data = 
			uid: m.id
			config: config
			isadmin: m.get('isadmin')

		if m.id==0
			this.$el.html this.template(data)
		else
			$.ajax(
				url: config.servicesBase + '/pathfromcontainer/' + m.get('idcontainer')
				context: this
				success: (json) ->
					data.galleryPath = json.path
					this.$el.html this.template(data)
			)
		this

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()
		document.location = config.urlBase
