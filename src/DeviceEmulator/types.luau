export type DeviceScaleType = "FitToScreen" | "Resolution" | "Physical"
export type DevicePlatform = "iOS" | "Android"
export type DeviceBrand = "Apple" | "Google" | "Samsung"
export type DeviceType = "Tablet" | "Smartphone" | "Laptop" | "Desktop"

type Image = {
	Image: string,
	ImageRectOffset: Vector2,
	ImageRectSize: Vector2,
}

export type Device = {
	name: string,
	platform: DevicePlatform,
	deviceType: DeviceType,
	brand: DeviceBrand,
	physicalSize: Vector2,
	resolution: Vector2,
	ppi: number,
	frame: Image,
}

return nil
