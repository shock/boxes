json.cache! thing_json_cache_key(@thing, "tree/parents") do
  path = @thing.self_and_ancestors
  path_ids = path.map(&:id)

  json.array! container_sort(path.first.children) do |thing|
    json_ltree_builder( json, thing, path_ids )
  end
end