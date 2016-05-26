BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	className: 'large-12 columns cart-item'

	#events:

	initialize: (options) ->
		this.template = templates['cartitem-view']
		this.model.set 'urlBase' , config.urlBase
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		data = this.model.toJSON()
		imagewidth = 150 * data.width/data.height

		data.cropx *= (imagewidth/250)
		data.cropwidth *= (imagewidth/250)

		###
		aspect = data.vsizeprod / data.hsizeprod
		if data.width > data.height
			data.clipwidth = 150*aspect
		else
			data.clipwidth = 150/aspect
		if data.cropwidth < 100
			data.imagewidth = data.clipwidth/(data.cropwidth/100)
			data.imageheight = 150
		else if data.cropheight < 100
			data.imageheight = 150/(data.cropheight/100)
			data.imagewidth = data.clipwidth
		###
		this.$el.html this.template(data)
