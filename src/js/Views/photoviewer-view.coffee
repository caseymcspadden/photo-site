Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'
PhotoviewerModel = require './photoviewer'

module.exports = Backbone.View.extend
	tagName: 'div'

	events:
		'click .scroll-left' : 'scrollLeft'
		'click .scroll-right' : 'scrollRight'
		'click input:radio[name=view-size]' : 'changeImageSize'
		'keydown' : 'keyDown'

	initialize: (options) ->
		console.log "Initializing photo viewer"
		this.revealElement = options.revealElement
		this.urlBase = options.urlBase
		this.model = new PhotoviewerModel
		this.template = templates['photoviewer-view']
		this.listenTo this.model, 'change:size', this.photoChanged
		this.listenTo this.model, 'change:photo', this.photoChanged
		this.listenTo this.model, 'change:collection', this.collectionChanged

	keyDown: (e) ->
		console.log e
		if e.keyCode==37
			this.scrollLeft e
		else if e.keyCode==39
			this.scrollRight e

	scrollLeft: (e) ->
		collection = this.model.get('collection')
		this.index-- 
		this.index = collection.length-1 if this.index<0
		this.model.set {photo: collection.at this.index}
		#e.preventDefault()

	scrollRight: (e) ->
		collection = this.model.get('collection')
		this.index++
		this.index = 0 if this.index>=collection.length
		this.model.set {photo: collection.at this.index}
		#e.preventDefault()

	changeImageSize: (e) ->
		size = $(e.target).attr('id').replace('view-','')
		this.model.set {size: size}
		if size=='L' or size=='X'
			this.$el.addClass('full-screen') 
		else
			this.$el.removeClass('full-screen') 
		this.$('.view-image-wrapper').focus()

	render: ->
		this.$el.html this.template()
		this

	open: (photo, collection) ->
		console.log photo
		this.model.set {collection: collection}
		this.model.set {photo: photo}
		this.index = collection.indexOf photo
		if collection.length>0	
			this.revealElement.foundation 'open'
			this.$('.view-image-wrapper').focus()

	photoChanged: ->
		this.$('.view-image').attr('src' , this.urlBase + '/photos/' + this.model.get('size') + '/' + this.model.get('photo').id + '.jpg')
		json = this.model.get('photo').toJSON()
		console.log json
		text = '';
		for k, v of json
			text += k + ": " + v + '<br>'
		this.$('.text-container').html text

	collectionChanged: (collection) ->
		console.log "collection changed"
