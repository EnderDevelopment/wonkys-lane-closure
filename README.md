# FiveM Lane Closure Resource: Wonkys Lane Closure

Wonkys Lane Closure is a configurable FiveM resource for creating manual cone layouts and redirecting ambient NPC traffic around lane closures. It provides an in-game cone placement editor, synchronized persistent layouts, permission controls, ox_lib menus and notifications, and configurable traffic diversion behavior.

## Install

1. Create a resource folder named `wonkys_laneclosure` inside your FiveM server's resources directory.

2. Add the following files and folders:

```text
wonkys_laneclosure/
├── client/
│   └── main.lua
├── server/
│   └── main.lua
├── config.lua
└── fxmanifest.lua
```

3. Ensure `ox_lib` is installed and started before this resource.

4. Add the resource to `server.cfg`:

```cfg
ensure ox_lib
ensure wonkys_laneclosure
```

5. Restart the resource or server.

The resource creates `layout.json` automatically when the first layout is saved.

## Configuration

Edit `config.lua` to configure permissions, cone placement, and traffic behavior.

### Permissions

By default, all players can manage lane closures:

```lua
Config.RequireJob = false
```

To require a QBCore job, enable job restrictions:

```lua
Config.RequireJob = true
```

Configure the allowed jobs and minimum grades:

```lua
Config.AllowedJobs = {
    police = 0,
    mechanic = 0,
    roadworker = 0
}
```

When job restrictions are enabled, the resource requires `qb-core`.

### Traffic Settings

Traffic diversion can be enabled or disabled:

```lua
Config.Traffic.enabled = true
```

Available traffic settings include:

- Scan interval
- Vehicle approach distance
- Barrier distance
- Diversion distance
- Diversion offset
- Maximum vehicles routed per scan
- Vehicle reroute cooldown

## Use

1. In game, use the command:

```text
/laneclosure
```

2. Choose one of the menu options:

- Edit current layout
- Create new layout
- Save layout
- Clear layout

3. While editing:

- Press `E` to place a cone in front of your character.
- Press `Backspace` to remove the last cone.
- Press `G` to save the current layout.
- Press `X` to close the editor.

4. Place at least two cones in a line to create a closure path. The resource uses the first and last cones to calculate the closure direction and diversion area.

5. Save the layout to persist it for all players. The saved layout is written to `layout.json` and synchronized to connected clients.

Ambient NPC vehicles approaching the configured cone layout may be assigned a driving task that moves them around the closure. Player-controlled vehicles are not rerouted.

## Exports

### GetConeLayout

Returns the current cone layout.

```lua
local layout = exports.wonkys_laneclosure:GetConeLayout()
```

### ClearLayout

Clears the current layout and saves the cleared state when the calling player has management permission.

```lua
exports.wonkys_laneclosure:ClearLayout()
```

## Requirements

- FiveM
- `ox_lib`
- Lua 5.4 support
- `qb-core` only when `Config.RequireJob` is enabled

## Notes

- A maximum of 200 cones can be saved.
- Cone positions and headings are validated by the server before being stored.
- Cone objects are removed when the resource stops.
- Traffic routing affects ambient NPC vehicles only.
- The resource does not automatically remove or permanently alter road paths.

---

More FiveM resource projects by EnderDevelopment: https://github.com/EnderDevelopment

Project page: https://dash.enderdevelopment.com/community/682a2f5c-6b58-417d-930d-b4d7947fff69?utm_source=github&utm_medium=readme&utm_campaign=auto_publish&utm_content=682a2f5c-6b58-417d-930d-b4d7947fff69
