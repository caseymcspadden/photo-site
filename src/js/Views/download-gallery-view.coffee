BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	events:
		'submit form' : 'submitPaymentForm'
		'click .create-archive' : 'createArchive'
		'click .cancel-archive' : 'cancelArchive'

	initialize: (options) ->
		this.template = templates['download-gallery-view']
		this.listenTo this.model, 'change:error', this.notifyError
		this.listenTo this.model, 'change:archiveProgress', this.archiveProgress
		this.listenTo this.model, 'change:maxdownloadsize change:idpayment', this.render
		this.listenTo this.model.photos, 'reset', this.initializeProgress

	render: ->
		data = this.model.toJSON()
		data.waitsrc = config.urlBase+'/images/wait-circle.gif'
		data.waitpaymentsrc = config.urlBase+'/images/ajax-loader.gif'
		data.cancelsrc = config.urlBase+'/images/cancel.png'
		this.$el.html this.template(data)

	open: ->
		this.$('.archive-wait').addClass 'hide'
		this.$('.archive-notify').addClass 'hide'
		$('.payment-wait').addClass 'hide'
		$('.payment-error').addClass 'hide'
		$('.payment-form').removeClass 'hide'
		this.$el.foundation 'open'

	submitPaymentForm: (e) ->
		e.preventDefault();
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		data.name = this.model.get 'name'
		$('.payment-form').addClass 'hide'
		$('.payment-wait').removeClass 'hide'
		$.ajax(
			url: config.servicesBase +  '/containers/' + this.model.id + '/payment'
			type: 'POST'
			context: this
			data: data
			success: (json) ->
				$('.payment-wait').addClass 'hide'
				if json.errors.length>0
					this.$('textarea[name="error-text"]').val JSON.stringify(json.errors)
					this.$('.payment-error').removeClass 'hide'
				else
					this.model.set {idpayment: json.idpayment}
		)

	initializeProgress: ->
		this.$('.progress').attr 'aria-valuenow', 0
		this.$('.progress-meter').css 'width' , '0%'
		this.$('.progress-meter-text').html ''
	
	createArchive: ->
		this.$('.archive-wait').removeClass 'hide'
		imagesize = this.$('#imagesize').val()
		this.model.createArchive(imagesize)

	cancelArchive: ->
		this.model.set 'cancelArchive', true

	notifyError: ->
		this.$('.archive-wait').addClass 'hide'
		this.$('.archive-notify').html('Problem creating archive: ' + this.model.get 'error')
		this.$('.archive-notify').removeClass 'hide'

	archiveProgress: (m) ->
		progress = m.get('archiveProgress') 
		pct = Math.round (100*progress)/m.photos.length
		this.$('.progress').attr 'aria-valuenow' , pct
		this.$('.progress-meter').css 'width' , '' + pct + '%'
		this.$('.progress-meter-text').html '' + pct + '%'

		if progress >= m.photos.length
			this.$('.archive-wait').addClass 'hide'
			this.$('.archive-notify').removeClass 'hide'
			$archive = this.model.get 'archive'
			this.$('.archive-notify').html('You may download your file using this link: <a href="' + config.urlBase + '/downloads/archive/' + $archive + '">' + config.urlBase + '/downloads/archive/' + $archive + '</a>')
