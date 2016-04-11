BaseView = require './base-view'
templates = require './jst'
PhotoView = require './photo-view'
config = require './config'

module.exports = BaseView.extend

	initialize: (options) ->
		this.template = templates['gallery-photo-view']		
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto

	render: ->
		this.$el.html this.template {urlBase: config.urlBase}
		this

	changePhoto: (m) ->
		photo = m.get 'currentPhoto'
		this.$('.content img').attr 'src' , config.urlBase + '/photos/M/' + photo.id + '.jpg'
