json.array!(@nouns) do |noun|
  json.extract! noun, :id, :name, :parent_id, :description, :aquired_on, :cost, :value
  json.url noun_url(noun, format: :json)
end
