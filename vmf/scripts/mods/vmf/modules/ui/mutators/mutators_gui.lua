local scenegraph_definition = {
	sg_root = {
		is_root = true,
		size = {1920, 1080},
		position = {0, 0, UILayer.default}
  },
  sg_mutators_background = {
		vertical_alignment = "bottom",
		parent = "sg_root",
		horizontal_alignment = "left",
		size = {547, 313},
		position = {-2, -2, 10} -- @TODO: fix the actual image
	},
}

local widgets_definition = {
  static_elements = {
    scenegraph_id = "sg_root",
    element = {
      passes = {
        {
          pass_type = "texture",

          style_id  = "mutators_background",
          texture_id = "mutators_background_texture_id"
        }
      }
    },
    content = {
      mutators_background_texture_id = "map_view_mutators_area",
    },
    style = {
      mutators_background = {
        scenegraph_id = "sg_mutators_background"
      }
    }
  }



}




-----------------------------


local vmf = get_mod("VMF")

local _MUTATORS = vmf.mutators

local _UI_SCENEGRAPH
local _WIDGETS

local _DEFINITIONS

-- temp (will replace with dofile)
_DEFINITIONS = {}
_DEFINITIONS.scenegraph_definition = scenegraph_definition
_DEFINITIONS.widgets_definition    = widgets_definition


-- ####################################################################################################################
-- ##### Local functions ##############################################################################################
-- ####################################################################################################################


local function initialize_mutators_ui(map_view)

  _UI_SCENEGRAPH = UISceneGraph.init_scenegraph(_DEFINITIONS.scenegraph_definition)

  _WIDGETS = {}

  vmf:pcall(function()
  _WIDGETS.static_elements = UIWidget.init(_DEFINITIONS.widgets_definition.static_elements)
  end)

  vmf:echo("AAAA: initialize_mutators_ui")
end

local function draw(map_view, dt)
  local input_service = map_view.input_manager:get_service("map_menu")
  local ui_renderer = map_view.ui_renderer
  local render_settings = map_view.render_settings

  UIRenderer.begin_pass(ui_renderer, _UI_SCENEGRAPH, input_service, dt, nil, render_settings)

  UIRenderer.draw_widget(ui_renderer, _WIDGETS.static_elements)

  UIRenderer.end_pass(ui_renderer)
end

local function update_mutators_ui(map_view, dt)
  draw(map_view, dt)
end

-- ####################################################################################################################
-- ##### Hooks ########################################################################################################
-- ####################################################################################################################

vmf:hook("MapView.init", function (func, self, ingame_ui_context)
  func(self, ingame_ui_context)

  initialize_mutators_ui(self)
end)

vmf:hook("MapView.update", function (func, self, dt, t)
  func(self, dt, t)

	if self.menu_active then
    update_mutators_ui(self, dt)
	end
end)

-- ####################################################################################################################
-- ##### Script #######################################################################################################
-- ####################################################################################################################

local map_view_exists, map_view = pcall(function () return Managers.matchmaking.ingame_ui.views.map_view end)
if map_view_exists then
  vmf:echo("map_view_exists!!!!!!!!!!!")
  initialize_mutators_ui(map_view)
end