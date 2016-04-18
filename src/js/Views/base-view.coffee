Backbone = require 'backbone'

module.exports = Backbone.View.extend

	assign : (view, selector) ->
		view.setElement(this.$(selector)).render()

	getContainingElement: (e, elementType) ->
		$e = $(e)
		while $e
			return $e if $e.is elementType
			$e = $e.parent()

