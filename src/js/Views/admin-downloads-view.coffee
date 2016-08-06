BaseView = require './base-view'
templates = require './jst'
AdminDownloadsRowView = require './admin-downloads-row-view'
JsonView = require './json-view'
config = require './config'

module.exports = BaseView.extend
	###
	events:
		'click .add-user' : 'addUser'
	###
	
	initialize: (options) ->
		this.template = templates['admin-downloads-view']
		this.jsonView = new JsonView
		this.listenTo this.collection, 'add', this.addOne
		this.listenTo this.collection, 'reset', this.addAll
	
	render: ->
		this.$el.html this.template()
		this.assign this.jsonView, '.json-view'
  		
	addOne: (model) ->
		adminDownloadsRowView = new AdminDownloadsRowView {model: model, jsonView: this.jsonView}
		this.$('.downloads').append adminDownloadsRowView.render().el

	addAll: ->
		this.collection.each this.addOne, this
