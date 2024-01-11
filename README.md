# qb-propplacing
A small script for qb-core that adds the ability to place props.

If you want to support me use [ko-fi](https://ko-fi.com/bentix)❤️​.

## Features
- Metadata saving of the item
- Saves the citizenid of the Player that placed the item
- Ability to pickup the item with qb-target

## Planned Features
- Support more inventories

## Installation
**Dependencies**
- [core_inventory](https://core.tebex.io/package/5123274) or qb-inventory
- qb-target
- qb-core

### Step 1
Rename the resource from "qb-propplacing-main" to "qb-propplacing" and put it into your resources folder.

### Step 2
Import the import.sql file into your db.

### Step 3 (only core_inventory)
Search in core_inventory/client/main.lua:

```lua
RegisterNUICallback("useItem", function(data)
    TriggerServerEvent('core_inventory:server:useItem', data['item'], data['exact'])
end)
```

and add below:

```lua
RegisterNUICallback("placeItem", function(data)
    TriggerEvent('qb-propplacing:client:placeProp', data['item'], data['prop'])
end)
```


Search in core_inventory/config.lua:

```lua
['use'] = 'USE',
```

and add below:

```lua
['place'] = 'PLACE',
```


Search in core_inventory/html/script.js:

```lua
function dropItem(id, inventory) {

    $.post('https://core_inventory/dropItem', JSON.stringify({
        item: id,
        inventory: inventory || null
    }));

}
```

and add below:

```lua
function placeItem(name, prop) {


    closeMenu();

    $.post('https://core_inventory/placeItem', JSON.stringify({
        item: name,
        prop: prop
    }));

}
```


Search in core_inventory/html/script.js:

```js
if (
      $(el).parent().attr('inventory') == 'content-' + cid &&
      $(el).parent().attr('category') == 'weapons'
    ) {
      base =
        base +
        '<div class="dropdown-option shadow-pop-br" onclick="openAttachemnts(\'' +
        $(el).parent().attr('id') +
        '\')">' +
        getText('attachments') +
        '</div>'
    }
```

and add below:

```js
if (qbitems[$(el).parent().attr('name')].prop) {
      base =
        base +
        '<div class="dropdown-option shadow-pop-br" onclick="placeItem(\'' +
        $(el).parent().attr('name') +
        "', '" +
        qbitems[$(el).parent().attr('name')].prop +
        '\')">' +
        getText('place') +
        '</div>'
    }
```

### Step 4 (only qb-inventory)
Search in qb-inventory/html/ui.html:

```html
<div class="inv-option-item" id="item-use"><p>USE</p></div>
```

and add below:

```html
<div class="inv-option-item" id="item-place"><p>PLACE</p></div>
```


Search in qb-inventory/html/js/app.js:

```js
$('#item-use').droppable({
    hoverClass: 'button-hover',
    drop: function (event, ui) {
      setTimeout(function () {
        IsDragging = false
      }, 300)
      fromData = ui.draggable.data('item')
      fromInventory = ui.draggable.parent().attr('data-inventory')
      if (fromData.useable) {
        if (fromData.shouldClose) {
          Inventory.Close()
        }
        $.post(
          'https://qb-inventory/UseItem',
          JSON.stringify({
            inventory: fromInventory,
            item: fromData
          })
        )
      }
    }
  })
```

and add below:

```js
$('#item-place').droppable({
    hoverClass: 'button-hover',
    drop: function (event, ui) {
      setTimeout(function () {
        IsDragging = false
      }, 300)
      fromData = ui.draggable.data('item')
      if (fromData.useable) {
        Inventory.Close()
        $.post(
          'https://qb-inventory/PlaceItem',
          JSON.stringify({
            item: fromData
          })
        )
      }
    }
  })
```


Search in qb-inventory/client/main.lua:

```lua
RegisterNUICallback('UseItem', function(data, cb)
    TriggerServerEvent('inventory:server:UseItem', data.inventory, data.item)
    cb('ok')
end)
```

and add below:

```lua
RegisterNUICallback('PlaceItem', function(data, cb)
    local prop = QBCore.Shared.Items[data.item.name].prop

    TriggerEvent('qb-propplacing:client:placeProp', data.item, prop)
    cb('ok')
end)
```

## How to add a placeable item
Just add `prop = 'NAME OF THE PROP',` for the desired item in your qb-core items.lua

Make sure the prop works with qb-target because some of them don't have collision

List of props https://forge.plebmasters.de/objects/

## Showcase

