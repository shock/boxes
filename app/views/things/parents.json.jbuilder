path = @thing.self_and_ancestors
path_ids = path.map(&:id)

json.array! path.first.children do |thing|
  json_ltree_builder( json, thing, path_ids )
end