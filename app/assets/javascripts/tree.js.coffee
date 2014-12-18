eventNodeClick = (e) ->
    isOpen = (node) ->
      for open_id in $tree.tree('getState')['open_nodes']
        return true if open_id == node.id
      return false

    node = e.node

    if selected_node = $tree.tree('getSelectedNode')
      if selected_node.id == node.id
        window.location = "/things/#{node.id}"
        return

    if parent = node.parent
      for sibling in parent.children
        continue if sibling.id == node.id
        $tree.tree('toggle', sibling) if isOpen(sibling)

    $tree.tree('toggle', node) unless isOpen(node)

eventNodeMove = (e) ->
  console.log('moved_node', e.move_info.moved_node);
  console.log('target_node', e.move_info.target_node);
  console.log('position', e.move_info.position);
  console.log('previous_parent', e.move_info.previous_parent);
  e.move_info.moved_node
  e.move_info.target_node
  e.move_info.position
  e.move_info.previous_parent

$ ->
  $tree = $('#tree')
  $tree.tree
    dragAndDrop: true
    autoOpen: 1000
    useContextMenu: false
    selectable: true

  $tree.bind 'tree.click', eventNodeClick
  $tree.bind 'tree.move', eventNodeMove