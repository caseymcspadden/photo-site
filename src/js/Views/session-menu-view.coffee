require 'foundation'
Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.listenTo this.model, 'change:id' , this.setUser
		this.setUser(this.model)

	setUser: (m) ->
		if m.id==0
			this.$('ul.submenu').html ''
			this.$('.top-item').html 'LOGIN'
			this.$('.top-item').addClass('login-item')
		else
			this.$('.top-item').html 'CLIENT'
			this.$('.top-item').removeClass('login-item')
			self = this
			$.get(config.servicesBase + '/pathfromcontainer/' + m.get('idcontainer'), (json) ->
				html = 	'<li><a href="#">PROFILE</a></li><li><a href="' + config.urlBase + '/galleries/' + json.path + '">MY GALLERIES</a></li>'
				html += '<li><a href="' + config.adminBase + '">ADMIN</a></li>' if m.get('isadmin')
				html += '<li><a href="#" class="logout-item">LOGOUT</a></li>'
				self.$('ul.submenu').html html
			)

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()
		document.location = config.urlBase

	render: ->
		this