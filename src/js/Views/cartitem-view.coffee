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
		this.$el.html this.template(this.model.toJSON())
