local assets = require("@root/assets")
local types = require("./types")

local devices: { types.Device } = {
	-- Apple
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20803
		name = "iPad 10th Gen",
		brand = "Apple",
		deviceType = "Tablet",
		platform = "iOS",
		physicalSize = Vector2.new(179.5, 248.6),
		resolution = Vector2.new(1640, 2360),
		ppi = 264,
		frame = assets.DeviceEmulator["iPad 10 Gen"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20136
		name = "iPad Air 5th Gen",
		brand = "Apple",
		deviceType = "Tablet",
		platform = "iOS",
		physicalSize = Vector2.new(178.5, 247.6),
		resolution = Vector2.new(1640, 2360),
		ppi = 265,
		frame = assets.DeviceEmulator["iPad Air (2022)"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=19280
		name = "iPad Mini 6th Gen",
		brand = "Apple",
		deviceType = "Tablet",
		platform = "iOS",
		physicalSize = Vector2.new(134.8, 195.4),
		resolution = Vector2.new(1488, 2266),
		ppi = 328,
		frame = assets.DeviceEmulator["iPad Mini 2022"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=23523
		name = "iPad Pro 11-inch",
		brand = "Apple",
		deviceType = "Tablet",
		platform = "iOS",
		physicalSize = Vector2.new(177.5, 249.7),
		resolution = Vector2.new(1668, 2420),
		ppi = 265,
		frame = assets.DeviceEmulator["iPad Pro 11 Inches"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=23532
		name = "iPad Pro 13-inch",
		brand = "Apple",
		deviceType = "Tablet",
		platform = "iOS",
		physicalSize = Vector2.new(215.5, 281.6),
		resolution = Vector2.new(2064, 2752),
		ppi = 265,
		frame = assets.DeviceEmulator["iPad Pro 12.9 Inches"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20629
		name = "iPhone 14 Plus",
		brand = "Apple",
		deviceType = "Smartphone",
		platform = "iOS",
		physicalSize = Vector2.new(78.1, 160.8),
		resolution = Vector2.new(1284, 2778),
		ppi = 458,
		frame = assets.DeviceEmulator["iPhone 14 Plus"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20596
		name = "iPhone 14 Pro Max",
		brand = "Apple",
		deviceType = "Smartphone",
		platform = "iOS",
		physicalSize = Vector2.new(77.6, 160.7),
		resolution = Vector2.new(1290, 2796),
		ppi = 460,
		frame = assets.DeviceEmulator["iPhone 14 Pro Max"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20614
		name = "iPhone 14 Pro",
		brand = "Apple",
		deviceType = "Smartphone",
		platform = "iOS",
		physicalSize = Vector2.new(71.5, 147.5),
		resolution = Vector2.new(1179, 2556),
		ppi = 460,
		frame = assets.DeviceEmulator["iPhone 14 Pro"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20643
		name = "iPhone 14",
		brand = "Apple",
		deviceType = "Smartphone",
		platform = "iOS",
		physicalSize = Vector2.new(71.5, 146.7),
		resolution = Vector2.new(1170, 2532),
		ppi = 460,
		frame = assets.DeviceEmulator["iPhone 14"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=20129
		name = "iPhone SE",
		brand = "Apple",
		deviceType = "Smartphone",
		platform = "iOS",
		physicalSize = Vector2.new(67.3, 138.4),
		resolution = Vector2.new(750, 1334),
		ppi = 325,
		frame = assets.DeviceEmulator["iPhone SE"],
	},

	-- Google
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=21701
		name = "Google Pixel 7 Pro",
		brand = "Google",
		deviceType = "Smartphone",
		physicalSize = Vector2.new(76.6, 162.9),
		platform = "Android",
		resolution = Vector2.new(1440, 3120),
		ppi = 513,
		frame = assets.DeviceEmulator["Google Pixel 7 Pro"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=21719
		name = "Google Pixel 7",
		brand = "Google",
		deviceType = "Smartphone",
		physicalSize = Vector2.new(73.2, 155.6),
		platform = "Android",
		resolution = Vector2.new(1080, 2400),
		ppi = 416,
		frame = assets.DeviceEmulator["Google Pixel 7"],
	},

	-- Samsung
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=21687
		name = "Samsung Galaxy S23 Ultra",
		brand = "Samsung",
		deviceType = "Smartphone",
		platform = "Android",
		physicalSize = Vector2.new(78.1, 163.4),
		resolution = Vector2.new(1440, 3088),
		ppi = 500,
		frame = assets.DeviceEmulator["Samsung Galaxy S23 Ultra"],
	},
	{
		-- Specs: https://phonedb.net/index.php?m=device&id=22841
		name = "Samsung Galaxy S23",
		brand = "Samsung",
		deviceType = "Smartphone",
		platform = "Android",
		physicalSize = Vector2.new(76.5, 158),
		resolution = Vector2.new(1080, 2340),
		ppi = 401,
		frame = assets.DeviceEmulator["Samsung Galaxy S23"],
	},
}

return devices
