BaseView = require './base-view'
templates = require './jst'
PageView = require './gallery-grid-page'
config = require './config'

module.exports = BaseView.extend
	events:
		'change .pager select' : 'changePage'
		'click .prev' : 'scrollLeft'
		'click .next' : 'scrollRight'
		'keyup' : 'keyUp'

	initialize: (options) ->
		this.template = templates['gallery-grid-view']
		this.gridPages = []
		this.currentPage = -1
		this.listenTo this.model.photos, 'reset', this.addAll
		this.listenTo this.model, 'change:urlsuffix', this.render
		this.listenTo this.model, 'change:currentPhoto', this.currentPhotoChanged

	render: ->
		console.log this.model
		if this.model.get('access')==1
			breadcrumbs = [this.model.get('name')]
		else
			breadcrumbs =  document.location.pathname.replace(/^.*\/galleries\//,'').split '/'		
			count = breadcrumbs.length
			if count>1 and breadcrumbs[count-1] == this.model.get('urlsuffix')
				breadcrumbs.pop()

		this.$el.html this.template {urlBase: config.urlBase, breadcrumbs: breadcrumbs}
		this

	keyUp: (e) ->
		offset = switch e.keyCode
			when 37 then -1
			when 38 then -3
			when 39 then 1
			when 40 then 3
			else 0
		this.model.offsetCurrentPhoto offset

	currentPhotoChanged: (model) ->
		photo = model.get "currentPhoto"
		photo.set 'selected', true
		return if !photo
		index = model.photos.indexOf photo
		page = Math.floor(index/12)
		this.$('.pager select').val page
		this.showPage page

	addAll: (collection) ->
		for i in [0...collection.length]
			if i%12 == 0
				pageView = new PageView {model: this.model, id: 'grid-' + this.gridPages.length}
				this.gridPages.push pageView
			this.gridPages[this.gridPages.length-1].addPhoto collection.at(i)

		for i in [0...this.gridPages.length]
			this.$('.pager select').append $("<option></option>").attr("value",i).text('' + (i+1) + ' of ' + this.gridPages.length)

		this.showPage 0
		this.model.set 'currentPhoto', this.model.photos.at 0

	scrollLeft: ->
		this.model.offsetCurrentPhoto -12

	scrollRight: ->
		index = this.model.photos.indexOf this.model.get('currentPhoto')
		this.model.offsetCurrentPhoto Math.min(12, this.model.photos.length-index-1)

	changePage: (e) ->
		page = e.target.value
		this.showPage e.target.value
		this.model.photos.at(page*12).set 'selected' , true

	showPage: (page) ->
		return if page==this.currentPage
		this.$('.content').html ''
		this.gridPages[this.currentPage].undelegateEvents() if this.currentPage>=0
		this.currentPage = page
		this.assign this.gridPages[page] , '.content'
		this.$('a').focus()
