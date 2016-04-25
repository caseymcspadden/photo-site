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
		this.listenTo this.model, 'change:archive', this.notifyArchive

	render: ->
		this.$el.html this.template {waitsrc: config.urlBase+'/images/wait-bar.gif'}

	open: ->
		this.$('.archive-wait').addClass 'hide'
		this.$('.archive-notify').addClass 'hide'

	createArchive: ->
		this.$('.archive-wait').removeClass 'hide'
		this.model.createArchive()

	notifyError: ->
		console.log 'notifyError'
		this.$('.archive-notify').removeClass 'hide'
		this.$('.archive-notify').html('Problem creating archive: ' + this.model.get 'error')

	notifyArchive: ->
		console.log 'notifyArchive'
		this.$('.archive-wait').addClass 'hide'
		this.$('.archive-notify').removeClass 'hide'
		$archive = this.model.get 'archive'
		this.$('.archive-notify').html('You may download your file using this link: <a href="' + config.urlBase + '/downloads/' + $archive + '">' + config.urlBase + '/downloads/' + $archive + '</a>')
