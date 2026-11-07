Config = {}

Config.RequireJob = false
Config.AllowedJobs = {
    police = 0,
    mechanic = 0,
    roadworker = 0
}

Config.Editor = {
    coneModel = `prop_mp_cone_02`,
    placementDistance = 4.0,
    groundOffset = 0.02,
    defaultSpacing = 3.0
}

Config.Traffic = {
    enabled = true,
    scanInterval = 250,
    approachDistance = 35.0,
    barrierDistance = 8.0,
    diversionDistance = 35.0,
    diversionOffset = 3.5,
    maxVehicles = 24,
    cooldown = 6000
}
