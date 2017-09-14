BaseView = require './base-view'
config = require './config'

module.exports = BaseView.extend

	events:
		'click a img' : 'breadcrumbImageClicked'
		'click a' : 'breadcrumbClicked'

	initialize: (options) ->
		this.listenTo this.model, 'change:selectedContainer', this.render
		this.listenTo this.model.containers, 'change:featuredphoto', this.render

	render: ->
		container = this.model.get 'selectedContainer'
		return if !container or container.get('type') != 'gallery'
		breadcrumbs = this.model.getContainerTree(container)
		html = ''
		
		for i in [breadcrumbs.length-1..0]
			uid = breadcrumbs[i].get 'uid'
			name = breadcrumbs[i].get 'name'
			if uid
				src = config.urlBase + '/photos/T/' + uid + '.jpg'
			else if breadcrumbs[i].get('type') == 'folder'
				src = config.urlBase + '/images/thumbnail-folder.jpg'
			else
				src = config.urlBase + '/images/thumbnail-gallery.jpg'

			html += '<a id="breadcrumb-' + breadcrumbs[i].id + '" href="#"><img src="' + src + '" alt="' + name + '">' + name + '</a>'
			if i!=0
				html += ' &gt; '
		
		this.$el.html html
		this

	breadcrumbImageClicked: (e) ->
		e.stopPropagation()
		container = this.model.get 'selectedContainer'
		photoids = container.getSelectedPhotos true

		pid = if photoids.length==0 then 0 else photoids[0]

		$a = this.getContainingElement e.target, 'a'
		targetid = $a.attr('id').replace('breadcrumb-','')

		this.model.setFeaturedPhoto targetid, pid

	breadcrumbClicked: (e) ->
		targetid = e.target.id.replace('breadcrumb-','')
		this.model.selectContainer targetid




