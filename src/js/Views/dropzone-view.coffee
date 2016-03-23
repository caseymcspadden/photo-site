Backbone = require 'backbone'
Dropzone = require 'dropzone'
templates = require './jst'

module.exports = Backbone.View.extend

	events:
		'click .close-button' : 'close'	

	initialize: (options) ->
		this.template = templates['dropzone-view']
		this.listenTo this.model, 'change:selectedContainer', this.selectedContainerChanged

	render: ->
		this.$el.html this.template()
		self = this
		#this.$(".filedrop").dropzone
		this.dropzone = new Dropzone('.filedrop',
			url: "services/upload"
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
		#this.dropzone.options.headers.Watermark = '0'
		#this.dropzone.options.headers.Watermark = '1' if container.get('watermark')==1

	close: ->
		this.$('.filedrop').html ''

