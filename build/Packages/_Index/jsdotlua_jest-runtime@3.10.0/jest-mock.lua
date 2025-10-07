local REQUIRED_MODULE = require(script.Parent.Parent["jsdotlua_jest-mock@3.10.0"]["jest-mock"])
export type MaybeMockedDeep<T> = REQUIRED_MODULE.MaybeMockedDeep<T>
export type MaybeMocked<T> = REQUIRED_MODULE.MaybeMocked<T>
export type UnknownFunction = REQUIRED_MODULE.UnknownFunction 
export type Mock<T > = REQUIRED_MODULE.Mock<T >
export type ModuleMocker = REQUIRED_MODULE.ModuleMocker 
export type JestFuncFn = REQUIRED_MODULE.JestFuncFn 
export type JestFuncMocked = REQUIRED_MODULE.JestFuncMocked 
export type JestFuncSpyOn = REQUIRED_MODULE.JestFuncSpyOn 
return REQUIRED_MODULE
