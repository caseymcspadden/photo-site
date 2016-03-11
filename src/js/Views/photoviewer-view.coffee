Backbone = require 'backbone'
templates = require './jst'
Photo = require './photo'
PhotoviewerModel = require './photoviewer'

module.exports = Backbone.View.extend
	tagName: 'div'

	events:
		'click .scroll.left' : 'scrollLeft'
		'click .scroll.right' : 'scrollRight'
		'click input:radio[name=view-size]' : 'changeImageSize'

	initialize: (options) ->
		console.log "Initializing photo viewer"
		this.revealElement = options.revealElement
		this.model = new PhotoviewerModel
		this.template = templates['photoviewer-view']
		this.listenTo this.model, 'change:size', this.photoChanged
		this.listenTo this.model, 'change:photo', this.photoChanged
		this.listenTo this.model, 'change:collection', this.collectionChanged
	
	scrollLeft: ->
		collection = this.model.get('collection')
		this.index-- 
		this.index = collection.length-1 if this.index<0
		this.model.set {photo: collection.at this.index}

	scrollRight: ->
		collection = this.model.get('collection')
		this.index++
		this.index = 0 if this.index>=collection.length
		this.model.set {photo: collection.at this.index}

	changeImageSize: (e)->
		this.model.set {size: $(e.target).attr('id').replace('view-','')}
		this.$('.view-image').focus()

	render: ->
		this.$el.html this.template()

	open: (photo, collection)->
		console.log photo
		this.model.set {collection: collection}
		this.model.set {photo: photo}
		this.index = collection.indexOf photo
		this.revealElement.foundation 'open' if collection.length>0

	photoChanged: ->
		this.$('.view-image').attr('src' , 'photos/' + this.model.get('size') + '/' + this.model.get('photo').id + '.jpg')
		json = this.model.get('photo').toJSON()
		console.log json
		text = '';
		for k, v of json
			text += k + ": " + v + '<br>'
		this.$('.text-container').html text

	collectionChanged: (collection) ->
		console.log "collection changed"
