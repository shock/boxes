json.array! container_sort(@thing.children) do |thing|
  json_ltree_builder( json, thing, [] )
end
