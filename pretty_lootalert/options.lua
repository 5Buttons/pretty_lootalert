---
-- /@ loot toast options; // s0h2x, pretty_wow @/

local _, private = ...;

local AceConfig = LibStub("AceConfig-3.0");
local AceConfigDialog = LibStub("AceConfigDialog-3.0");
local AceDB = LibStub("AceDB-3.0");
local AceDBOptions = LibStub("AceDBOptions-3.0");
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0");
local GetAuctionItemClasses = GetAuctionItemClasses;
local Weapon, Armor, Container, Consumable, _, TradeGoods, Projectile, Quiver, Recipe, Gem, Misc, Quest = GetAuctionItemClasses();
local PrettyLootAlert = LibStub("AceAddon-3.0"):NewAddon("PrettyLootAlert", "AceConsole-3.0");

private.config = {};

local defaults = {
    profile = {
        scale = 1, sound = true, time = 0.30, numbuttons = 4, anims = true,
        offset_x = 4, point_x = 0, point_y = 0,
        looting = true, creating = true, rolling = true,
        money = true, recipes = true, honor = true,
        ignore_level = true, low_level = 2, max_level = 4, filter = false,
        filter_type = {}
    }
};

function PrettyLootAlert:SyncConfig()
    for key, value in pairs(self.db.profile) do
        private.config[key] = value;
    end
    _G["LOOTALERT_NUM_BUTTONS"] = self.db.profile.numbuttons;
end


local options = {
    name = "Pretty Loot Alert",
    handler = PrettyLootAlert,
    type = "group",
    args = {
        general = {
            order = 1, type = "group", name = "General Settings",
            args = {
                header_display = { order = 1, type = "header", name = "Display" },
                scale = { order = 2, type = "range", name = "Scale", min = 0.5, max = 2.0, step = 0.1,
                    get = function() return PrettyLootAlert.db.profile.scale end,
                    set = function(_, val) PrettyLootAlert.db.profile.scale = val; private.config.scale = val; end,
                },
                numbuttons = { order = 3, type = "range", name = "Max Alerts", min = 1, max = 8, step = 1,
                    get = function() return PrettyLootAlert.db.profile.numbuttons end,
                    set = function(_, val) PrettyLootAlert.db.profile.numbuttons = val; private.config.numbuttons = val; _G["LOOTALERT_NUM_BUTTONS"] = val; end,
                },
                time = { order = 4, type = "range", name = "Update Time", min = 0.1, max = 2.0, step = 0.1,
                    get = function() return PrettyLootAlert.db.profile.time end,
                    set = function(_, val) PrettyLootAlert.db.profile.time = val; private.config.time = val; end,
                },
                offset_x = { order = 5, type = "range", name = "Alert Spacing", min = 0, max = 20, step = 1,
                    get = function() return PrettyLootAlert.db.profile.offset_x end,
                    set = function(_, val) PrettyLootAlert.db.profile.offset_x = val; private.config.offset_x = val; end,
                },

                header_position = { order = 10, type = "header", name = "Position" },
                unlock_button = {
                    order = 11,
                    type = "execute",
                    name = function()
                        if _G.LootAlertAnchorFrame and _G.LootAlertAnchorFrame:IsShown() then
                            return "Lock Frame"
                        else
                            return "Unlock Frame"
                        end
                    end,
                    desc = "Shows a movable frame to visually adjust the position of the alerts.",
                    func = function()
                        if _G.PrettyLootAlert_ToggleAnchor then
                            _G.PrettyLootAlert_ToggleAnchor()
                            _G.PLA_REFRESH_PANEL_NEEDED = true
                        end
                    end,
                },
                point_x = { order = 12, type = "range", name = "X Position", min = -1000, max = 1000, step = 1,
                    get = function() return PrettyLootAlert.db.profile.point_x end,
                    set = function(_, val) PrettyLootAlert.db.profile.point_x = val; private.config.point_x = val; end,
                },
                point_y = { order = 13, type = "range", name = "Y Position", min = -1000, max = 1000, step = 1,
                    get = function() return PrettyLootAlert.db.profile.point_y end,
                    set = function(_, val) PrettyLootAlert.db.profile.point_y = val; private.config.point_y = val; end,
                },

                header_effects = { order = 20, type = "header", name = "Effects" },
                sound = { order = 21, type = "toggle", name = "Play Sounds",
                    get = function() return PrettyLootAlert.db.profile.sound end,
                    set = function(_, val) PrettyLootAlert.db.profile.sound = val; private.config.sound = val; end,
                },
                anims = { order = 22, type = "toggle", name = "Play Animations",
                    get = function() return PrettyLootAlert.db.profile.anims end,
                    set = function(_, val) PrettyLootAlert.db.profile.anims = val; private.config.anims = val; end,
                },
            }
        },
        activity = {
            order = 2, type = "group", name = "Activity Types",
            args = {
                looting = { order = 1, type = "toggle", name = "Looting",
                    get = function() return PrettyLootAlert.db.profile.looting end,
                    set = function(_, val) PrettyLootAlert.db.profile.looting = val; private.config.looting = val; end,
                },
                creating = { order = 2, type = "toggle", name = "Crafting",
                    get = function() return PrettyLootAlert.db.profile.creating end,
                    set = function(_, val) PrettyLootAlert.db.profile.creating = val; private.config.creating = val; end,
                },
                rolling = { order = 3, type = "toggle", name = "Rolling",
                    get = function() return PrettyLootAlert.db.profile.rolling end,
                    set = function(_, val) PrettyLootAlert.db.profile.rolling = val; private.config.rolling = val; end,
                },
                money = { order = 4, type = "toggle", name = "Money",
                    get = function() return PrettyLootAlert.db.profile.money end,
                    set = function(_, val) PrettyLootAlert.db.profile.money = val; private.config.money = val; end,
                },
                recipes = { order = 5, type = "toggle", name = "Recipes",
                    get = function() return PrettyLootAlert.db.profile.recipes end,
                    set = function(_, val) PrettyLootAlert.db.profile.recipes = val; private.config.recipes = val; end,
                },
                honor = { order = 6, type = "toggle", name = "Honor/PvP",
                    get = function() return PrettyLootAlert.db.profile.honor end,
                    set = function(_, val) PrettyLootAlert.db.profile.honor = val; private.config.honor = val; end,
                },
            }
        },
        filtering = {
            order = 3, type = "group", name = "Item Filtering",
            args = {
                ignore_level = { order = 1, type = "toggle", name = "Ignore Level-Based Filtering",
                    get = function() return PrettyLootAlert.db.profile.ignore_level end,
                    set = function(_, val) PrettyLootAlert.db.profile.ignore_level = val; private.config.ignore_level = val; end,
                },
                low_level = { order = 2, type = "select", name = "Low Level Quality", values = { [0] = "|cff9d9d9dPoor|r", [1] = "|cffffffffCommon|r", [2] = "|cff1eff00Uncommon|r", [3] = "|cff0070ddRare|r", [4] = "|cffa335eeEpic|r", [5] = "|cffff8000Legendary|r", [6] = "|cffe6cc80Artifact|r", [7] = "|cffe6cc80Heirloom|r" },
                    disabled = function() return PrettyLootAlert.db.profile.ignore_level end,
                    get = function() return PrettyLootAlert.db.profile.low_level end,
                    set = function(_, val) PrettyLootAlert.db.profile.low_level = val; private.config.low_level = val; end,
                },
                max_level = { order = 3, type = "select", name = "Max Level Quality", values = { [0] = "|cff9d9d9dPoor|r", [1] = "|cffffffffCommon|r", [2] = "|cff1eff00Uncommon|r", [3] = "|cff0070ddRare|r", [4] = "|cffa335eeEpic|r", [5] = "|cffff8000Legendary|r", [6] = "|cffe6cc80Artifact|r", [7] = "|cffe6cc80Heirloom|r" },
                    disabled = function() return PrettyLootAlert.db.profile.ignore_level end,
                    get = function() return PrettyLootAlert.db.profile.max_level end,
                    set = function(_, val) PrettyLootAlert.db.profile.max_level = val; private.config.max_level = val; end,
                },
            }
        },
        profiles = { order = 4, type = "group", name = "Profiles", args = {} }
    }
};

function PrettyLootAlert:OnInitialize()
    self.db = AceDB:New("PrettyLootAlertDB", defaults, true);
    
    self.db.RegisterCallback(self, "OnProfileChanged", "SyncConfig");
    self.db.RegisterCallback(self, "OnProfileCopied", "SyncConfig");
    self.db.RegisterCallback(self, "OnProfileReset", "SyncConfig");
    
    options.args.profiles.args.profiles = AceDBOptions:GetOptionsTable(self.db);
    
    AceConfig:RegisterOptionsTable("PrettyLootAlert", options);
    AceConfigDialog:AddToBlizOptions("PrettyLootAlert", "Pretty Loot Alert");
    
    self:RegisterChatCommand("pla", "SlashCommand");
    self:RegisterChatCommand("prettyloot", "SlashCommand");

    self:SyncConfig();
end

function PrettyLootAlert:SlashCommand(input)
    if input == "config" or input == "" then
        AceConfigDialog:Open("PrettyLootAlert");
    else
        self:Print("Usage: /pla config - Opens configuration panel");
    end
end