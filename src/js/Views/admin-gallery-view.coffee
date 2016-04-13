#Gallery View manages a gallery or folder

BaseView = require './base-view'
Dragula = require 'dragula'
PhotoView = require './photo-view'
templates = require './jst'
PhotoViewerModel= require './photoviewer'
#PhotoViewer = require './photoviewer-view'
Photo = require './photo'
DropzoneView = require('./dropzone-view')
EditContainerView = require('./edit-container-view')
#MasterThumbnailsView = require('./master-thumbnails-view')

module.exports = BaseView.extend
	currentGallery: null

	photoViews: {}

	events:
		'click .add-photos' : 'addPhotos'
		'click .remove-photos' : 'removePhotos'
		'click .delete-photos' : 'deletePhotos'
		'click .set-featured-gallery' : 'setFeaturedGalleryPhoto'
		'click .set-featured-folder' : 'setFeaturedFolderPhoto'
		'click .delete-gallery' : 'deleteGallery'
		'click .select-all' : 'selectAll'
		'click .deselect-all' : 'deselectAll'
		'dblclick' : 'openViewer'
		'keydown .photo-list' : 'keyDown'
		'keyup .photo-list' : 'keyUp'

	initialize: (options) ->
		this.template = templates['admin-gallery-view']
		this.listenTo this.model, 'change:selectedContainer', this.changeGallery
		this.selectMode = 0
		this.currentPhoto = null

		this.dropzoneView = new  DropzoneView {model: this.model}
		this.editContainerView = new EditContainerView {model: this.model}

		this.drag = Dragula({direction: 'horizontal'})

		self = this
		this.drag.on('drop', (el, target, source, sibling) ->
			elements = $(source).find('div').toArray()
			ids = []
			for e in elements
				ids.push $(e).attr('id').replace('gallery-photo-','')
			self.currentGallery.rearrangePhotos ids
		)

	keyDown: (e) ->
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

		this.model.set 'selectedPhoto', photo			
		this.currentPhoto = photo		

	openViewer: (e) ->
		this.model.set 'viewingPhotosToggle' , !this.model.get('viewingPhotosToggle')

	deleteGallery: ->
		this.model.deleteContainer this.currentGallery

	changeGallery: ->
		if  this.currentGallery
			this.stopListening this.currentGallery
			this.stopListening this.currentGallery.photos
	
		this.currentGallery = this.model.get('selectedContainer')
		#this.$('.title').html(if this.currentGallery then this.currentGallery.get('name') else 'Default')

		if this.currentGallery and this.currentGallery.get('type')=='gallery'
			this.listenTo this.currentGallery, 'change', this.galleryChanged 
			this.listenTo this.currentGallery.photos, 'reset', this.addAll 
			this.listenTo this.currentGallery.photos, 'add', this.addOne
			this.listenTo this.currentGallery.photos, 'change:selected', this.selectedPhotoChanged
			this.addAll()
			this.galleryChanged()

	galleryChanged: (e) ->
		name = this.currentGallery.get 'name'
		this.$('.title').html name

	selectAll: ->
		this.selectMode=2
		this.currentGallery.photos.each (photo) ->
			photo.set 'selected', true
		this.selectMode=0

	deselectAll: ->
		this.currentGallery.photos.each (photo) ->
			photo.set 'selected', false

	removePhotos: (e) ->
		this.currentGallery.removeSelectedPhotos(false)
		e.preventDefault()

	deletePhotos: (e) ->
		this.currentGallery.removeSelectedPhotos(true)
		e.preventDefault()

	addPhotos: (e) ->
		this.model.set {addingPhotosToggle: !this.model.get('addingPhotosToggle')}
		e.preventDefault()

	setFeaturedGalleryPhoto: (e) ->
		ids = this.currentGallery.getSelectedPhotos true
		return if ids.length==0
		this.model.setFeaturedPhoto this.currentGallery.id, ids[0]

	setFeaturedFolderPhoto: (e) ->
		ids = this.currentGallery.getSelectedPhotos true
		return if ids.length==0
		this.model.setFeaturedPhoto this.currentGallery.get('idparent'), ids[0]

	render: ->
		this.$el.html this.template {name: 'Default'}
		
		#this.photoViewer = new PhotoViewer {el:this.$('.photo-viewer'), revealElement: this.$('#gv-photoViewer'), urlBase: this.model.urlBase}
		#this.photoViewer.render()
		#this.assign this.photoViewer, '#gv-photoViewer'
		this.assign this.dropzoneView, '#gv-uploadPhotos'
		this.assign this.editContainerView, '#gv-editGallery'

		this.drag.containers.pop()
		this.drag.containers.push this.$('.photo-list')[0]

	addOne: (photo) ->
		if !(this.photoViews.hasOwnProperty photo.id)
			view = this.photoViews[photo.id] = new PhotoView {model:photo, id: 'gallery-photo-' + photo.id}
		view = this.photoViews[photo.id]
		this.$('.photo-list').append view.render().el
		view.delegateEvents()

	addAll: ->
		this.$('.photo-list').html ''
		this.currentGallery.photos.each this.addOne, this

