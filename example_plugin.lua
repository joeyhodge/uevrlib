local uevrUtils = require('libs/uevr_utils')
local controllers = require('libs/controllers')
local plugin = require('libs/core/plugin')

-- press F1 to change all X icons in the game to display RB instead
register_key_bind("F1", function()
	print("F1 pressed")
	
	local XBOX_ICONS_DATA = "IndianaUIControllerIconsData /Game/UI/XboxOneControllerIcons.XboxOneControllerIcons"
	local iconsData = uevrUtils.find_required_object(XBOX_ICONS_DATA)
	--iconsData.Icons is a TMap which normally can't be accessed in Lua
	
	--plugin.showDebug = true
	print("FULL LIST")
	local result = plugin.getProperty(iconsData, "Icons")
		if result ~= nil then
		for key, icon in pairs(result) do
			print(key, icon:get_full_name())
		end
	end

	print("BEFORE")
	local result = plugin.getProperty(iconsData, "Icons[Gamepad_FaceButton_Left]")
	if result ~= nil then
		print(result:get_full_name())
	else
		print("Result is nil")
	end

	--------------------
	-- This is the only section of code thats actually needed. The rest is just to show how it works
	local XBOX_RB_TEXTURE = "Texture2D /Game/UI/Art/FrontEnd/General/Navigation/Xbox/T_Button_Xbox_RB.T_Button_Xbox_RB"
	local rbTexture = uevrUtils.find_required_object(XBOX_RB_TEXTURE)
	plugin.setProperty(iconsData, "Icons[Gamepad_FaceButton_Left]", rbTexture)
	--------------------
 
	print("AFTER")
	local result = plugin.getProperty(iconsData, "Icons[Gamepad_FaceButton_Left]")
	if result ~= nil then
		print(result:get_full_name())
	else
		print("Result is nil")
	end
	--plugin.showDebug = false

end)

-- press F2 to show all of the primitive components near your right hand controller
register_key_bind("F2", function()
	print("F2 pressed")

    --plugin.showDebug = true
	local location = controllers.getControllerLocation(Handed.Right)
	local radius = 50
	local objectTypes = {0,5,14,19}
	local classFilter = uevrUtils.get_class("Class /Script/Engine.PrimitiveComponent")
	local ignoreActors = {pawn}
	local foundComponents = {}

	-- This is what the API version looks like in KismetSystemLibrary
	--   static bool SphereOverlapComponents(const class UObject* WorldContextObject, const struct FVector& SpherePos, float SphereRadius, const TArray<EObjectTypeQuery>& ObjectTypes, class UClass* ComponentClassFilter, const TArray<class AActor*>& ActorsToIgnore, TArray<class UPrimitiveComponent*>* OutComponents);
	--
	-- The OutComponents TArray normally can't be handled in Lua
	--
	-- Below is the equivalent call using the plugin. Notice result.OutComponents uses the exact name that the API uses. 
	-- If the function returns a value then result.ReturnValue will be set to the returned value.
	local result = plugin.executeFunction(kismet_system_library, "SphereOverlapComponents", uevrUtils.get_world(), location, radius, objectTypes, classFilter, ignoreActors, foundComponents)
	if result ~= nil then
		if result.ReturnValue == true then
			local components = result.OutComponents or {}
			for i = 1, #components do
				local comp = components[i]
				print("Component:", comp:get_full_name())
			end
		end
	end
	--plugin.showDebug = false
end)
