# UteKnark
When you want to grow your weed free, man! Fresh air, man!

![UteKnark logo](uteknark.png)

Gotten tired of everyone knowing where the "drug location" is? Server operator tired of moving said location?

What if you open up the whole map, so every patch of dirt, every lawn and every plot of land becomes somewhere you can plant your weed?

That is exactly what UteKnark does!

# Player manual

First you need to get a hold of seeds. How you do this is different from server to server. Ask whatever support staff your server has.

Next you will have to find somewhere to plant. Almost anywhere where there is grass or dirt will work, and even some places with sand! Make sure it's not directly under something, but has a pretty clear view of the sky.

When you have your spot, use the seed item in your inventory. You will get feedback on the planting process.

Shortly after planting, your little sapling will need some tending. It depends on soil quality, but it's within a couple of minutes.

When the sapling has been tended, it will need some time to grow, and then it will need tending again. If you fail to tend your plant, it will die. What is needed for the tending process can be different from server to server. In this fork, tending uses the fertilizer item configured as `Config.Items.Tend` (default: `dunger`). Set it to `nil` to disable the requirement.

Once the plant has reached the very last stage (Stage 6 by default), it will be ready to harvest. How much weed you get, and how many seeds, is entirely up to the server you play on.

At any point during this process, anyone can come along and destroy your plant, so you want to put it somewhere nobody will find it. Keep in mind that anyone can harvest it when it's ready, too, so you might want to guard it!

# Moar info plx

- Why the weird name? 

  It's Swedish. Ute means "outside" and Knark means "drugs" - You're growing your drugs outside.


- What do I need?

  - One of:
    - [es_extended](https://github.com/esx-framework/esx_core) (ESX)
    - [qb-core](https://github.com/qbcore-framework/qb-core) (QBCore)
    - Standalone (no framework) - uses a command to plant seeds
    - [oxmysql](https://github.com/overextended/oxmysql)
    - Already existing ways to obtain seeds and sell the weed you harvest.
    - The items you want to use for seeds, fertilizer (tending) and harvested weed.

- How do I install it?

    1. Clone this repository.
    2. Make sure the directory it creates is called `mosh_uteknark`.
    3. Move the files into your `resources/` directory.
    4. Make sure your chosen framework (ESX/QB) and `oxmysql` are started before this resource, then add `ensure mosh_uteknark` to your `server.cfg`.
    5. Import [mosh_uteknark.sql](mosh_uteknark.sql) into your database.
    6. Modify [the configuration](config.lua) to suit your needs. Pay special attention to `Framework`, `Inventory` and `Items`.
    7. Either `refresh` and `start mosh_uteknark` or restart your server.


- Item definitions

  You must add the used items to your framework/inventory. Ready-to-paste snippets are included:

  - ESX: `items/esx_items.sql` (pick weight-based or limit-based section)
  - QBCore: `items/qb_items.lua` (add to `qb-core/shared/items.lua`)
  - ox_inventory: `items/ox_inventory_items.lua` (add to `ox_inventory/data/items.lua`)



- Standalone note

  If you run the resource without a framework, set `Config.Framework = 'standalone'`.
  In that mode, planting is done via the command defined in `Config.Standalone.PlantCommand` (default: `/moshseed`).

- Why multi-framework?

  This fork adds a small bridge layer so the same resource can run on ESX, QBCore, or in standalone mode.

- Will you release a VRP version?

    No.

- Can I modify and release the script?

  Check out [the license](LICENSE). The short version is: yes. If you publish a fork, please use a distinct resource name to avoid conflicts.

- Where can I plant weed?

    Pretty much anywhere there is grass or dirt. The resource checks what material the ground is, and allows or disallows planting based on that. Different ground types have different soil quality and will cause the plants to grow slower or faster.

- How many plants can be planted at any given time?

    There are currently no limits on this, but as testing progresses we might discover a need to impose limits. On my rather mediocre computer, having a thousand plants within a radius of 200 meters is not a problem.

- What do I do if I'm having trouble with the resource?

    Please post any problems/bug reports on the [mosh_uteknark issues](https://github.com/moshquit0/mosh_uteknark/issues) page on GitHub. Kindly check if the issue is already listed first.
    
    **DO NOT** look me up on Discord for support. I do not provide chat-based support for this resource, and will simply block you on there.

- Where can I get more details about what I need to plant, tend and harvest the plants?

    The script is made to be as configurable as possible. That means the details can be quite different between the defaults and the server you play on. See [the config](config.lua) for the default values.

# Thanks to DemmyDemon/esx_uteknark and:

- Tails for putting up with my obsessive coding into the night.
- Degen for the encouragement and feedback.
- VigeStig for the push to make it happen.
- Testers: Rolkann, Waldost (more to come as they remind me who they are)
