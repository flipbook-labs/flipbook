local Foundation = require("@rbxpkg/Foundation")
local React = require("@pkg/React")

local Group = require("@root/Group")
local Panel = require("@root/Panel")

local Root = require("./Root")

return {
	story = function()
		return React.createElement(Foundation.ScrollView, {
			tag = "size-full col gap-large padding-medium",
			scroll = {
				CanvasSize = UDim2.fromScale(1, 0),
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				ScrollingDirection = Enum.ScrollingDirection.Y,
			},
			layout = {
				FillDirection = Enum.FillDirection.Vertical,
			},
		}, {
			FlipbookLayout = React.createElement(Foundation.View, {
				tag = "size-full-0 auto-y col gap-medium",
				LayoutOrder = 1,
			}, {
				Label = React.createElement(Foundation.Text, {
					tag = "auto-xy text-heading-small content-emphasis",
					Text = "Flipbook Layout",
					LayoutOrder = 1,
				}),

				Story = React.createElement(Root, {
					fillDirection = Enum.FillDirection.Horizontal,
					LayoutOrder = 1,
				}, {
					Sidebar = React.createElement(Group, {
						LayoutOrder = 1,
					}, {
						Explorer = React.createElement(Panel, {
							LayoutOrder = 1,
						}, {
							Searchbar = React.createElement(Foundation.SearchInput, {
								size = Foundation.Enums.InputSize.Small,
								width = UDim.new(0, 200),
								text = "",
								shape = Foundation.Enums.SearchInputShape.Rounded,
								onChanged = function() end,
							}),
						}),
					}),

					Primary = React.createElement(Group, {
						LayoutOrder = 2,
					}, {
						Topbar = React.createElement(Panel, {
							LayoutOrder = 1,
						}, {
							Icon = React.createElement(Foundation.Icon, {
								name = Foundation.Enums.IconName.Tilt,
							}),
						}),

						StoryViewport = React.createElement(Panel, {
							LayoutOrder = 2,
						}, {
							Icon = React.createElement(Foundation.Icon, {
								name = Foundation.Enums.IconName.BookOpen,
							}),
						}),

						StoryControls = React.createElement(Panel, {
							LayoutOrder = 3,
						}, {
							Icon = React.createElement(Foundation.Icon, {
								name = Foundation.Enums.IconName.Gear,
							}),
						}),
					}),

					Logs = React.createElement(Panel, {
						LayoutOrder = 3,
					}, {
						Title = React.createElement(Foundation.Text, {
							tag = "auto-xy text-wrap text-align-x-left text-align-y-top text-heading-medium content-emphasis",
							LayoutOrder = 1,
							Text = "Logs",
						}),

						Text = React.createElement(Foundation.Text, {
							tag = "auto-xy text-wrap text-align-x-left text-align-y-top text-body-medium content-default",
							LayoutOrder = 2,
							Text = ("Line\n"):rep(40),
						}),
					}),
				}),
			}),

			-- HorizontalThreePanels = labeled(
			-- 	"Horizontal Three Panels",
			-- 	React.createElement(Root, {
			-- 		fillDirection = Enum.FillDirection.Horizontal,
			-- 		LayoutOrder = 2,
			-- 	}, {
			-- 		Left = React.createElement(Panel, {
			-- 			LayoutOrder = 1,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Left",
			-- 			}),
			-- 		}),

			-- 		Center = React.createElement(Panel, {
			-- 			LayoutOrder = 2,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Center",
			-- 			}),
			-- 		}),

			-- 		Right = React.createElement(Panel, {
			-- 			LayoutOrder = 3,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Right",
			-- 			}),
			-- 		}),
			-- 	})
			-- ),

			-- ConstrainedPanels = labeled(
			-- 	"Constrained Panels (Center: min 200px, max 400px)",
			-- 	React.createElement(Root, {
			-- 		fillDirection = Enum.FillDirection.Horizontal,
			-- 		LayoutOrder = 3,
			-- 	}, {
			-- 		Left = React.createElement(Panel, {
			-- 			LayoutOrder = 1,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Left (unconstrained)",
			-- 			}),
			-- 		}),

			-- 		Center = React.createElement(Panel, {
			-- 			LayoutOrder = 2,
			-- 			minSize = Vector2.new(200, 100),
			-- 			maxSize = Vector2.new(400, math.huge),
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Center (min 200px, max 400px)",
			-- 			}),
			-- 		}),

			-- 		Right = React.createElement(Panel, {
			-- 			LayoutOrder = 3,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Right (unconstrained)",
			-- 			}),
			-- 		}),
			-- 	})
			-- ),

			-- NestedGroupIsolation = labeled(
			-- 	"Nested Group Isolation",
			-- 	React.createElement(Root, {
			-- 		fillDirection = Enum.FillDirection.Horizontal,
			-- 		LayoutOrder = 4,
			-- 	}, {
			-- 		OuterA = React.createElement(Panel, {
			-- 			LayoutOrder = 1,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Outer A",
			-- 			}),
			-- 		}),

			-- 		Inner = React.createElement(Group, {
			-- 			LayoutOrder = 2,
			-- 			fillDirection = Enum.FillDirection.Vertical,
			-- 		}, {
			-- 			Top = React.createElement(Panel, {
			-- 				LayoutOrder = 1,
			-- 			}, {
			-- 				Label = React.createElement(Foundation.Text, {
			-- 					tag = "auto-xy text-body-medium content-default",
			-- 					Text = "Inner Top",
			-- 				}),
			-- 			}),

			-- 			Bottom = React.createElement(Panel, {
			-- 				LayoutOrder = 2,
			-- 			}, {
			-- 				Label = React.createElement(Foundation.Text, {
			-- 					tag = "auto-xy text-body-medium content-default",
			-- 					Text = "Inner Bottom",
			-- 				}),
			-- 			}),
			-- 		}),

			-- 		OuterB = React.createElement(Panel, {
			-- 			LayoutOrder = 3,
			-- 		}, {
			-- 			Label = React.createElement(Foundation.Text, {
			-- 				tag = "auto-xy text-body-medium content-default",
			-- 				Text = "Outer B",
			-- 			}),
			-- 		}),
			-- 	})
			-- ),
		})
	end,
}
