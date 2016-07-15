BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	tagName: 'tr'

	events:
		'click .edit-user' : 'editUser'
		'click .isactive' : 'isActiveClicked'
		'click .isadmin' : 'isAdminClicked'
		'change .containers' : 'changeRootContainer'
	
	initialize: (options) ->
		this.template = templates['admin-users-row-view']
		this.editUserView = options.editUserView
		this.containers = options.containers
		this.listenTo this.model, 'change', this.render
		this.listenTo this.containers, 'reset', this.render

	isActiveClicked: (e) ->
		isactive = if this.model.get('isactive') then 0 else 1
		this.model.save {isactive: isactive}

	isAdminClicked: (e) ->
		isadmin = if this.model.get('isadmin') then 0 else 1
		this.model.save {isadmin: isadmin}

	changeRootContainer: (e) ->
		this.model.save {idcontainer: e.target.item(e.target.selectedIndex).value}

	editUser: (e) ->
		this.editUserView.open(this.model.collection, this.model)
		e.preventDefault()

	render: ->
		data = this.model.toJSON()
		data.containers = this.containers
		this.$el.html this.template(data)
		this
