{CompositeDisposable, TextEditor} = require 'atom'
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
  SELECTOR: '.tree-view .entry'
  COMMAND: 'tree-view-copy-relative-path:copy-path'
  subscriptions: null
  config:
    replaceBackslashes:
      title: 'Replace backslashes (\\) with forward slashes (/) (usefull for Windows)'
      type: 'boolean'
      default: true

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

    activeTextEditor = atom.workspace.getActiveTextEditor() ||
      atom.workspace.getPanes().find(({activeItem}) => activeItem instanceof TextEditor)?.activeItem
    currentPath = activeTextEditor?.getPath()

    unless currentPath
      atom.notifications.addWarning '"Copy Relative Path" command
        has no effect when no files are open'
      return

    relativePath = relative(currentPath, treeViewPath)
    if relativePath.substr(0, 3) != '../'
      relativePath = './' + relativePath
    if atom.config.get('tree-view-copy-relative-path.replaceBackslashes')
      relativePath = relativePath.replace(/\\/g, "/")

    atom.clipboard.write relativePath
