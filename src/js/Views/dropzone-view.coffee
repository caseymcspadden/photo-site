dropzone = require 'dropzone'
Backbone = require 'backbone'
templates = require './jst'

module.exports = Backbone.View.extend

	events:
		'click .close-button' : 'close'	

	initialize: (options) ->
		console.log "initializing dropzone"
		this.template = templates['dropzone-view']

	render: ->
		this.$el.html this.template()
		self = this
		this.$(".filedrop").dropzone
			url: "services/upload"
			uploadMultiple: true
			addRemoveLinks: false
			acceptedFiles: 'image/*'
			maxFileSize: 50
			init: ->
				this.on("successmultiple", (a,b) ->
					self.model.addPhotos $.parseJSON(b) , true
				)

	close: ->
		this.$('.filedrop').html ''

