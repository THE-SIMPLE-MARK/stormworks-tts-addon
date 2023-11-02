--- Note, minimizer functionality can be disabled in your project settings. (right click -> Folder Settings)
--- A large scale update for supporting Addon work is in the works, so keep an eye on the extension!

vehicles = {}
requestQueue = {}

tick = 0
lastRequest = 0
function onTick(game_ticks)
	-- loop through each vehicle
	for vehicleId, vehicleData in pairs(vehicles) do
		-- skip iteration if vehicle is unloaded
		if vehicleData.isLoaded == false then goto continue end

		-- check if the tts_input has changed
		data, is_success = server.getVehicleDial(vehicleId, "tts_input")
		input = data.value

		if input ~= 0 then
			-- add request to queue
			server.announce("[TTS]", "/tts?input=" .. tostring(math.floor(input)) .. " | Added to queue")
			table.insert(requestQueue, "/tts?input=" .. tostring(math.floor(input)))
		end

		::continue::
	end

	-- try to send the last item in the request queue
	lastItem = requestQueue[#requestQueue]
	ticksSinceLastRequest = tick - lastRequest

	if ticksSinceLastRequest >= 2 and lastItem ~= nil then
		server.announce("[TTS]", lastItem .. " | GET Sent")
		server.httpGet(3200, lastItem)

		-- remove item from queue
		table.remove(requestQueue, #requestQueue)
	end

	tick = tick + 1
end

function onVehicleLoad(vehicleId)
	server.announce("[TTS]", "onVehicleLoad")
	-- check if it has a dial named tts_input
	data, is_success = server.getVehicleDial(vehicleId, "tts_input")

	if data and is_success then
		-- get it's coordinates
		transformMatrix, is_success = server.getVehiclePos(vehicleId, 0, 0, 0)
		x, y, z = matrix.position(transformMatrix)

		-- add to vehicles table
		vehicles[vehicleId] = { isLoaded = true }
		server.announce("[TTS]", vehicleId .. " added to table")
	end
end

function onVehicleUnload(vehicle_id)
	server.announce("[TTS]", "onVehicleUnload")
	-- set isLoaded property to false (so we don't make unnecessary loops in onTick)
	vehicles[vehicle_id].isLoaded = false
end

function onVehicleDespawn(vehicle_id)
	server.announce("[TTS]", "onVehicleDespawn")
	-- remove from vehicles table
	vehicles[vehicle_id] = nil
end