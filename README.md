# Config Setup for mrj-megaphone

Configuration Settings

* debug: Set to false to disable debugging.
* framework: Choose between "qb-core" or "esx" for your server's framework.
* megaphoneItem: Defines the item used for the megaphone ("megaphone" by default).
* ForceVolume: Forces volume on certain actions, set to true to enable.
* ForcedProximity: Sets the proximity range for actions (default: 20.0).
* Vehicle Classes :
The configuration includes vehicle classes that can be customized. The current classes available in the script are:

18 - Emergency Vehicles
Uncomment or modify additional vehicle classes as needed. Example classes include:

[!NOTE]  
0 - Compacts  
1 - Sedans  
2 - SUVs  
3 - Coupes  
4 - Muscle Cars  
5 - Sports Cars  
6 - Sports Classics  
7 - Super Cars  
8 - Motorcycles  
9 - Off-road Vehicles  
10 - Industrial Vehicles  
11 - Utility Vehicles  
12 - Vans  
13 - Bicycles  
14 - Boats  
15 - Helicopters  
16 - Planes  
17 - Service Vehicles  
18 - Emergency Vehicles  
19 - Military Vehicles  
20 - Commercial Vehicles  
21 - Trains  
22 - Trash Vehicles

* Framework-Specific Items
For the QB-Core Framework:

* megaphoneItem: The item used to trigger the megaphone, typically managed via ox_inventory. Make sure to add this item in your ox_inventory configuration.
For the ESX Framework:

* megaphoneItem: The item used for megaphone functionality, typically defined in the ESX inventory system. Add it to your esx_inventory database if necessary.

ox_inventory
To add the megaphone item to the inventory:
```
-- Add this to your ox_inventory items configuration
    ["megaphone"] = {
        label = "Megaphone",
        weight = 500,
        image = "megaphone.png",
        description = "A loudspeaker for communication."
    },

```
esx_inventory
For the megaphone item in the ESX framework, add the following to your ESX inventory database:
```
-- Add this to your esx_inventory items table
INSERT INTO items (`name`, `label`, `weight`, `rare`, `can_remove`, `price`) VALUES
    ('megaphone', 'Megaphone', 1, 0, 1, 0),
```
