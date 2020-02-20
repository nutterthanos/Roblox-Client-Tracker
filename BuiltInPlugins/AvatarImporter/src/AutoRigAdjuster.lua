local RigAdjuster = {}

function RigAdjuster:AdjustRig(char, avatarType)

	local bones = {}
	for _,child in pairs(char:GetDescendants()) do
		if child:IsA("Bone") then
			table.insert(bones, child)
		end
	end
	
	-- Returns first Bone with matching name, S15 canonical Bones must be uniquely named
	local function FindBoneByName(boneName)
		for _,child in pairs(char:GetDescendants()) do
			if child:IsA("Bone") and child.Name==boneName then
				return child
			end
		end
		return nil
	end
	
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local lowerTorso = char:FindFirstChild("LowerTorso")
	local upperTorso = char:FindFirstChild("UpperTorso")
	local rightUpperArmPart = char:FindFirstChild("RightUpperArm")
	local leftUpperArmPart = char:FindFirstChild("LeftUpperArm")
	local rightLowerArmPart = char:FindFirstChild("RightLowerArm")
	local leftLowerArmPart = char:FindFirstChild("LeftLowerArm")
	local rightHandPart = char:FindFirstChild("RightHand")
	local leftHandPart = char:FindFirstChild("LeftHand")
	local rightUpperLegPart = char:FindFirstChild("RightUpperLeg")
	local leftUpperLegPart = char:FindFirstChild("LeftUpperLeg")
	
	-- Shoulder Rig Attachments
	local upperTorsoRightShoulderAtt = upperTorso and upperTorso:FindFirstChild("RightShoulderRigAttachment")
	local upperTorsoLeftShoulderAtt = upperTorso and upperTorso:FindFirstChild("LeftShoulderRigAttachment")
	local rightUpperArmShoulderAtt = rightUpperArmPart and rightUpperArmPart:FindFirstChild("RightShoulderRigAttachment")
	local leftUpperArmShoulderAtt = leftUpperArmPart and leftUpperArmPart:FindFirstChild("LeftShoulderRigAttachment")
	
	-- Elbow Rig Attachments
	local rightUpperArmElbowAtt = rightUpperArmPart and rightUpperArmPart:FindFirstChild("RightElbowRigAttachment")
	local rightLowerArmElbowAtt = rightLowerArmPart and rightLowerArmPart:FindFirstChild("RightElbowRigAttachment")
	local leftUpperArmElbowAtt = leftUpperArmPart and leftUpperArmPart:FindFirstChild("LeftElbowRigAttachment")
	local leftLowerArmElbowAtt = leftLowerArmPart and leftLowerArmPart:FindFirstChild("LeftElbowRigAttachment")
	
	-- Wrist Rig Attachments
	local rightHandWristAtt = rightHandPart and rightHandPart:FindFirstChild("RightWristRigAttachment")
	local rightLowerArmWristAtt = rightLowerArmPart and rightLowerArmPart:FindFirstChild("RightWristRigAttachment")
	local leftHandWristAtt = leftHandPart and leftHandPart:FindFirstChild("LeftWristRigAttachment")
	local leftLowerArmWristAtt = leftLowerArmPart and leftLowerArmPart:FindFirstChild("LeftWristRigAttachment")
	
	local rightShoulderPos = nil
	local leftShoulderPos = nil
	local rightElbowPos = nil
	local leftElbowPos = nil
	local rightWristPos = nil
	local leftWristPos = nil
	
	local upperTorsoBone = FindBoneByName("UpperTorso")
	local rightUpperArmBone = FindBoneByName("RightUpperArm")
	local leftUpperArmBone = FindBoneByName("LeftUpperArm")
	local rightLowerArmBone = FindBoneByName("RightLowerArm")
	local leftLowerArmBone = FindBoneByName("LeftLowerArm")
	local rightHandBone = FindBoneByName("RightHand")
	local leftHandBone = FindBoneByName("LeftHand")
	
	-- Right shoulder joint world location: If neither RightShoulderRigAttachment exists, look for RightUpperArm Bone
	if upperTorsoRightShoulderAtt then
		rightShoulderPos = upperTorsoRightShoulderAtt.WorldPosition
	elseif rightUpperArmShoulderAtt then
		rightShoulderPos = rightUpperArmShoulderAtt.WorldPosition
	elseif rightUpperArmBone then
		rightShoulderPos = rightUpperArmBone.WorldPosition
	end
	
	-- Left Shoulder joint world location
	if upperTorsoLeftShoulderAtt then
		leftShoulderPos = upperTorsoLeftShoulderAtt.WorldPosition
	elseif leftUpperArmShoulderAtt then
		leftShoulderPos = leftUpperArmShoulderAtt.WorldPosition
	elseif leftUpperArmBone then
		leftShoulderPos = leftUpperArmBone.WorldPosition
	end
	
	-- Right Elbow joint world location
	if rightUpperArmElbowAtt then
		rightElbowPos = rightUpperArmElbowAtt.WorldPosition
	elseif rightLowerArmElbowAtt then
		rightElbowPos = rightLowerArmElbowAtt.WorldPosition
	else
		local rightLowerArmBone = FindBoneByName("RightLowerArm")
		if rightLowerArmBone then
			rightElbowPos = rightLowerArmBone.WorldPosition
		end
	end
	
	-- Left Elbow joint world location
	if leftUpperArmElbowAtt then
		leftElbowPos = leftUpperArmElbowAtt.WorldPosition
	elseif leftLowerArmElbowAtt then
		leftElbowPos = leftLowerArmElbowAtt.WorldPosition
	elseif leftLowerArmBone then
		leftElbowPos = leftLowerArmBone.WorldPosition
	
	end
	
	-- Right wrist joint world location
	if rightHandWristAtt then
		rightWristPos = rightHandWristAtt.WorldPosition
	elseif rightLowerArmWristAtt then
		rightWristPos = rightLowerArmWristAtt.WorldPosition
	elseif rightHandBone then
		rightWristPos = rightHandBone.WorldPosition
	
	end
	
	-- Left wrist joint world location
	if leftHandWristAtt then
		leftWristPos = leftHandWristAtt.WorldPosition
	elseif rightLowerArmWristAtt then
		leftWristPos = leftLowerArmWristAtt.WorldPosition
	elseif leftHandBone then
		leftWristPos = leftHandBone.WorldPosition
	end
	
	local charLookVector = hrp and hrp.CFrame.LookVector or Vector3.new(0,0,-1)
	if hrp and rightShoulderPos and leftShoulderPos then
		local rightVector = (rightShoulderPos - leftShoulderPos).Unit
		
		charLookVector = -rightVector:Cross(Vector3.new(0,1,0))
		local dp = charLookVector:Dot(hrp.CFrame.LookVector)
		
		--print("Character LookVector:", charLookVector)
		--print("Character Facing Correct Way:", dp > 0.9961946980917455) -- Constant allows for 5-degree deviation
	end
	
	local rightArmIsTpose = true
	local rightArmDirVector = nil
	if rightShoulderPos and (rightWristPos or rightElbowPos) then
		rightArmDirVector = ((rightWristPos or rightElbowPos) - rightShoulderPos).Unit
		rightArmIsTpose = math.abs(rightArmDirVector.Y) < 0.7071 -- Matches check in C++ as close as possible given float precision difference
		--print("Right Arm Angle from T (deg): ",math.deg(math.atan2(rightArmDirVector.Y,math.abs(rightArmDirVector.X))))
	end
	
	local leftArmIsTpose = true
	local leftArmDirVector = nil
	if leftShoulderPos and (leftWristPos or leftElbowPos) then
		leftArmDirVector = ((leftWristPos or leftElbowPos) - leftShoulderPos).Unit
		leftArmIsTpose = math.abs(leftArmDirVector.Y) < 0.7071 -- Matches check in C++ as close as possible given float precision difference
		--print("Left Arm Angle from T (deg): ",math.deg(math.atan2(leftArmDirVector.Y,math.abs(leftArmDirVector.X))))
	end
	
	
	
	
	--[[
		
		Detecting if adjustment to I-pose has already been done at BuildRigFromAttachments time in C++
		
		If this detects that a correction of 45 degrees or more has been made to the shoulder Motor6D.C1, or that the elbow rig attachments
		are off from identity by more than a 45-degree rotation, which should always be true at the same time, then elbow and wrist
		rig attachments are given 90-degree rotations to bring them to what would be identity orientation if the character were in perfect I pose
		
	--]]
	local rightShoulderMotor = rightUpperArmPart and rightUpperArmPart:FindFirstChild("RightShoulder")
	if rightShoulderMotor and not rightShoulderMotor:IsA("Motor6D") then
		rightShoulderMotor = nil
	end
	
	local leftShoulderMotor = leftUpperArmPart and leftUpperArmPart:FindFirstChild("LeftShoulder")
	if leftShoulderMotor and not leftShoulderMotor:IsA("Motor6D") then
		leftShoulderMotor = nil
	end
	
	if rightShoulderMotor and rightUpperArmShoulderAtt then
		local correction = rightUpperArmShoulderAtt.CFrame * rightShoulderMotor.C1:Inverse()
		local ox, oy, oz = correction:ToOrientation()
		--print("Correction Made to Right Shoulder Motor6D.C1: ",ox,oy,oz)
		if oz < -math.rad(45) then
			rightArmIsTpose = true
		end
	end
	
	if leftShoulderMotor and leftUpperArmShoulderAtt then
		local correction = leftUpperArmShoulderAtt.CFrame * leftShoulderMotor.C1:Inverse()
		local ox, oy, oz = correction:ToOrientation()
		--print("Correction Made to Left Shoulder Motor6D.C1: ",ox,oy,oz)
		if oz > math.rad(45) then
			leftArmIsTpose = true
		end
	end
	
	if rightArmDirVector and rightLowerArmElbowAtt and rightUpperArmElbowAtt then
		local dpLower = rightArmDirVector:Dot(rightLowerArmElbowAtt.WorldCFrame.RightVector)
		local dpUpper = rightArmDirVector:Dot(rightUpperArmElbowAtt.WorldCFrame.RightVector)
		--print("Right Elbow dpLower:",dpLower," dpUpper:",dpUpper)
		
		if dpUpper > 0.7071 then
			rightArmIsTpose = true
		end
	end
	
	if leftArmDirVector and leftLowerArmElbowAtt and leftUpperArmElbowAtt then
		local dpLower = leftArmDirVector:Dot(leftLowerArmElbowAtt.WorldCFrame.RightVector)
		local dpUpper = leftArmDirVector:Dot(leftUpperArmElbowAtt.WorldCFrame.RightVector)
		--print("Left Elbow dpLower:",dpLower," dpUpper:",dpUpper)
		
		if dpUpper < -0.7071 then
			leftArmIsTpose = true
		end
	end
	
	
	
	local isTpose = rightArmIsTpose or leftArmIsTpose  -- Skinned mesh corrections already made are symmetric
	
	print("isTpose:",isTpose)
	
	-- If character is T-posed, elbow and wrist rig Attachments and Bone instances also need joint orientation adjustment
	-- When MeshPart API to get Bones and bind pose matrices is available, that should be used
	-- rather than hoping our T-pose check here matches what the C++ computed
	
	if isTpose then
		-- Right elbow and wrist rig attachments get +90 Z correction from identity
		if rightUpperArmElbowAtt then
			rightUpperArmElbowAtt.Orientation = Vector3.new(0, 0, 90)
		end
		if rightLowerArmElbowAtt then
			rightLowerArmElbowAtt.Orientation = Vector3.new(0, 0, 90)
		end
		if rightLowerArmWristAtt then
			rightLowerArmWristAtt.Orientation = Vector3.new(0, 0, 90)
		end
		if rightHandWristAtt then
			rightHandWristAtt.Orientation = Vector3.new(0, 0, 90)
		end
		
		-- Left elbow and wrist rig attachments get -90 Z correction from identity
		if leftUpperArmElbowAtt then
			leftUpperArmElbowAtt.Orientation = Vector3.new(0, 0, -90)
		end
		if leftLowerArmElbowAtt then
			leftLowerArmElbowAtt.Orientation = Vector3.new(0, 0, -90)
		end
		if leftLowerArmWristAtt then
			leftLowerArmWristAtt.Orientation = Vector3.new(0, 0, -90)
		end
		if leftHandWristAtt then
			leftHandWristAtt.Orientation = Vector3.new(0, 0, -90)
		end
		
		
		-- Corrections to bones depend on whether the bone is parented to a part or another Bone
		
		if leftUpperArmBone then
			leftUpperArmBone.Orientation = Vector3.new(0, 0, -90)
			print("Adjusting leftUpperArmBone")
		end
		
		if rightUpperArmBone then
			rightUpperArmBone.Orientation = Vector3.new(0, 0, 90)
			print("Adjusting rightUpperArmBone")
		end
		
		if leftLowerArmBone then
			if leftUpperArmBone and leftLowerArmBone.Parent == leftUpperArmBone then
				-- LeftLowerArm Bone is parented to LeftUpperArm Bone, in which case it needs offset XY swizzling
				--leftLowerArmBone.Position = Vector3.new( leftLowerArmBone.Position.Y, leftLowerArmBone.Position.X, leftLowerArmBone.Position.Z )
				print("Adjusting leftLowerArmBone")
			else
				-- LeftLowerArm Bone is parented to something else, presumable LeftUpperArm MeshPart, in this case a
				-- rotation correct is required instead
				leftLowerArmBone.Orientation = Vector3.new(0, 0, -90)
				print("Adjusting leftLowerArmBone with Mesh parent")
			end
		end
		
		if leftHandBone then
			if leftLowerArmBone and leftHandBone.Parent == leftLowerArmBone then
				-- LeftHand Bone is parented to LeftLowerArm Bone, in which case it needs offset XY swizzling
				--leftHandBone.Position = Vector3.new( leftHandBone.Position.Y, leftHandBone.Position.X, leftHandBone.Position.Z )
				print("Adjusting leftHandBone")
			else
				-- LeftHand Bone is parented to something else, presumable LeftLowerArm MeshPart, in this case a
				-- rotation correct is required instead
				leftHandBone.Orientation = Vector3.new(0, 0, -90)
				print("Adjusting leftHandBone with Mesh parent")
			end
		end
		
		if rightLowerArmBone then
			if rightUpperArmBone and rightLowerArmBone.Parent == rightUpperArmBone then
				-- RightLowerArm Bone is parented to RightUpperArm Bone, in which case it needs offset XY swizzling
				--rightLowerArmBone.Position = Vector3.new( rightLowerArmBone.Position.Y, -rightLowerArmBone.Position.X, rightLowerArmBone.Position.Z )
				print("Adjusting rightLowerArmBone")
			else
				-- RightLowerArm Bone is parented to something else, presumable RightUpperArm MeshPart, in this case a
				-- rotation correct is required instead
				rightLowerArmBone.Orientation = Vector3.new(0, 0, 90)
				print("Adjusting rightLowerArmBone with Mesh parent")
			end
		end
		
		if rightHandBone then
			if rightLowerArmBone and rightHandBone.Parent == rightLowerArmBone then
				-- RightHand Bone is parented to RightLowerArm Bone, in which case it needs offset XY swizzling
				--rightHandBone.Position = Vector3.new( rightHandBone.Position.Y, -rightHandBone.Position.X, rightHandBone.Position.Z )
				print("Adjusting rightHandBone")
			else
				-- RightHand Bone is parented to something else, presumable RightLowerArm MeshPart, in this case a
				-- rotation correct is required instead
				rightHandBone.Orientation = Vector3.new(0, 0, 90)
				print("Adjusting rightHandBone with Mesh parent")
			end
		end
	end
	
	humanoid:BuildRigFromAttachments()

end

return RigAdjuster
