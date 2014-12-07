json.id @thing.id
json.label @thing.name
json.description @thing.name
json.children do
  json.partial! @thing.children, 'things/tree', as: tree
end