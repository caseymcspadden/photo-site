BaseView = require './base-view'
templates = require './jst'
config = require './config'

module.exports = BaseView.extend

	events:
		'click .prev' : 'shiftLeft'
		'click .next' : 'shiftRight'
		'closed.zf.reveal' : 'closed'
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.template = templates['photo-view']
		#this.listenTo this.model.photos, 'reset', this.render

	open: ->
		this.changePhoto this.model
		this.listenTo this.model, 'change:currentPhoto', this.changePhoto
		this.$el.foundation 'open'

	closed: ->
		this.stopListening this.model

	render: ->
		this.$el.html this.template()

	keyUp: (e) ->
		offset = switch e.keyCode
			when 37 then -1
			when 39 then 1
			else 0
		this.model.offsetCurrentPhoto offset

	shiftLeft: ->
		this.model.offsetCurrentPhoto -1
		this.$('.photo-container a').focus()
		
	shiftRight: ->
		this.model.offsetCurrentPhoto 1
		this.$('.photo-container a').focus()

	changePhoto: (m) ->
		photo = m.get 'currentPhoto'
		this.$('img.photo').attr 'src' , config.urlBase + '/photos/L/' + photo.uid + '.jpg'
