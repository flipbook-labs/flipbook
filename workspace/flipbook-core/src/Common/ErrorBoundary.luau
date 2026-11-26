local React = require("@pkg/React")

export type Props = {
	fallback: (problem: string, reset: () -> ()) -> React.Node,
	resetKey: unknown?,
	children: React.Node?,
}

type State = {
	problem: string?,
}

local ErrorBoundary = React.Component:extend("ErrorBoundary")

function ErrorBoundary:init()
	self.state = {
		problem = nil,
	} :: State

	self.reset = function()
		self:setState({
			problem = React.None,
		})
	end
end

function ErrorBoundary.getDerivedStateFromError(err: unknown): State
	return {
		problem = tostring(err),
	}
end

function ErrorBoundary:componentDidUpdate(previousProps: Props)
	local props: Props = self.props
	local state: State = self.state
	if state.problem ~= nil and props.resetKey ~= previousProps.resetKey then
		self.reset()
	end
end

function ErrorBoundary:render(): React.Node
	local props: Props = self.props
	local state: State = self.state
	if state.problem ~= nil then
		return props.fallback(state.problem, self.reset)
	end

	return props.children
end

return ErrorBoundary
