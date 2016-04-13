Backbone = require 'backbone'
config = require './config'

module.exports = Backbone.View.extend

	events:
		'click a' : 'breadcrumbClicked'

	initialize: (options) ->
		this.listenTo this.model, 'change:selectedContainer', this.render
		this.listenTo this.model.containers, 'change:featuredPhoto', this.render

	render: ->
		container = this.model.get 'selectedContainer'
		return if !container or container.get('type') != 'gallery'
		breadcrumbs = this.model.getContainerTree(container)
		html = ''
		for i in [breadcrumbs.length-1..0]
			fid = breadcrumbs[i].get 'featuredPhoto'
			name = breadcrumbs[i].get 'name'
			if fid!=0
				src = config.urlBase + '/photos/T/' + fid + '.jpg'
			else if breadcrumbs[i].get('type') == 'folder'
				src = config.urlBase + '/images/thumbnail-folder.jpg'
			else
				src = config.urlBase + '/images/thumbnail-gallery.jpg'

			html += '<a id="breadcrumb-' + breadcrumbs[i].id + '" href="#"><img src="' + src + '" alt="' + name + '">' + name + '</a>'
			if i!=0
				html += ' &gt; '

		this.$el.html html
		this

	breadcrumbClicked: (e) ->
		container = this.model.get 'selectedContainer'
		photoids = container.getSelectedPhotos true

		pid = if photoids.length==0 then 0 else photoids[0]

		targetid = e.target.id.replace('breadcrumb-','')
		this.model.setFeaturedPhoto targetid, pid
