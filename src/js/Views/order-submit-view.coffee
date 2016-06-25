BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	events:
		'closed.zf.reveal' : 'closed'		

	initialize: (options) ->
		this.template = templates['order-submit-view']

	render: ->
		this.$el.html this.template {urlBase: config.urlBase}

	submit: (data) ->
		this.$('.page').addClass 'hide'
		this.$('.wait').removeClass 'hide'
		this.$el.foundation 'open'
		$.ajax(
			url: config.servicesBase +  '/orders'
			type: 'POST'
			context: this
			data: data
			success: (json) ->
				this.$('.page').addClass 'hide'
				if json.errors.length>0
					this.$('textarea[name="error-text"]').val JSON.stringify(json.errors)
					this.$('.order-error').removeClass 'hide'
					this.model.set {error: true, idorder: json.idorder}
				else
					href = config.urlBase + '/orders/' + json.orderid
					this.$('.order-success a').attr('href',href).html href
					this.$('.order-success').removeClass 'hide'
					this.model.set {error: false, idorder: json.idorder, orderid: json.orderid}
		)

	closed: ->
		console.log "closed"