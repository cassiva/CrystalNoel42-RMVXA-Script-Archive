#==============================================================================
# * Crystal Engine -  Basic Module
#------------------------------------------------------------------------------
# Current Version: 1.17
#==============================================================================
$imported = {} if $imported.nil?
$imported["CE-BasicModule"] = true
=begin
this is a basic moule of some funtions in the final fantasy series that are
farily important as well as some fixes from the defualt that needed to be fixed

please place any other scripts that alter the diplay of HP and MP bars above 
this script

the current_time method has been added for using real time funtions

Your can use the control code \script[string] to display script data in the
messagebox
=end
module CRYSTAL
  module BASIC
    
    TITLE_WIDTH = 160 #allows for a wider title command window default 160
    
    #--------------------------------------------------------------------------
    # the next settings are to remove hp gauges from the battle and menu
    # this also allows for maximum values to be shown
    #--------------------------------------------------------------------------
    MENU_HP_BAR = true
    MENU_HP_MAX = true
    MENU_MP_BAR = true
    MENU_MP_MAX = true
    BATTLE_HP_BAR = true
    BATTLE_HP_MAX = true
    BATTLE_MP_BAR = true
    BATTLE_MP_MAX = true
    
    REMOVE_MP_DISPLAY = false #get rid of the MP bar completely
    
    MOVE_CLASS_NAME_OVER = 0 #move the class name over x many pixles
    
    MOVE_NAME_VERTICAL = 0 #move the actor name up x many pixels
    
    #--------------------------------------------------------------------------
    # If you want to group digits i.e. 1000 becomes 1,000
    #--------------------------------------------------------------------------
    GROUP_DIGITS = true
  end
end
#==============================================================================
# Editing beyond this point may cause stone, zombie, mist frenzy, and/or toad,
# so edit at your own risk.
#==============================================================================
module CRYSTAL
  module CHECK
    #--------------------------------------------------------------------------
    # * Script Name Guide
    #--------------------------------------------------------------------------
    def self.scripts_list(name)
    end
  end
end
#==============================================================================
# ** Numeric
#==============================================================================

class Numeric  
  
  #--------------------------------------------------------------------------
  # new method: group_digits
  #--------------------------------------------------------------------------
  def group
    return self.to_s unless CRYSTAL::BASIC::GROUP_DIGITS
    self.to_s.gsub(/(\d)(?=\d{3}+(?:\.|$))(\d{3}\..*)?/,'\1,\2')
  end
  
end # Numeric
#==============================================================================
# ** SceneManager
#------------------------------------------------------------------------------
#  This module manages scene transitions. For example, it can handle
# hierarchical structures such as calling the item screen from the main menu
# or returning from the item screen to the main menu.
#==============================================================================

module SceneManager
  #--------------------------------------------------------------------------
  # * Direct Transition
  #--------------------------------------------------------------------------
  def self.goto(scene_class, *arguments)
    @scene = scene_class.new(*arguments)
  end
  #--------------------------------------------------------------------------
  # * Call
  #--------------------------------------------------------------------------
  def self.call(scene_class, *arguments)
    @stack.push(@scene)
    @scene = scene_class.new(*arguments)
  end
end
#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Extract Save Contents
  #--------------------------------------------------------------------------
  class <<self; alias ce_basic_extract_save_contents extract_save_contents; end
  def self.extract_save_contents(contents)
    ce_basic_extract_save_contents(contents)
    load_extra_data
  end
  #--------------------------------------------------------------------------
  # * Load Extra Data
  #--------------------------------------------------------------------------
  def self.load_extra_data
    $data_actors += $game_party.extra_data[:actors]
    $data_classes += $game_party.extra_data[:classes]
    $data_skills += $game_party.extra_data[:skills]
    $data_items += $game_party.extra_data[:items]
    $data_weapons += $game_party.extra_data[:weapons]
    $data_armors += $game_party.extra_data[:armors]
    $data_enemies += $game_party.extra_data[:enemies]
    $data_troops += $game_party.extra_data[:troops]
    $data_states += $game_party.extra_data[:states]
    $data_animations += $game_party.extra_data[:animations]
    $data_tilesets += $game_party.extra_data[:tilesets]
    $data_common_events += $game_party.extra_data[:common_events]
  end
end
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Get Added Skill Types
  #--------------------------------------------------------------------------
  alias added_skill_types_ce_basic_module added_skill_types
  def added_skill_types
    added_skill_types_ce_basic_module.sort
  end
end
#==============================================================================
# ** Game_Party
#------------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :extra_data         # The database
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias ce_basic_init initialize
  def initialize
    ce_basic_init
    @extra_data = {
      :actors        => [],
      :classes       => [],
      :skills        => [],
      :items         => [],
      :weapons       => [],
      :armors        => [],
      :enemies       => [],
      :troops        => [],
      :states        => [],
      :animations    => [],
      :tilesets      => [],
      :common_events => [],
      :system        => {},
      :mapinfos      => {}
    }
    unless $BTEST
      $data_mapinfos.each do |key, info|
        @extra_data[:mapinfos][key] = {}
      end
    end
  end
end
#==============================================================================
# ** Window_TitleCommand
#------------------------------------------------------------------------------
#  This window is for selecting New Game/Continue on the title screen.
#==============================================================================

class Window_TitleCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return CRYSTAL::BASIC::TITLE_WIDTH
  end
end
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  alias crystal_draw_hp draw_actor_hp
  def draw_actor_hp(actor, x, y, width = 124)
    if CRYSTAL::BASIC::MENU_HP_BAR
      crystal_draw_hp(actor, x, y, width)
    else
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::hp_a)
      crystal_current_and_max_hp(x, y, width, actor.hp, actor.mhp,
        hp_color(actor), normal_color)
    end
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #--------------------------------------------------------------------------
  alias crystal_draw_mp draw_actor_mp
  def draw_actor_mp(actor, x, y, width = 124)
    if CRYSTAL::BASIC::MENU_MP_BAR
      crystal_draw_mp(actor, x, y, width)
    else
      change_color(system_color)
      draw_text(x, y, 30, line_height, Vocab::mp_a)
      crystal_current_and_max_mp(x, y, width, actor.mp, actor.mmp,
        mp_color(actor), normal_color)
    end
  end
  #---------------------------------------------------------------------------
  # controled current and max value
  #---------------------------------------------------------------------------
  def crystal_current_and_max_hp(dx, dy, dw, current, max, color1, color2)
    if CRYSTAL::BASIC::MENU_HP_MAX
      total = current.group + "/" + max.group
      if dw < text_size(total).width + text_size(Vocab.hp).width
        change_color(color1)
        draw_text(dx, dy, dw, line_height, current.group, 2)
      else
        xr = dx + text_size(Vocab.hp).width
        dw -= text_size(Vocab.hp).width
        change_color(color2)
        text = "/" + max.group
        draw_text(xr, dy, dw, line_height, text, 2)
        dw -= text_size(text).width
        change_color(color1)
        draw_text(xr, dy, dw, line_height, current.group, 2)
      end
    else
      draw_text(dx, dy, dw, line_height, current.group, 2)
    end
  end
  
  def crystal_current_and_max_mp(dx, dy, dw, current, max, color1, color2)
    if CRYSTAL::BASIC::MENU_MP_MAX
      total = current.group + "/" + max.group
      if dw < text_size(total).width + text_size(Vocab.hp).width
        change_color(color1)
        draw_text(dx, dy, dw, line_height, current.group, 2)
      else
        xr = dx + text_size(Vocab.hp).width
        dw -= text_size(Vocab.hp).width
        change_color(color2)
        text = "/" + max.group
        draw_text(xr, dy, dw, line_height, text, 2)
        dw -= text_size(text).width
        change_color(color1)
        draw_text(xr, dy, dw, line_height, current.group, 2)
      end
    else
      draw_text(dx, dy, dw, line_height, current.group, 2)
    end
  end
  #--------------------------------------------------------------------------
  # alias method: draw_actor_class
  #--------------------------------------------------------------------------
  alias draw_actor_class_ce draw_actor_class
  def draw_actor_class(actor, x, y, width = 112)
    draw_actor_class_ce(actor, x + CRYSTAL::BASIC::MOVE_CLASS_NAME_OVER, y, width)
  end
  #--------------------------------------------------------------------------
  # * Draw Name
  #--------------------------------------------------------------------------
  alias crystal_draw_name draw_actor_name
  def draw_actor_name(actor, x, y, width = 112)
    crystal_draw_name(actor, x, y + CRYSTAL::BASIC::MOVE_NAME_VERTICAL, width)
  end
  if $imported["YEA-AceMenuEngine"]
  #--------------------------------------------------------------------------
  # overwrite method: draw_actor_simple_status
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, dx, dy)
    dy -= line_height / 2
    draw_actor_name(actor, dx, dy)
    draw_actor_level(actor, dx, dy + line_height * 1)
    draw_actor_icons(actor, dx, dy + line_height * 2)
    dw = contents.width - dx - 124
    draw_actor_class(actor, dx + 120, dy, dw)
    draw_actor_hp(actor, dx + 120, dy + line_height * 1, dw)
    if YEA::MENU::DRAW_TP_GAUGE && actor.draw_tp? && !actor.draw_mp?
      draw_actor_tp(actor, dx + 120, dy + line_height * 2, dw)
    elsif YEA::MENU::DRAW_TP_GAUGE && actor.draw_tp? && actor.draw_mp?
      if $imported["YEA-BattleEngine"]
        draw_actor_tp(actor, dx + 120, dy + line_height * 2, dw/2 + 1)
        draw_actor_mp(actor, dx + 120 + dw/2, dy + line_height * 2, dw/2) unless CRYSTAL::BASIC::REMOVE_MP_DISPLAY
      else
        draw_actor_mp(actor, dx + 120, dy + line_height * 2, dw/2 + 1) unless CRYSTAL::BASIC::REMOVE_MP_DISPLAY
        draw_actor_tp(actor, dx + 120 + dw/2, dy + line_height * 2, dw/2)
      end
    else
      draw_actor_mp(actor, dx + 120, dy + line_height * 2, dw) unless CRYSTAL::BASIC::REMOVE_MP_DISPLAY
    end
  end
  else
  #--------------------------------------------------------------------------
  # * Draw Simple Status
  #--------------------------------------------------------------------------
  def draw_actor_simple_status(actor, x, y)
    draw_actor_name(actor, x, y)
    draw_actor_level(actor, x, y + line_height * 1)
    draw_actor_icons(actor, x, y + line_height * 2)
    draw_actor_class(actor, x + 120, y)
    draw_actor_hp(actor, x + 120, y + line_height * 1)
    draw_actor_mp(actor, x + 120, y + line_height * 2) unless CRYSTAL::BASIC::REMOVE_MP_DISPLAY
  end
  end
  #--------------------------------------------------------------------------
  # * Draw Icon
  #     enabled : Enabled flag. When false, draw semi-transparently.
  #--------------------------------------------------------------------------
  alias draw_icon_ce_basic_module draw_icon
  def draw_icon(icon_index, x, y, enabled = true)
    draw_icon_ce_basic_module(icon_index, x + ((line_height - 24) / 2), y, enabled)
  end
  #--------------------------------------------------------------------------
	# * Preconvert Control Characters
	#    As a rule, replace only what will be changed into text strings before
	#    starting actual drawing. The character "\" is replaced with the escape
	#    character (\e).
	#--------------------------------------------------------------------------
	alias ce_convert_escape_characters_basic convert_escape_characters
	def convert_escape_characters(text)
		result = ce_convert_escape_characters_basic(text) # Run Original Method
		result.gsub!(/\eSCRIPT\[(\w+)\]/i) { eval($1).to_s rescue "" }
		result # Return result
	end
end
#==============================================================================
# ** Window_BattleStatus
#------------------------------------------------------------------------------
#  This window is for displaying the status of party members on the battle
# screen.
#==============================================================================

class Window_BattleStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Draw HP
  #--------------------------------------------------------------------------
  alias crystal_draw_hp draw_actor_hp
  def draw_actor_hp(actor, x, y, width = 124)
    if CRYSTAL::BASIC::BATTLE_HP_BAR
      draw_gauge(x, y, width, actor.hp_rate, hp_gauge_color1, hp_gauge_color2)
    end
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::hp_a)
    crystal_current_and_max_hp(x, y, width, actor.hp, actor.mhp,
      hp_color(actor), normal_color)
  end
  #--------------------------------------------------------------------------
  # * Draw MP
  #--------------------------------------------------------------------------
  alias crystal_draw_mp draw_actor_mp
  def draw_actor_mp(actor, x, y, width = 124)
    if CRYSTAL::BASIC::BATTLE_MP_BAR
      draw_gauge(x, y, width, actor.mp_rate, mp_gauge_color1, mp_gauge_color2)
    end
    change_color(system_color)
    draw_text(x, y, 30, line_height, Vocab::mp_a)
    crystal_current_and_max_mp(x, y, width, actor.mp, actor.mmp,
      mp_color(actor), normal_color)
  end
  #---------------------------------------------------------------------------
  # controled current and max value
  #---------------------------------------------------------------------------
  def crystal_current_and_max_hp(dx, dy, dw, current, max, color1, color2)
    if CRYSTAL::BASIC::BATTLE_HP_MAX
      total = current.group + "/" + max.group
      if dw < text_size(total).width + text_size(Vocab.hp).width
        change_color(color1)
        draw_text(dx, dy, dw, line_height, current.group, 2)
      else
        xr = dx + text_size(Vocab.hp).width
        dw -= text_size(Vocab.hp).width
        change_color(color2)
        text = "/" + max.group
        draw_text(xr, dy, dw, line_height, text, 2)
        dw -= text_size(text).width
        change_color(color1)
        draw_text(xr, dy, dw, line_height, current.group, 2)
      end
    else
      draw_text(dx, dy, dw, line_height, current.group, 2)
    end
  end
  
  def crystal_current_and_max_mp(dx, dy, dw, current, max, color1, color2)
    if CRYSTAL::BASIC::BATTLE_MP_MAX
      total = current.group + "/" + max.group
      if dw < text_size(total).width + text_size(Vocab.hp).width
        change_color(color1)
        draw_text(dx, dy, dw, line_height, current.group, 2)
      else
        xr = dx + text_size(Vocab.hp).width
        dw -= text_size(Vocab.hp).width
        change_color(color2)
        text = "/" + max.group
        draw_text(xr, dy, dw, line_height, text, 2)
        dw -= text_size(text).width
        change_color(color1)
        draw_text(xr, dy, dw, line_height, current.group, 2)
      end
    else
      draw_text(dx, dy, dw, line_height, current.group, 2)
    end
  end
end
#==============================================================================
# ** Game_Actor
#------------------------------------------------------------------------------
#  This class handles actors. It is used within the Game_Actors class
# ($game_actors) and is also referenced from the Game_Party class ($game_party).
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias crystal_basic_init initialize
  def initialize(actor_id)
    crystal_basic_init(actor_id)
    refresh
  end
end
#==============================================================================
# ** Game_Message
#------------------------------------------------------------------------------
#  This class handles the state of the message window that displays text or
# selections, etc. The instance of this class is referenced by $game_message.
#==============================================================================

class Game_Message
  #--------------------------------------------------------------------------
  # * Add Text
  #--------------------------------------------------------------------------
  alias ce_basic_add_text add
  def add(text)
    return unless text.is_a?(String)
    return if text.empty?
    ce_basic_add_text(text)
  end
end
#==============================================================================
# ** Object
#------------------------------------------------------------------------------
#  This class is the superclass of all other classes.
#==============================================================================

class Object
  #----------------------------------------------------------------------------
  # * Time
  #----------------------------------------------------------------------------
  def current_time
    Time.now 
  end
end
#==============================================================================
# ** Scene_Base
#------------------------------------------------------------------------------
#  This is a super class of all scenes within the game.
#==============================================================================

class Scene_Base
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :message_window     # The message window
  #--------------------------------------------------------------------------
  # * Start Processing
  #--------------------------------------------------------------------------
  alias always_present_start start
  def start
    always_present_start
    @message_window = Window_Message.new unless SceneManager.scene_is?(Scene_Title)
  end
end
#==============================================================================
# ** Window_HorzCommand
#------------------------------------------------------------------------------
#  This is a command window for the horizontal selection format.
#==============================================================================

class Window_HorzCommand < Window_Command
  #--------------------------------------------------------------------------
  # * Set Leading Digits - BUGFIX Credit to Fomar0153
  #--------------------------------------------------------------------------
  def top_col=(col)
    col = 0 if col < 0     
    col = item_max - (col_max - 1) if col > item_max - 1
    self.ox = col * (item_width + spacing)
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Right
  #--------------------------------------------------------------------------
  def cursor_right(wrap = false)
    if index < item_max - 1 || (wrap && horizontal?)
      select((index + 1) % item_max)
    end
  end
  #--------------------------------------------------------------------------
  # * Move Cursor Left
  #--------------------------------------------------------------------------
  def cursor_left(wrap = false)
    if index > 0 || (wrap && horizontal?)
      select((index - 1 + item_max) % item_max)
    end
  end
end
#==============================================================================
# ** Sprite_Battler
#------------------------------------------------------------------------------
#  This sprite is used to display battlers. It observes an instance of the
# Game_Battler class and automatically changes sprite states.
#==============================================================================

class Sprite_Battler < Sprite_Base
  #--------------------------------------------------------------------------
  # * Frame Update
  #--------------------------------------------------------------------------
  alias update_ce_basic update
  def update
    update_ce_basic
    @battler_visibler = false if @battler && @battler.dead?
  end
end
#==============================================================================
# ** Scene_Battle
#------------------------------------------------------------------------------
#  This class performs battle screen processing.
#==============================================================================

class Scene_Battle < Scene_Base
  #--------------------------------------------------------------------------
	# * Refresh Spriteset
	#--------------------------------------------------------------------------
	def refresh_spriteset
    @spriteset.refresh_battlers
	end
end
#==============================================================================
# ** Spriteset_Battle
#------------------------------------------------------------------------------
#  This class brings together battle screen sprites. It's used within the
# Scene_Battle class.
#==============================================================================

class Spriteset_Battle
  #--------------------------------------------------------------------------
	# * Refresh Battlers
	#--------------------------------------------------------------------------
	def refresh_battlers
    $game_troop.alive_members.each do |member, i|
      next if @enemy_sprites.any? {|sprite| sprite.battler == member }
      sprite = Sprite_Battler.new(@viewport1, member)
      sprite.battler_visible = member.alive?
      sprite.update
      @enemy_sprites.push(sprite)
    end
    update_actors
    @actor_sprites.each {|sprite| sprite.visible = true }
  end
end