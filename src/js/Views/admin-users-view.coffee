BaseView = require './base-view'
templates = require './jst'
EditUserView = require './edit-user-view'

module.exports = BaseView.extend
	events:
		'click .add-user' : 'addUser'
		'click .edit-user' : 'editUser'

	initialize: (options) ->
		this.template = templates['admin-users-view']
		this.editUserView = new EditUserView {collection: this.collection}
		this.userTemplate = templates['admin-users-row-view']
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll

	addUser: (e) ->
		this.editUserView.model = null
		this.editUserView.open()
	
	editUser: (e) ->
		id = e.target.id.replace('user-', '')
		model = this.collection.get id
		console.log model
		e.preventDefault()

	render: ->
		this.$el.html this.template()
		this.assign this.editUserView, '.edit-user-view'
  		
	addOne: (user) ->
		this.$('.users').append this.userTemplate user.toJSON()

	addAll: ->
		this.collection.each this.addOne, this

