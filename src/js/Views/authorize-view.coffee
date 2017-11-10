BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend
	initialize: (options) ->
		this.template = templates['authorize-view']
		params = {}
		me=this
		window.location.search.replace(/[?&]+([^=&]+)=([^&]*)/gi, (str,key,value) -> 
			params[key] = value;
 		)
		this.params = params
		this.listenTo this.model, 'change:id' , this.render
	
	render: ->
		this.$el.html this.template {urlBase: config.urlBase, uid: this.model.get('id'), params: this.params}
