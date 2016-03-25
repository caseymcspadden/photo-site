#Gallery View manages a gallery or folder

Backbone = require 'backbone'
Dragula = require 'dragula'
PhotoView = require './photo-view'
templates = require './jst'
PhotoViewerModel= require './photoviewer'
PhotoViewer = require './photoviewer-view'
Photo = require './photo'
DropzoneView = require('./dropzone-view')

module.exports = Backbone.View.extend
	currentGallery: null

	photoViews: {}

	events:
		'submit #gv-editGallery form' : 'editGallery'
		'click .add-photos' : 'addPhotos'
		'click .remove-photos' : 'removePhotos'
		'click .add-selected' : 'addSelected'	
		'click .set-featured' : 'setFeaturedPhoto'
		'click .delete-gallery' : 'deleteGallery'
		'dblclick' : 'openViewer'
		'keydown .photo-list' : 'keyDown'
		'keyup .photo-list' : 'keyUp'
		'keydown .master-photo-list' : 'keyDown'
		'keyup .master-photo-list' : 'keyUp'

	initialize: (options) ->
		this.template = templates['gallery-view']
		this.listenTo this.model, 'change:selectedContainer', this.changeGallery
		this.listenTo this.model.photos, 'change:selected', this.masterSelectedPhotoChanged
		this.currentPhoto = null
		this.currentMaterPhoto = null
		this.selectMode = 0
		this.masterPhotoCollection = new Backbone.Collection {model: Photo}

	keyDown: (e) ->
		console.log 'key down'
		if e.keyCode == 91
			this.selectMode=2
		else if e.keyCode == 16
			this.selectMode=3

	keyUp: (e) ->
		this.selectMode = 0

	selectedPhotoChanged: (photo) ->
		return if photo.get('selected') == false 

		if this.selectMode==0
			this.currentGallery.photos.each (p) ->
				p.set('selected', false) if p.id != photo.id
		
		if this.selectMode==3
			this.selectMode=2
			index1 = this.currentGallery.photos.indexOf this.currentPhoto
			index2 = this.currentGallery.photos.indexOf photo
			this.currentGallery.photos.at(i).set('selected',true) for i in [index1 .. index2]
	
		this.currentPhoto = photo		

	masterSelectedPhotoChanged: (photo) ->
		return if photo.get('selected') == false 

		if this.selectMode==0
			this.masterPhotoCollection.each (p) ->
				p.set('selected', false) if p.id != photo.id
		
		if this.selectMode==3
			this.selectMode=2
			index1 = this.masterPhotoCollection.indexOf this.currentMasterPhoto
			index2 = this.masterPhotoCollection.indexOf photo
			this.masterPhotoCollection.at(i).set('selected',true) for i in [index1 .. index2]
	
		this.currentMasterPhoto = photo		

	openViewer: (e) ->
		console.log this.currentGallery.photos
		this.photoViewer.open this.currentPhoto, this.currentGallery.photos

	addSelected: ->
		this.model.addSelectedPhotosToContainer this.currentGallery
		this.$('#gv-addPhotos .close-button').trigger('click')

	deleteGallery: ->
		this.model.deleteContainer this.currentGallery

	editGallery: (e) ->
		e.preventDefault()
		arr = $(e.target).serializeArray()
		data = {}
		for elem in arr
			data[elem.name]=elem.value	
		this.currentGallery.save data
		this.$('#gv-editGallery .close-button').trigger('click')

	changeGallery: ->
		if  this.currentGallery
			this.stopListening this.currentGallery
			this.stopListening this.currentGallery.photos
	
		this.currentGallery = this.model.get('selectedContainer')
		this.$('.title').html(if this.currentGallery then this.currentGallery.get('name') else 'Default')

		if this.currentGallery and this.currentGallery.get('type')=='gallery'
			this.listenTo this.currentGallery, 'change:selected', this.galleryChanged 
			this.listenTo this.currentGallery.photos, 'reset', this.addAll 
			#this.listenTo this.currentGallery.photos, 'sort', this.addAll 
			this.listenTo this.currentGallery.photos, 'add', this.addOne
			this.listenTo this.currentGallery.photos, 'remove', this.removeOne
			this.listenTo this.currentGallery.photos, 'change:selected', this.selectedPhotoChanged
			this.masterAddAll()
			this.addAll()
			this.galleryChanged()
			this.photoViewer.model.set {gallery: this.currentGallery, index: 0}

	galleryChanged: (e) ->
		this.$("#gv-editGallery input[name='name']").val this.currentGallery.get('name')
		this.$("#gv-editGallery input[name='description']").val this.currentGallery.get('description')
		this.$("#gv-editGallery input[name='featuredPhoto']").val this.currentGallery.get('featuredPhoto')

	removePhotos: (e) ->
		this.currentGallery.removeSelectedPhotos()
		this.masterAddAll()
		e.preventDefault()

	addPhotos: (e) ->
		this.model.set {addingPhotos: !this.model.get('addingPhotos')}
		e.preventDefault()

	setFeaturedPhoto: (e) ->
		this.currentGallery.setFeaturedPhoto()

	render: ->
		this.$el.html this.template {name: 'Default'}
		this.photoViewer = new PhotoViewer {el:this.$('.photo-viewer'), revealElement: this.$('#gv-photoViewer'), urlBase: this.model.urlBase}
		this.photoViewer.render()
		this.dropzoneView = new  DropzoneView {el: '#gv-uploadPhotos', model: this.model}
		this.dropzoneView.render()

		this.drag = Dragula [this.$('.photo-list')[0]],
			direction: 'horizontal'

		self = this
		this.drag.on('drop', (el, target, source, sibling) ->
			elements = $(source).find('div').toArray()
			ids = []
			for e in elements
				ids.push $(e).attr('id').replace('gallery-photo-','')

			self.currentGallery.rearrangePhotos ids
		)
  		
	removeOne: (photo) ->
		console.log photo

	addOne: (photo) ->
		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new PhotoView {model:photo, viewer: this.photoViewer, urlBase: this.model.urlBase}
		view = this.photoViews[photo.id]
		this.$('.photo-list').append view.el
		view.delegateEvents()

	addAll: ->
		this.$('.photo-list').html ''
		this.currentGallery.photos.each this.addOne, this

	masterAddOne: (photo) ->
		if this.currentGallery && this.currentGallery.photos.get(photo.id)
			return

		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new PhotoView {model:photo, viewer: this.photoViewer, urlBase: this.model.urlBase}
			view.render()

		this.masterPhotoCollection.add photo
		view = this.photoViews[photo.id]
		this.$('.master-photo-list').append view.el
		view.delegateEvents()

	masterAddAll: ->
		this.$('.master-photo-list').html ''
		this.masterPhotoCollection.reset()
		this.model.photos.each this.masterAddOne, this
