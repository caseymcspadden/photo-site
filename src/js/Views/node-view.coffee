Backbone = require 'backbone'
_ = require 'underscore'
Folder = require './folder'

module.exports = Backbone.View.extend
	events:
		'click .add-folder': 'addFolder'
		'click .add-gallery': 'addGallery'
		'click li > *:first-child' : 'test1'

	initialize: (options) ->
		this.template = options.JST['node-view'];
		console.log(options.template);
		console.log this.collection
		_.each this.collection.models, (element,index) ->
			console.log element
		this.listenTo(this.collection, 'add', this.folderAdded)
		this.listenTo(this.collection, 'remove', this.folderRemoved)

	render: ->
		this.$el.html this.template()

	folderAdded: ->
		console.log "Folder Added"
		console.log this.collection

	folderRemoved: ->
		console.log "Folder Removed"

	addFolder: ->
		console.log "Add Folder"
		console.log this.collection

	addGallery: ->
		console.log "Add Gallery"

	test1: ->
		console.log "test1 called"