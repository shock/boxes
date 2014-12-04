json.array!(@things) do |thing|
  json.extract! thing, :id, :name, :parent_id, :description, :aquired_on, :cost, :value
  json.url thing_url(thing, format: :json)
end
