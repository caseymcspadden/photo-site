BaseView = require './base-view'
templates = require './jst'
User = require './user'

module.exports = BaseView.extend
	events:
		'submit form' : 'doSubmit'
		'change #hsize' : 'hsizeChanged'
		'change #vsize' : 'vsizeChanged'

	defaultData:
		id: 0
		api: 'pwinty'
		idapi: ''
		type: 'Print'
		description: ''
		hsize: ''
		vsize: ''
		hsizeprod: ''
		vsizeprod: ''
		hres: ''
		vres: ''
		price: ''
		shippingtype: '0'
		active: '1'

	defaultPPI: 150

	initialize: (options) ->
		this.template= templates['edit-product-view']

	open: (collection, model) ->
		this.collection=collection
		this.model = model
		this.render()
		this.$el.foundation 'open'

	serialize: (form) ->
		arr = $(form).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value
		data

	hsizeChanged: (e) ->
		this.$('input[name="hres"]').val e.target.value * this.defaultPPI

	vsizeChanged: (e) ->
		this.$('input[name="vres"]').val e.target.value * this.defaultPPI

	doSubmit: (e) ->
		e.preventDefault()		
		data = this.serialize e.target
		self = this
		if this.model
			this.model.save(
				data
				error: (model, response, options) ->
					self.$('.error-message').html response.responseJSON.message
					self.$('.error-message').removeClass('hide')
				success: (model, response, options) ->
					self.$el.foundation 'close'
			)
		else
			this.collection.create(
				data
				wait: true
				error: (model, response, options) ->
					self.$('.error-message').html response.responseJSON.message
					self.$('.error-message').removeClass('hide')
				success: (model, response, options) ->
					self.$el.foundation 'close'
			)
		this

	render: ->
		data = if this.model then this.model.toJSON() else this.defaultData 
		this.$el.html this.template(data)
