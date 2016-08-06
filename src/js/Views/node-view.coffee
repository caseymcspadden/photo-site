BaseView = require './base-view'
templates = require './jst'

module.exports = BaseView.extend
	tagName: 'li'

	className: ->
		this.model.get('type') + ' mtree-node'

	id: ->
		'node-' + this.model.id

	initialize: (options) ->
		this.folderTemplate = templates['folder-node-view']
		this.galleryTemplate = templates['gallery-node-view']
		this.listenTo this.model, 'change:name', this.nameChanged
		this.listenTo this.model, 'destroy', this.remove

	nameChanged: (m) ->
		this.$('> a .node-name').html m.get 'name'

	render: ->
		template = if this.model.get('type') == 'gallery' then this.galleryTemplate else this.folderTemplate
		this.$el.html template(this.model.toJSON())
		this
