BaseView = require './base-view'
templates = require './jst'
Photo = require './photo'
PhotoviewerModel = require './photoviewer'
PhotoTextEditor = require './photo-text-editor-view'
config = require './config'

module.exports = BaseView.extend
	tagName: 'div'

	events:
		'click .scroll-left' : 'scrollLeft'
		'click .scroll-right' : 'scrollRight'
		'click input:radio[name=view-size]' : 'changeImageSize'
		'keydown .view-image-wrapper' : 'keyDown'

	initialize: (options) ->
		this.revealElement = options.revealElement
		this.template = templates['photoviewer-view']
		this.listenTo this.model, 'change:viewPhotoSize', this.photoChanged
		this.listenTo this.model, 'change:viewPhoto', this.photoChanged
		this.listenTo this.model, 'change:viewingPhotosToggle' , this.open
		this.photoTextEditor = new PhotoTextEditor {model: this.model}

	open: ->
		this.$el.foundation 'open'
		this.selectedContainer = this.model.get 'selectedContainer'
		this.photos = this.selectedContainer.photos
		this.model.set 'viewPhoto' , this.model.get('selectedPhoto')
		this.index = this.photos.indexOf(this.model.get 'viewPhoto')
		this.$('.view-image-wrapper').focus()

	keyDown: (e) ->
		if e.keyCode==37
			this.scrollLeft e
		else if e.keyCode==39
			this.scrollRight e

	scrollLeft: (e) ->
		this.index-- 
		this.index = this.photos.length-1 if this.index<0
		this.model.set {viewPhoto: this.photos.at this.index}

	scrollRight: (e) ->
		this.index++
		this.index = 0 if this.index>=this.photos.length
		this.model.set {viewPhoto: this.photos.at this.index}

	changeImageSize: (e) ->
		size = $(e.target).attr('id').replace('view-','')
		this.model.set {viewPhotoSize: size}
		if size=='L' or size=='X'
			this.$('.photo-viewer').addClass('full-screen') 
		else
			this.$('.photo-viewer').removeClass('full-screen') 
		this.$('.view-image-wrapper').focus()

	render: ->
		this.$el.html this.template()
		this.assign this.photoTextEditor , '.photo-text-editor'

	photoChanged: (m) ->
		this.$('.view-image').attr('src' , config.urlBase + '/photos/' + m.get('viewPhotoSize') + '/' + m.get('viewPhoto').id + '.jpg')
