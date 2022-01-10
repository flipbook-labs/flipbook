local Llama = require(script.Parent.Parent.Packages.Llama)
local Roact = require(script.Parent.Parent.Packages.Roact)
local styles = require(script.Parent.Parent.styles)
local Panel = require(script.Parent.Panel)

return {
	roact = Roact,
	story = Roact.createElement("Frame", {
		Size = UDim2.fromScale(0.5, 1),
		BackgroundTransparency = 1,
	}, {
		Panel = Roact.createElement(Panel, {}, {
			Layout = Roact.createElement("UIListLayout", {
				SortOrder = Enum.SortOrder.LayoutOrder,
				Padding = UDim.new(0, 16),
			}),

			Par1 = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					TextWrapped = true,
					Text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Amet facilisis magna etiam tempor orci. Dictum varius duis at consectetur lorem. Diam vel quam elementum pulvinar etiam. Massa ultricies mi quis hendrerit dolor magna eget est. Enim praesent elementum facilisis leo. Velit euismod in pellentesque massa placerat duis ultricies lacus sed. Nisl rhoncus mattis rhoncus urna neque. Viverra ipsum nunc aliquet bibendum enim facilisis. Est ullamcorper eget nulla facilisi etiam dignissim diam. Lacus viverra vitae congue eu consequat ac. Vitae auctor eu augue ut lectus arcu. Massa vitae tortor condimentum lacinia quis vel. Enim nulla aliquet porttitor lacus luctus accumsan tortor posuere ac. Neque gravida in fermentum et sollicitudin. Arcu dui vivamus arcu felis bibendum ut tristique. Erat pellentesque adipiscing commodo elit at imperdiet dui. Convallis aenean et tortor at risus viverra adipiscing at in. Amet tellus cras adipiscing enim eu turpis egestas. Eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque.",
				})
			),

			Par2 = Roact.createElement(
				"TextLabel",
				Llama.Dictionary.join(styles.TextLabel, {
					TextWrapped = true,
					Text = "Condimentum id venenatis a condimentum vitae. Pulvinar elementum integer enim neque volutpat ac. Dolor sit amet consectetur adipiscing elit pellentesque habitant morbi tristique. Pretium fusce id velit ut. Ornare arcu dui vivamus arcu felis bibendum ut. Tellus pellentesque eu tincidunt tortor aliquam nulla facilisi cras. Ornare quam viverra orci sagittis eu volutpat odio. Nisl vel pretium lectus quam id leo in vitae turpis. Urna porttitor rhoncus dolor purus non enim praesent. Metus dictum at tempor commodo ullamcorper a lacus vestibulum. Faucibus nisl tincidunt eget nullam non. Praesent elementum facilisis leo vel fringilla est ullamcorper. Imperdiet dui accumsan sit amet nulla. Porttitor leo a diam sollicitudin. Viverra adipiscing at in tellus integer feugiat. Placerat vestibulum lectus mauris ultrices eros. Non quam lacus suspendisse faucibus interdum posuere lorem ipsum.",
				})
			),
		}),
	}),
}
