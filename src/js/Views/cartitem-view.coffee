BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	className: 'large-12 columns cart-item'

	events:
		'click .crop-item' : 'cropItem'
		'click .remove-item' : 'removeItem'

	initialize: (options) ->
		this.template = templates['cartitem-view']
		this.model.set 'urlBase' , config.urlBase
		#this.listenTo this.model.photos, 'reset', this.render

	render: ->
		data = this.model.toJSON()
		imagewidth = 150 * data.width/data.height
		data.cropx *= (imagewidth/250)
		data.cropwidth *= (imagewidth/250)
		this.$el.html this.template(data)

	cropItem: (e) ->
		e.preventDefault();
		console.log "crop item"

	removeItem: (e) ->
		e.preventDefault();
		this.model.destroy()
