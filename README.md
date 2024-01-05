# qb-propplacing
A small script for qb-core that adds the ability to place props with [core_inventory](https://core.tebex.io/package/5123274).

## Features
- Metadata saving of the item
- Saves the citizenid of the Player that placed the item
- Ability to pickup a item with qb-target

## Installation
**Dependencies**
- [core_inventory](https://core.tebex.io/package/5123274)
- qb-target
- qb-core

### Step 1
Rename the resource from "main-qb-propplacing" to "qb-propplacing" and put it into your resoucres folder.

### Step 2
Import the import.sql file into your db.

### Step 3
Search in core_inventory/client/main.lua:

```
RegisterNUICallback("useItem", function(data)
    TriggerServerEvent('core_inventory:server:useItem', data['item'], data['exact'])
end)
```

and add below:

```
RegisterNUICallback("placeItem", function(data)
    TriggerEvent('qb-propplacing:client:placeProp', data['item'], data['prop'], data['exact'])
end)
```

### Step 4
Search in core_inventory/config.lua:

```
['use'] = 'USE',
```

and add below:

```
['place'] = 'PLATZIEREN',
```

### Step 5
Search in core_inventory/html/script.js:

```
function dropItem(id, inventory) {

    $.post('https://core_inventory/dropItem', JSON.stringify({
        item: id,
        inventory: inventory || null
    }));

}
```

and add below:

```
function placeItem(name, prop) {


    closeMenu();

    $.post('https://core_inventory/placeItem', JSON.stringify({
        item: name,
        prop: prop
    }));

}
```

### Step 6
Search in core_inventory/html/script.js:

```
if ($(el).parent().attr('inventory') == 'content-' + cid && $(el).parent().attr('category') != 'weapons' && $(el).parent().attr('category') != 'food' && $(el).parent().attr('category') != 'drinks') {
        base = base + '<div class="dropdown-option shadow-pop-br" onclick="useItem(\'' + $(el).parent().attr('name') + '\', \'' + $(el).parent().attr('id') + '\')">' + getText('use') + '</div>';
    }
```

and add below:

```
if (qbitems[$(el).parent().attr('name')].prop) {
        base = base + '<div class="dropdown-option shadow-pop-br" onclick="placeItem(\'' + $(el).parent().attr('name') + '\', \'' + qbitems[$(el).parent().attr('name')].prop + '\')">' + getText('place') + '</div>';
    }
```