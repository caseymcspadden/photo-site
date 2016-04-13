BaseView = require './base-view'
templates = require './jst'
PhotoView = require './photo-view'
config = require './config'

module.exports = BaseView.extend

	events:
		'click .prev' : 'shiftLeft'
		'click .next' : 'shiftRight'
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.template = templates['gallery-photo-view']
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto

	render: ->
		this.$el.html this.template {urlBase: config.urlBase}
		this

	keyUp: (e) ->
		offset = switch e.keyCode
			when 37 then -1
			when 38 then -3
			when 39 then 1
			when 40 then 3
			else 0
		this.model.offsetCurrentPhoto offset

	shiftLeft: ->
		this.model.offsetCurrentPhoto -1
		this.$('.content a').focus()
		
	shiftRight: ->
		this.model.offsetCurrentPhoto 1
		this.$('.content a').focus()

	updateCounter: ->
		photo = this.model.get 'currentPhoto'
		this.$('.index').html (1+this.model.photos.indexOf photo)
		this.$('.total').html this.model.photos.length

	changePhoto: (m) ->
		photo = m.get 'currentPhoto'
		this.$('.content img').attr 'src' , config.urlBase + '/photos/M/' + photo.id + '.jpg'
		this.updateCounter()
