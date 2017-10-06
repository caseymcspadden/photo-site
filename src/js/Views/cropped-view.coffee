BaseView = require './base-view'
templates = require './jst'
config = require './config'

#Model: cartitem

module.exports = BaseView.extend
	events:
		'onload img' : 'render'
		'click .crop-rect' : 'doCrop'

	initialize: (options) ->
		this.template = templates['cropped-view']
		this.width = options.width
		this.height = options.height
		this.listenTo this.model, 'change:togglecrop', this.render

	render: ->
		data = this.model.toJSON()
		data.urlBase = config.urlBase
		imagewidth = this.height * data.width/data.height
		data.cropx *= (imagewidth/this.width)
		data.cropwidth *= (imagewidth/this.width)
		this.$el.html this.template(data)
		this.$('img').css {height: this.height + 'px'}
		this.$el.css {height: this.height+'px', width: this.width+'px'}
		this

	doCrop: (e) ->
		this.trigger 'cropImage', e, this.model
 