json.cache! thing_json_cache_key(@thing, "tree/children") do
  json.array! container_sort(@thing.children) do |thing|
    json_ltree_builder( json, thing, [] )
  end
end