BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	events:
		'click .create-archive' : 'createArchive'
		'open.zf.reveal' : 'open'

	initialize: (options) ->
		this.template = templates['download-gallery-view']
		this.listenTo this.model, 'change:error', this.notifyError
		this.listenTo this.model, 'change:archiveProgress', this.archiveProgress
		this.listenTo this.model.photos, 'reset', this.initializeProgress

	render: ->
		this.$el.html this.template {waitsrc: config.urlBase+'/images/wait-bar.gif'}

	open: ->
		this.$('.archive-wait').addClass 'hide'
		this.$('.archive-notify').addClass 'hide'
		this.$('.progress').addClass 'hide'

	initializeProgress: ->
		this.$('.progress').attr 'aria-valuenow', 0
		this.$('.progress-meter').css 'width' , '0%'
		this.$('.progress-meter-text').html ''
	
	createArchive: ->
		this.$('.archive-wait').removeClass 'hide'
		this.$('.progress').removeClass 'hide'
		this.model.createArchive()

	notifyError: ->
		console.log 'notifyError'
		this.$('.archive-notify').removeClass 'hide'
		this.$('.archive-notify').html('Problem creating archive: ' + this.model.get 'error')

	archiveProgress: (m) ->
		progress = m.get('archiveProgress') 
		console.log progress
		pct = Math.round (100*progress)/m.photos.length
		this.$('.progress').attr 'aria-valuenow' , pct
		this.$('.progress-meter').css 'width' , '' + pct + '%'
		this.$('.progress-meter-text').html '' + pct + '%'

		if progress >= m.photos.length
			this.$('.archive-wait').addClass 'hide'
			this.$('.progress').addClass 'hide'
			this.$('.archive-notify').removeClass 'hide'
			$archive = this.model.get 'archive'
			this.$('.archive-notify').html('You may download your file using this link: <a href="' + config.urlBase + '/downloads/' + $archive + '">' + config.urlBase + '/downloads/' + $archive + '</a>')
