![Lapis Lazuli](http://media-mcw.cursecdn.com/5/5e/Lapis_Lazuli_\(Block\).png)

# Sky Stone

Sky Stone is a plugin which lends it's name to the fact that it uses [Lapis lazuli](http://en.wikipedia.org/wiki/Lapis_lazuli) as a control block. Finally some use for all that Lapis Lazuli!

# Features

Like Ruby, the language we used to develop this plugin, the plugin uses convention over configuration. What that means? It tries to follow simple design patterns to provide it's functionality. 
Check out these awesome features:

## Minecarts routing

- Switching rails based on block-types and/or wool-colors
- Routing of minecarts based on using more than one switch
- Remembers your destination with the press of a stone-button
- Resets the destination to 'home' (which is configurable) when you exit the cart.
- Override destination by holding the right block-type or wool(color) in your hand.
- Messages it's intentions to the player.

### How to

#### Switch
Basically the below image explains how you need to layout your tracks.
In the center of it all is a block of lapis. In this example we've made four stops on each side.

![Basic Switch](http://f.cl.ly/items/2I2929470h152y3t0n26/switch.jpg)

#### Selector
A selector button is nothing more than the block you used to indicate directions a the switch with a button slapped on it AND a block of lapis adjacent to it (direction doesn't matter).

![Selector button](http://f.cl.ly/items/180C2P0B0w3l421y1k1O/selector.jpg)

#### Commands
The plugin supports the following command to set the route:

    /skystone route red
    


### TODO
- Default routes with glass
- Collision detection / locking of switch
- Eject player if on wrong side of the rails (at intersections)

### Issues

- Fix for players using the wrong side (left) of the rails

## Storage & sorting
- Auto sorter using minecarts

