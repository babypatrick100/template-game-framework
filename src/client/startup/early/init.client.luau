for _, bootstraper in script.bootstrapers:GetChildren() do
	task.spawn(require(bootstraper))
end
