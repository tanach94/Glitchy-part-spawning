--this script is created by masternamedjoe on DC, and on roblox Jozinn93, i took like hour or two on this. For HiddenDevs luau test.

local Game_players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Server_random_part_spawning_oop_table = {}
local Part_deleted_signal = {}
local Count_of_killed_people = {}

Part_deleted_signal.__index = Part_deleted_signal
Server_random_part_spawning_oop_table.__index = Server_random_part_spawning_oop_table

local Can_spawn_part = true
local Can_spawn_part_cooldown_time = .3

local function Detect_ground_under_main_part(Main_part:BasePart) -- detects if spawned part is close to ground, if yes destroy
	-- this function creates a ray, under main part, and checks if there's basepart, if yes the main part will destroy
	local Params = RaycastParams.new() -- raycastparams are custom parameters for raycast, for example if you want include or exclude some instances and its childs

	Params.FilterType = Enum.RaycastFilterType.Exclude
	Params.FilterDescendantsInstances = {Main_part} -- excludes all descendants of itself

	local Direction = Vector3.new(0, -5, 0) -- vector3 is a X, Y, Z coordinations in workspace, from origin
	
	local RayCast = workspace:Raycast(Main_part.Position + Vector3.new(0,3,0), Direction, Params) -- returns a raycast table infromations where the ray touched

	if RayCast then
		local hitInstance = RayCast.Instance
		hitInstance.Color = Return_random_color_R_G_B()
		return hitInstance
	else
		return nil
	end
end

local function Put_random_size_on_part_tween(Part, MinSize, MaxSize) -- pretty simple tween size effect for backend
	-- this function is for smooth size changing, tween service is because of that smoothness
	
	local Size_X_Random = math.random(MinSize,MaxSize)
	local Size_Y_Random = math.random(MinSize,MaxSize)
	local Size_Z_Random = math.random(MinSize,MaxSize)

	local Tween_info = TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	local Tween_goal = {Size = Vector3.new(Size_X_Random, Size_Y_Random, Size_Z_Random)}
	local Tween_size = TweenService:Create(Part, Tween_info, Tween_goal)
	Tween_size:Play()	
end

local function Rotate_part_tween(Part:BasePart, Rotation : Vector3) -- another effect for backend, good rotate
	local Tween_info = TweenInfo.new(1, Enum.EasingStyle.Back, Enum.EasingDirection.InOut)
	local Tween_goal = {Rotation = Rotation}
	local Tween_rotate = TweenService:Create(Part, Tween_info, Tween_goal)
	Tween_rotate:Play()	
end

local function Return_a_random_position_around_object(Object:any) : Vector3 -- this will give you position around ["Object"] basically
	local Object_original_position = Object.Position
	local Multiplier = 10
	
	-- im putting -360 to 360 because of degrees of orientation
	-- sin and cos, it's math and it allows number to be in radiants
	-- so using this function i can get random position around Object and set Part's position there.
	-- Im also multiplying it by 10, the distance was too small from object
	
	local Random_position_X = math.random(-360,360)
	local Random_position_Y = math.random(-360,360)
	local Random_object_Y = math.random(-7,7)

	local Calculated_sin = math.sin(Random_position_X) * Multiplier
	local Calculated_cos = math.cos(Random_position_Y) * Multiplier

	local Object_around_position = Object_original_position + Vector3.new(Calculated_sin, Random_object_Y, Calculated_cos)
	return Object_around_position
end

local function Return_vector3_with_random_x_y_z(min_number, max_number) : Vector3 -- simple random rotation
	-- im using math.random for random number within x = < and x = >
	
	local Random_Y = math.random(-min_number,max_number)
	local Random_X = math.random(-min_number,max_number)
	local Random_Z = math.random(-min_number,max_number)

	local Random_Vector3 = Vector3.new(Random_X, Random_Y, Random_Z)
	return Random_Vector3
end

function Return_random_color_R_G_B() : Color3 -- random color..
	local random_R = math.random(0,255)
	local random_G = math.random(0,255)
	local random_B = math.random(0,255)
	--color have 0 to 255, so im choosing between them to get random color R(ed), color G(green), color B(lue)
	-- these 3 numbers RGB makes one color
	
	local Random_R_G_B = Color3.fromRGB(random_R, random_G, random_B)
	return Random_R_G_B
end

local function Create_glitchy_part() : Part -- creates part.._
	-- instance is function where you can add object in game, with big choose list
	local Part = Instance.new("Part")
	Part.Parent = workspace
	Part.CanCollide = false
	Part.Anchored = true
	Part.Transparency = .5
	Part.Color = Return_random_color_R_G_B()
	return Part
end

local function Make_spawn_parts_around_player(Player:Player) -- basically, make spawn part around this player
	local Player_character = Player.Character
	-- every player has its own character
	local New_Class_Random_Part_spawning = Server_random_part_spawning_oop_table.Random_part_spawning_new(Player_character)
end

local function Character_humanoid_root_part_loaded_detection(Character:Model) : boolean -- this is because of game loading and checking if player character is loaded
	if not Character then return end 
	local Possible_humanoid_root_part = Character:FindFirstChild("HumanoidRootPart")
	-- findfirstchild is function where if the item is not found, it dont give error, it also search for first child named "HumanoidRootPart"
	if not Possible_humanoid_root_part then return end 
	return true
end

local function Spawn_parts_around_game_players() -- spawning part around these all players
	for Index, Player in pairs(Game_players:GetPlayers()) do -- for i,v is in pairs is loop throught table or object:GetChildren() or object:GetDescendants(), for i,v in ipairs i know too. 
		-- ipairs is like sorting result, a table with index 1 to inf, will give you sorted result from 1 to inf structured from lowest to highest
		if Character_humanoid_root_part_loaded_detection(Player.Character) then
			Make_spawn_parts_around_player(Player)
		end
	end
end

----------- Custom listener
function Part_deleted_signal.New() -- this creates new metatable for signal so parts after being destroyed will cause something
	return setmetatable({_listeners = {}}, Part_deleted_signal) -- setmetatable is function what adds whatever table to table with its index
end

function Part_deleted_signal:Connect(callback: (any) -> ()) -- adds new connection in listeners so i can communicate after i destroy metatable of part
	local connection = { -- _signal is so self is not lost, _handler is the passing function what will fire after fire
		_handler = callback,
		_signal = self,
	}

	function connection:Disconnect() -- creates a function to disconnect, when this is fired a created function will disconnect itself
		local listeners = self._signal._listeners
		local index = table.find(listeners, self)
		if index then
			table.remove(listeners, index)
		end
	end

	table.insert(self._listeners, connection)
	return connection
end

function Part_deleted_signal:Fire(...) -- this, after i fire, will call my connection and pass information
	local listeners = self._listeners
	for i = #listeners, 1, -1 do -- basically goes throught all listeners and if there are, it calls a function in task.spawn so it run in it own parallel 
		local listener = listeners[i]
		if listener then
			task.spawn(listener._handler, ...)
		end
	end
end

function Part_deleted_signal:Destroy() -- and then this, will remove all connections of signal 
	for _, listener in ipairs(self._listeners) do
		listener:Disconnect() 
	end
	self._listeners = {}
end
-----------

function Server_random_part_spawning_oop_table.Random_part_spawning_new(Target) -- im creating this metatable, for one part, then setting around Target and other stuff
	local self = setmetatable({}, Server_random_part_spawning_oop_table) -- returns a metatable what can be controlled using local a = new(Target), a:DoThis() and its original it have saved things in its self
	
	-- setting target, the target where this part will be around, target is character.
	self.Target = Target
	self.Target_humanoid_root_part = self.Target.HumanoidRootPart
	self.Target_humanoid = self.Target.Humanoid 
	
	 -- creating a part, setting his position and everything using functions i made 
	self.Part = Create_glitchy_part()
	self.Rotation = Return_vector3_with_random_x_y_z(-20,20)
	self.Position = Return_a_random_position_around_object(self.Target_humanoid_root_part)
	self:Set_properties_of_self()

	self.Connections = {}
	self.OnDeleted = Part_deleted_signal.New() -- the connection for when part is destroyed, little experimenting

	self.Connections.Task_deleting = task.delay(5, function()
		self:Delete_itself()
	end)

	self.OnDeleted:Connect(function() -- checks whatever i deleted this metatable, then take damage to my humanoid and adds my hum kill count
		local function Humanoid_died()
			if not Count_of_killed_people[self.Target_humanoid] then
				Count_of_killed_people[self.Target_humanoid] = 0
			end
			Count_of_killed_people[self.Target_humanoid] += 1
		end

		self.Target_humanoid:TakeDamage(5)

		if self.Target_humanoid.Health <= 0 then
			Humanoid_died()
		end
	end)

	local function Local_coroutine_loop()
		while task.wait(1) do -- a loop, will run until coroutine is cancalled of this part
			self.Part.CFrame = CFrame.lookAt(self.Part.Position, self.Target_humanoid_root_part.Position)
			Rotate_part_tween(self.Part, Vector3.new(0,360,0))
			Put_random_size_on_part_tween(self.Part, 1, 10)
		end
	end

	self.Connections.Coroutine = coroutine.create(Local_coroutine_loop) -- coroutine is like parallel too, but you can manipulate with it, different than task.spawn
	coroutine.resume(self.Connections.Coroutine)

	local Ground_detected_close_to_part = Detect_ground_under_main_part(self.Part) -- delete itself after part is too close to ground
	if Ground_detected_close_to_part then
		self:Delete_itself() -- call this function so part deletes itself
	end

	return self 
end

function Server_random_part_spawning_oop_table:Set_properties_of_self() -- the informations in metatable will set to part, simple way
	for Property, Value in pairs(self) do 
		local success, message = pcall(function() -- pcall is function where script will notice error but script will not stop, it will only report u error, good for handling data saving and these, normally message is the error returned
			self.Part[Property] = Value
		end)
	end
end

function Server_random_part_spawning_oop_table:Delete_itself() -- metatable delete itself, and all connections so no memory break:)
	self.OnDeleted:Fire()
	self.OnDeleted:Destroy() -- Destroy deletes all connections and everything from instance, instance:Destroy(), instance:Delete() or instance = nil are not doing the same thing
	self.Part:Destroy()
	local function Remove_connections()
		for index, connection:RBXScriptConnection in pairs(self.Connections) do 
			if typeof(connection) == "RBXScriptConnection" then
				connection:Disconnect()
			end
			if typeof(connection) == "thread" then
				coroutine.yield(connection)
				coroutine.close(connection)
			end
		end
	end
	Remove_connections()
	setmetatable(self, nil)
end

RunService.Stepped:Connect(function() -- this function running because it spawns random parts around all players
	if Can_spawn_part then
		Can_spawn_part = false
		task.delay(Can_spawn_part_cooldown_time, function() -- task delay creates a function what will fire in parallel after time you set
			Can_spawn_part = true
		end)
		Spawn_parts_around_game_players()
	end
end)
