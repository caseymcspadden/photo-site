Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend
	className: 'reveal'

	events:
		'click a.login-item' : 'clicked'
		#'submit #fv-addGallery form' : 'addGallery'
		#'click .featured-thumbnail' : 'selectContainer'

	initialize: (options) ->
		this.template = templates['session-menu-view']
		this.listenTo this.model, 'change:uid' , this.uidChanged
		this.render()

	uidChanged: (m) ->
		this.$('.login-item').html(if m.get('uid')==0 then 'LOGIN' else 'LOGOUT')

	clicked: (e) ->
		if this.model.get('uid')==0
			this.model.set 'loggingIn', true
		else
			this.model.logout()

	render: ->
		this.$el.html this.template()
		this
