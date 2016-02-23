#Folders View manages a collection of folders

Backbone = require 'backbone'
templates = require './jst'
Folders = require './folders'
Folder = require './folder'
Gallery = require './gallery'
PhotoApp = require './photoapp'

module.exports = Backbone.View.extend
	app: null
	$tree: null
	collapsed: true
	close_same_level: false
	duration: 400
	listAnim: true

	events:
		'click .add-folder': 'addFolder'
		'click .add-gallery': 'addGallery'
		'click .folder > *:first-child' : 'folderClicked'
		'click .gallery > *:first-child' : 'galleryClicked'

	initialize: (options) ->
		this.template = templates['folders-view']

		this.app = options.app

		this.$el.html(this.template());

		this.$tree = this.$('.mtree');

		this.listenTo(this.app.folders, 'add', this.folderAdded)
		this.listenTo(this.app.folders, 'remove', this.folderRemoved)
			
	render: ->
		this.$tree.html('');
		self = this
		this.app.folders.each (folder) ->
			self.app.set({selectedFolder: folder})
			self.folderAdded folder
			folder.Galleries.each (gallery) ->
				self.galleryAdded(gallery)

		this.$tree.find('ul').css
			'overflow':'hidden'
			'height': if this.collapsed then 0 else 'auto'
			'display': if this.collapsed then 'none' else 'block'

	folderAdded: (f) ->
		this.listenTo(f.Galleries, 'add', this.galleryAdded)
		this.listenTo(f.Galleries, 'remove', this.galleryRemoved)
		test = this.$tree.append('<li id="folder-' + f.cid + '" class="folder mtree-node mtree-closed"><a href="#">' + f.get('Name') + '</a><ul class="mtree-level-1"></ul></li>')

	folderRemoved: (f) ->
		console.log "Folder Removed"

	galleryAdded: (g) -> 
		this.listenTo(g.Photos, 'remove', this.photoRemoved)
		sel = this.app.get('selectedFolder')
		this.$('#folder-' + sel.cid + ' ul').append('<li id="gallery-' + g.cid + '" class="gallery"><a href="#">' + g.get('Name') + '</a></li>')

	galleryRemoved: (g) ->
		console.log 'Gallery Removed'

	photoRemoved: (p) ->
		console.log "photo removed from gallery"

	addFolder: ->
		this.app.folders.add(new Folder({Name: 'New Folder'}))

	addGallery: ->
		$active = this.$('.folder.mtree-active')
		if $active.length > 0
			isOpen = $active.hasClass 'mtree-open'
			this.setNodeClass $active, false

			$ul = $active.children('ul').first()
			if $ul.children().length > 0 and not isOpen
				$ul.slideToggle(this.duration)
			cid = $active.attr('id').replace(/^folder-/,'')
			this.app.selectFolder cid
			sel = this.app.get 'selectedFolder'
			sel.Galleries.add new Gallery({Name: 'New Gallery'})

	test1: ->
		console.log "test1 called"

	setNodeClass: (elem, isOpen) ->
		if isOpen
			elem.removeClass('mtree-open').addClass('mtree-closed')
		else
			elem.removeClass('mtree-closed').addClass('mtree-open')

	folderClicked: (e) ->
		$li = $(e.target).parent()
		this.$('.gallery.mtree-active').removeClass('mtree-active')		
		this.app.selectFolder $li.attr('id').replace(/^folder-/,'')
		this.app.selectGallery null
		
		this.$('.folder.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass 'mtree-active'

		$ul = $li.children('ul').first()
		isOpen = $li.hasClass('mtree-open')

		$ul.css
			'height': 'auto'

		if $ul.children().length > 0
			this.setNodeClass($li, isOpen)
			$ul.slideToggle(this.duration)

		e.preventDefault()

	galleryClicked: (e) ->
		$li = $(e.target).parent()
		$folder = $li.parent().parent()
		
		this.$('.folder.mtree-active').not($folder).removeClass('mtree-active')
		$folder.addClass 'mtree-active'
		this.app.selectFolder $folder.attr('id').replace(/^folder-/,'')

		this.$('.gallery.mtree-active').not($li).removeClass('mtree-active')
		$li.addClass('mtree-active')
		this.app.selectGallery $li.attr('id').replace(/^gallery-/,'')

		e.preventDefault()




