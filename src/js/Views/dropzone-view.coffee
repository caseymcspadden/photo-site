Backbone = require 'backbone'
Dropzone = require 'dropzone'
templates = require './jst'
config = require './config'

module.exports = Backbone.View.extend

	events:
		'click .close-button' : 'close'	

	initialize: (options) ->
		this.template = templates['dropzone-view']
		this.listenTo this.model, 'change:selectedContainer', this.selectedContainerChanged

	render: ->
		this.$el.html this.template()
		self = this
		this.dropzone = new Dropzone('.filedrop',
			url: config.servicesBase + "/upload"
			uploadMultiple: true
			addRemoveLinks: false
			acceptedFiles: 'image/*'
			maxFileSize: 50
			headers:
				Watermark: '0'
			init: ->
				this.on("successmultiple", (files,responses) ->
					for file in files
						self.dropzone.removeFile file
					self.model.addPhotos $.parseJSON(responses) , true
				)
				this.on("sending", (a,b,c) ->
					#console.log b.response
				)
				this.on("complete", (file) ->
					#console.log file
				)
		)

	selectedContainerChanged: (m) ->
		container = this.model.get('selectedContainer')

	close: ->
		this.$('.filedrop').html ''

