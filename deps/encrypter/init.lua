local keyg=require("./utils/keygen.lua")
local ran=require("./utils/randomizer.lua")
local enc=require("./utils/encrypt.lua")
local dec=require("./utils/decrypt.lua")
local tab={
	['Keygen']=keyg,
	['Randomizer']=ran,
	['Encrypt']=enc,
	['Decrypt']=dec,
}
return tab