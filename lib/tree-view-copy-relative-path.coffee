{CompositeDisposable} = require 'atom'
relative = require 'relative'

extractPath = (element) ->
  path = if element.dataset.path
    element.dataset.path
  else
    element.children[0].dataset.path

  unless path
    atom.notifications.addError "tree-view-copy-relative-path:
      unable to extract path from node."
    console.error "Unable to extract path from node: ", element

  path

module.exports = TreeViewCopyRelativePath =
  SELECTOR: '.tree-view .file'
  COMMAND: 'tree-view-copy-relative-path:copy-path'
  subscriptions: null

  activate: (state) ->
    command = atom.commands.add @SELECTOR,
      @COMMAND,
      ({target}) => @copyRelativePath(extractPath(target))

    @subscriptions = new CompositeDisposable
    @subscriptions.add(command)

  deactivate: ->
    @subscriptions.dispose()

  copyRelativePath: (treeViewPath) ->
    return if not treeViewPath

    currentPath = atom.workspace.getActivePaneItem()?.buffer.file?.path
    unless currentPath
      atom.notifications.addWarning '"Copy Relative Path" command
        has no effect when no files are open'
      return

    atom.clipboard.write relative(currentPath, treeViewPath)
