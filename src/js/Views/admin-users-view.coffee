Backbone = require 'backbone'
BaseView = require './base-view'
templates = require './jst'
AdminUsersRowView = require './admin-users-row-view'
EditUserView = require './edit-user-view'
config = require './config'

module.exports = BaseView.extend
	events:
		'click .add-user' : 'addUser'

	initialize: (options) ->
		this.template = templates['admin-users-view']
		this.editUserView = new EditUserView {collection: this.collection}
		this.containers = new Backbone.Collection
		this.containers.url = config.urlBase + '/bamenda/containers'
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
		this.containers.fetch {reset: true}

	addUser: (e) ->
		e.preventDefault()
		this.editUserView.open this.collection , null
	
	render: ->
		this.$el.html this.template()
		this.assign this.editUserView, '.edit-user-view'
  		
	addOne: (user) ->
		adminUsersRowView = new AdminUsersRowView {model: user, editUserView: this.editUserView, containers: this.containers}
		this.$('.users').append adminUsersRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this
