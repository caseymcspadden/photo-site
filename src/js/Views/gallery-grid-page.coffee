BaseView = require './base-view'
templates = require './jst'
PhotoView = require './photo-view'

module.exports = BaseView.extend

	className: 'grid-page'

	initialize: (options) ->
		this.photoViews = []
		this.listenTo this.model.photos, 'change:selected', this.selectPhoto

	render: ->
		for i in [0...this.photoViews.length]
			this.$el.append this.photoViews[i].render().el
			this.photoViews[i].delegateEvents()
		this

	selectPhoto: (m) ->
		if m.get('selected')
			this.model.photos.each( (photo) ->
				photo.set('selected', false) if photo.id != m.id
			, this)
			this.model.set 'currentPhoto' , m

	addPhoto: (photo) ->
		photoView = new PhotoView {model: photo}
		this.photoViews.push photoView

