BaseView = require './base-view'
templates = require './jst'
AdminArchivesRowView = require './admin-archives-row-view'
JsonView = require './json-view'

module.exports = BaseView.extend
	###
	events:
		'click .add-user' : 'addUser'
	###
	
	initialize: (options) ->
		this.template = templates['admin-archives-view']
		this.jsonView = new JsonView
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
	
	render: ->
		this.$el.html this.template()
		this.assign this.jsonView, '.json-view'
  		
	addOne: (model) ->
		adminArchivesRowView = new AdminArchivesRowView {model: model, jsonView: this.jsonView}
		this.$('.downloads').append adminArchivesRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this
