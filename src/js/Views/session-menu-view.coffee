BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'click .login-item' : 'login'
		'click .logout-item' : 'logout'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:id' , this.render
		#this.render this.model

	render: () ->
		m = this.model
		data = 
			uid: if m.id then m.id else 0
			config: config
			isadmin: m.get('isadmin')

		if not m.id
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
		this.model.logout config.urlBase
