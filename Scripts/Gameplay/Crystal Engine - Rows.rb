#==============================================================================
# Crystal Engine - Rows
#------------------------------------------------------------------------------
# Current Version: 1.03
#==============================================================================
$imported ||= {}
$imported["CE-Rows"] = true
=begin
This script allows you to mimic the row system of the final fantasy series were 
characters in the front take and deal full damage while charcters in the back 
take and deal reduced physical damage
-------------------------------------------------------------------------------
Notetags:
ROW CHANGE NOTETAGS ONLY WORKS ON ACTORS
Actor Notes
<row: x> # Sets the row of the actor to x (1 = front, 2 = back)
Skill Notes
<change front> # Makes the actor move to the front.
<change back> # Makes the actor move to the back.
<change row> # Makes the actor switch rows.
<affected by row> # Factors the row into the damage formula
Item Notes
<change front> # Makes the actor move to the front.
<change back> # Makes the actor move to the back.
<change row> # Makes the actor switch rows.
=end
module CRYSTAL
  module ROWS
    
    #--------------------------------------------------------------------------
    # *  The adjustment factor for Battle Engine Symphony
    #--------------------------------------------------------------------------
    SYMPHONY_ADJUST = ["32 * (@row - 1)", "0"] 
    
    #--------------------------------------------------------------------------
    # * The modifier for the row reduction 
    #--------------------------------------------------------------------------
    ROW_DIVISOR = 2
    
  end
end
#==============================================================================
# Editing beyond this point may cause stone, zombie, mist frenzy, and/or toad,
# so edit at your own risk.
#==============================================================================
#==============================================================================
# ** DataManager
#------------------------------------------------------------------------------
#  This module manages the database and game objects. Almost all of the 
# global variables used by the game are initialized by this module.
#==============================================================================

module DataManager
  #--------------------------------------------------------------------------
  # * Load Database
  #--------------------------------------------------------------------------
  class <<self; alias load_database_ce_rows load_database; end
  def self.load_database
    load_database_ce_rows
    $data_skills.each do |skill|
      next if skill.nil?
      skill.damage.skill_id = skill.id
    end
  end
end
#==============================================================================
# ** RPG::Actor
#------------------------------------------------------------------------------
#  The data class for actors.
#==============================================================================

class RPG::Actor < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Initial Row the Player is in
  #--------------------------------------------------------------------------
  def initial_row
    if @note =~ /<ROW: (\d+)>/i
      return [[$1.to_i, 1].max, 2].min
    else
      return 1
    end
  end
end
#==============================================================================
# ** RPG::UsableItem
#------------------------------------------------------------------------------
#  The Superclass of Skill and Item.
#==============================================================================

class RPG::UsableItem < RPG::BaseItem
  #--------------------------------------------------------------------------
  # * Any row changes
  #--------------------------------------------------------------------------
  def row_change
    if @note =~ /<CHANGE FRONT>/i
      return :front
    elsif @note =~ /<CHANGE BACK>/i
      return :back
    elsif @note =~ /<CHANGE ROW>/i
      return :toggle
    else
      return :none
    end
  end
end
#==============================================================================
# ** RPG::UsableItem::Damage
#------------------------------------------------------------------------------
#  The data class for damage.
#==============================================================================

class RPG::UsableItem::Damage
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :skill_id                 # The skill id for the damage
  #--------------------------------------------------------------------------
  # * Evaluate Damage
  #--------------------------------------------------------------------------
  alias eval_ce_rows_rpg_usableitem_damage eval
  def eval(a, b, v) 
    value = eval_ce_rows_rpg_usableitem_damage(a, b, v)
    if @skill_id
      if $data_skills[@skill_id]
        if $data_skills[@skill_id].affected_by_row?
          if (a.actor? && b.enemy?) | (a.enemy? && b.actor?)
            value /= CRYSTAL::ROWS::ROW_DIVISOR if a.row == 2
            value /= CRYSTAL::ROWS::ROW_DIVISOR if b.row == 2
          end
        end
      end
    end
    value
  end
end
#==============================================================================
# ** RPG::Skill
#------------------------------------------------------------------------------
#  This is the data class for skills.
#==============================================================================

class RPG::Skill < RPG::UsableItem
  #--------------------------------------------------------------------------
  # * Is the skill affected by the user's row
  #--------------------------------------------------------------------------
  def affected_by_row?
    @note =~ /<AFFECTED BY ROW>/i
  end
end
#==============================================================================
# ** Game_Battler
#------------------------------------------------------------------------------
#  A battler class with methods for sprites and actions added. This class 
# is used as a super class of the Game_Actor class and Game_Enemy class.
#==============================================================================

class Game_Battler < Game_BattlerBase
  #--------------------------------------------------------------------------
  # * Apply Effect of Skill/Item
  #--------------------------------------------------------------------------
  alias item_apply_ce_rows item_apply
  def item_apply(user, item)
    item_apply_ce_rows(user, item)
    if @result.hit? && actor?
      case item.row_change
      when :front
        @row = 1
      when :back
        @row = 2
      when :toggle
        @row == 1 ? @row = 2 : @row = 1
      end
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
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :row                      # The Battler's Row
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias ce_rows_init_game_actor initialize
  def initialize(actor_id)
    ce_rows_init_game_actor(actor_id)
    @row = actor.initial_row
  end
  if $imported[:ve_actor_battlers]
    #--------------------------------------------------------------------------
    # * New method: get_frontal_y
    #--------------------------------------------------------------------------
    alias get_frontal_y_ce_rows get_frontal_y
    def get_frontal_y
      get_frontal_y_ce_rows + (32 * (@row - 1))
    end
    #--------------------------------------------------------------------------
    # * New method: get_sideview_x
    #--------------------------------------------------------------------------
    alias get_sideview_x_ce_rows get_sideview_x
    def get_sideview_x
      get_sideview_x_ce_rows + (32 * (@row - 1))
    end
    #--------------------------------------------------------------------------
    # * New method: get_isometric_x
    #--------------------------------------------------------------------------
    alias get_isometric_x_ce_rows get_isometric_x
    def get_isometric_x
      get_isometric_x_ce_rows - (32 * (@row - 1))
    end
    #--------------------------------------------------------------------------
    # * New method: get_isometric_y
    #--------------------------------------------------------------------------
    alias get_isometric_y_ce_rows get_isometric_y
    def get_isometric_y
      get_isometric_y_ce_rows - (32 * (@row - 1))
    end
  end
  if $imported["YES-BattleSymphony"]
    #--------------------------------------------------------------------------
    # new method: set_default_position
    #--------------------------------------------------------------------------
    alias set_default_position_ce_rows set_default_position
    def set_default_position
      set_default_position_ce_rows
      position = CRYSTAL::ROWS::SYMPHONY_ADJUST
      @origin_x = @screen_x = @destination_x = @screen_x + eval(position[0])
      @origin_y = @screen_y = @destination_y = @screen_y + eval(position[1])
    end
  end
end
#==============================================================================
# ** Game_Enemy
#------------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==============================================================================

class Game_Enemy < Game_Battler
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :row                      # The Battler's Row
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  alias ce_rows_init_game_enemy initialize
  def initialize(index, enemy_id)
    ce_rows_init_game_enemy(index, enemy_id)
    @row = 1
  end
end
#==============================================================================
# ** Window_MenuStatus
#------------------------------------------------------------------------------
#  This window displays party member status on the menu screen.
#==============================================================================

class Window_MenuStatus < Window_Selectable
  #--------------------------------------------------------------------------
  # * Draw Actor Face Graphic
  #--------------------------------------------------------------------------
  def draw_actor_face(actor, x, y, enabled = true)
    draw_face(actor.face_name, actor.face_index, x + (actor.row - 1) * 20, y, enabled)
  end
  #--------------------------------------------------------------------------
  # * Swap Rows
  #--------------------------------------------------------------------------
  def swap_rows
    case $game_party.members[index].row
    when 1
      $game_party.members[index].row = 2
    when 2
      $game_party.members[index].row = 1
    end
    refresh
  end
end
#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * [OK] Personal Command
  #--------------------------------------------------------------------------
  alias on_personal_ok_ce_rows on_personal_ok
  def on_personal_ok
    on_personal_ok_ce_rows
    case @command_window.current_symbol
    when :rows
      @status_window.swap_rows
      @status_window.activate
    end
  end
end