require 'foundation'
Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'login'
		'click a.logout-item' : 'logout'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:uid' , this.setUser
		this.render()
		this.setUser(this.model)

	setUser: (m) ->
		if m.get('uid')==0
			this.$('ul.submenu').html '<li><a href="#" class="login-item">LOGIN</a></li>'
		else
			this.$('ul.submenu').html '<li><a href="#">PROFILE</a></li><li><a href="#">GALLERIES</a></li><li><a href="#" class="logout-item">LOGOUT</a></li>'

	login: (e) ->
		this.model.set 'loggingIn', true

	logout: (e) ->
		this.model.logout()

	render: ->
		this.$el.html this.template()
		this