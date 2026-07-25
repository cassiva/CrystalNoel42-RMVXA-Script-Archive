#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#===============================================================================
#                      ◆ Gambit System ver2.01 ◆ VX Ace ◆
#										by Ｏｚ
#							(http://fsmoz.blog.fc2.com/)
#                       	translated by CrystalNoel42
#						(https://crystalnoel42.wordpress.com)
#							instructions by okedokemoose
#------------------------------------------------------------------------------                                                    
# Based on the Gambit System from FF12.
#
# Gambits are Items (database tab) with a notetag, the script will treat
# The notetagged Item is a Gambit and it will not appear in the inventory, but
# you must give them to the player as if an item.
#
#
# Additional information is detailed below.
#===============================================================================
# ★ Notetags ★
#===============================================================================
#  All notetags are placed inside Items in the Database.
#
# ★ Add Slot ★
# [add gambit slot] : adds another Gambit slot
#
# ★ Gambit Template ★
# Don't include the brackets around [insert here].
#
# [gambit]
# condition = [insert here] # Conditions are illustrated below
# targets = [insert here] # Party or Troop
# backcolor = [insert here] # Defined below in GamBit_BackColors
# [/gambit]
#
# ★ Gambit Examples ★
# >>> Enemy with lowest HP
# [gambit]
# condition = hp_lowest_enemy
# backcolor = 0
# [/gambit]
#
# >>> Ally has State #8 applied
# [gambit]
# condition = specific_state_target ([8] : party)
# backcolor = 1
# targets   = party
# [/gambit]
#
# >>> The Actor itself has State #4 applied
# [gambit]
# condition = self_add_states (myself, [4])
# backcolor = 2
# targets   = party
# [/gambit]
#
#===============================================================================

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

$imported = {} if $imported == nil
$imported["GamBit"] = true

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ★ Customization ★
#==============================================================================

module GamBit
  # Action: Database ID of the skill to be used when 'Wait' is picked.
  Nothing_Skill_ID = 7
  # Action: Database ID of the skill to be used when 'Escape' is picked.
  Escape_Skill_ID = 6
  
  # Initial gambit slot
  GamBit_Slot = 5
  # Maximum gambits slots
  GamBit_MaxSlot = 12
  
  # System Windowskin color for the ON/OFF text
  #ON
  Switch_ON = 14
  #OFF
  Switch_OFF = 7
  
  # Gambit background color when ON. Order starts at 0.
  GamBit_BackColors = [
    [232, 153, 149, 192], [100, 213, 127, 192], [98, 100, 152, 192],
    [127, 116, 120, 127]
  ]
  #GamBit_BackColors background color when selected from Gambit OFF
  GamBit_OFF_BackColor = 3  #[127, 116, 120, 174]
  #SE Gambit switching ON / OFF  
  Switch_SE = "Switch1"
  #Item name to add to the menu
  Menu_GamBit = "Gambits"
  #Screen cursor setting Gambit
  GamBit_Cursor = "Cursor"
  #Cursor animation
  GamBit_Cursor_Animation = 3
  #Animation speed (fps)
  GamBit_Cursor_Speed = 25
  
#==============================================================================
# ★ Conditions ★
# Write the statement after self. into the conditions section of the notetag.
# Look at the Operator Expressions section of the Help Manual (F1) of RMVXA.
#==============================================================================
  # Targets the enemy with the lowest HP
  def self.hp_lowest_enemy
    result = {}
    targets = []
    targets = $game_troop.alive_members.sort{|a, b| a.hp <=> b.hp}
    result["condition"] = (targets.size > 0)
    result["target"] = targets.first
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # Targets the enemy with the highest HP
  def self.hp_highest_enemy
    result = {}
    targets = []
    targets = $game_troop.alive_members.sort{|a, b| a.hp <=> b.hp}
    result["condition"] = (targets.size > 0)
    result["target"] = targets.last
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # The target has the state inficted
  #type Specify the target
  #   :party => Your party
  #   :troop => The enemies
  def self.specific_state_target(states, type)
    unit = targets_unit(type)
    result = {}
    targets = []
    for member in unit.alive_members
      targets.push(member) if member.states.any?{|state| states.include?(state.id) }
    end
    result["condition"] = (targets.size > 0)
    result["target"] = targets.size > 0 ? targets[rand(targets.size)] : nil
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # The HP is under the specified amount
  def self.hp_under_target(hp, type)
    unit = targets_unit(type)
    result = {}
    targets = []
    for member in unit.alive_members
      targets << member unless member.hp > hp
    end
    result["condition"] = (targets.size > 0)
    result["target"] = targets.size > 0 ? targets[rand(targets.size)] : nil
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # The MP is under the specified amount
  def self.mp_under_targets(mp, type)
    unit = targets_unit(type)
    result = {}
    targets = []
    for member in unit.alive_members
      targets << member unless member.mp > mp
    end
    result["condition"] = (targets.size > 0)
    result["target"] = targets.size > 0 ? targets[rand(targets.size)] : nil
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # Targets the enemy with the lowest Max HP
  def self.maxhp_lowest_enemy
    result = {}
    targets = []
    targets = $game_troop.alive_members.sort{|a, b| a.maxhp <=> b.maxhp}
    result["condition"] = (targets.size > 0)
    result["target"] = targets.last
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # Targets the enemy with the lowest Max MP
  def self.maxmp_lowest_enemy
    result = {}
    targets = []
    targets = $game_troop.alive_members.sort{|a, b| a.maxmp <=> b.maxmp}
    result["condition"] = (targets.size > 0)
    result["target"] = targets.last
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # If the enemy is weak to the element (element rate is higher than 100%)
  def self.weak_element_enemy(element)
    result = {}
    targets = []
    for enemy in $game_troop.alive_members
      targets << enemy if enemy.element_rate(element) > 1.0
    end
    result["condition"] = (targets.size > 0)
    result["target"] = targets.size > 0 ? targets[rand(targets.size)] : nil
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # If the enemy is weak to the state (state rate is higher than 100%)
  def self.weak_state_enemy(state)
    result = {}
    targets = []
    for member in $game_troop.alive_members
      targets << member if member.state_rate(state) > 1.0
    end
    result["condition"] = (targets.size > 0)
    result["target"] = targets.size > 0 ? targets[rand(targets.size)] : nil
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#  
  # When someone on your party is inflicted with the state
  def self.self_add_states(battler, states)
    result = {}
    result["condition"] = battler.states.any?{|state| states.include?(state.id)}
    result["target"] = battler
    return result
  end
#//////////////////////////////////////////////////////////////////////////////#
end

#==============================================================================
# ★ システムワード GamBit ★　※ここは変更しないでください。
#==============================================================================

module GamBit_System_Word
  #定義開始
  GamBit_Define = /\[(?:ガンビット|GamBit)\]/i
  #定義終了
  GamBit_Define_End = /\[\/(?:ガンビット|GamBit)\]/i
  #GamBit定義項目
  #条件
  Condition = /(?:条件|condition)\s*[=＝]\s*(.+)/
  #対象
  Targets = /(?:対象|targets)\s*[=＝]\s*((?:自分|self)|(?:味方|party)|(?:敵|troop))/i
  #背景色
  BackColor = /(?:背景色|backcolor)\s*[=＝]\s*(\d+)/i
  #Actor設定
  #初期スロット数
  Slot = /(?:ガンビットスロット|gambit\s*slot)\s*[=＝]\s*(\d+)/i
  #最大スロット数
  MaxSlot = /(?:ガンビット最大スロット|gambit\s*max\s*slot)\s*[=＝]\s*(\d+)/i
  #スロット追加
  Add_Slot = /\[(?:ガンビットスロット追加|gambit\s*add\s*slot)\s*(\d+)\]/i
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Vocab
#------------------------------------------------------------------------------
# 　用語とメッセージを定義するモジュールです。定数でメッセージなどを直接定義す
# るほか、グローバル変数 $data_system から用語データを取得します。
#==============================================================================

module Vocab
  #メニューに追加する項目名
  def self.gambit
    return GamBit::Menu_GamBit
  end
  #待機
  def self.nothing
    return $data_skills[GamBit::Nothing_Skill_ID].name
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Sound
#------------------------------------------------------------------------------
# 　効果音を演奏するモジュールです。グローバル変数 $data_system からデータベー
# スで設定された SE の内容を取得し、演奏します。
#==============================================================================

module Sound
  @@_gambit_switch = RPG::SE.new(GamBit::Switch_SE)
  #ガンビットのＯＮ／ＯＦＦ切替ＳＥ
  def self.play_gambit_switch
    @@_gambit_switch.play
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Sound
#------------------------------------------------------------------------------
# 　ＧａｍＢｉｔに関するモジュールです。
#==============================================================================

module GamBit
  #----------------------------------------------------------------------------
  # ○ 指定アクターのスロット追加
  #----------------------------------------------------------------------------
  def self.targets_unit(type)
    case type
    when :party
      return $game_party
    when :troop
      return $game_troop
    end
  end  
end
#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ☐ Command
#==============================================================================

module Commands
  module_function
  #----------------------------------------------------------------------------
  # ○ 指定アクターのスロット追加
  #----------------------------------------------------------------------------
  def gambit_add_slot(actor_id, n)
    target = $game_actors[actor_id]
    n.times{
      break unless target.gambit_slots.size < target.actor.gambit_maxslot
      target.gambit_slots << Game_GamBit.new
    }
  end
  #----------------------------------------------------------------------------
  # ○ パーティ全体のスロット追加
  #----------------------------------------------------------------------------
  def party_gambit_add_slot(n)
    for target in $game_party.members
      n.times{
        break unless target.gambit_slots.size < target.actor.gambit_maxslot
        target.gambit_slots << Game_GamBit.new
      }
    end
  end
end

class Game_Interpreter
  include Commands
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ RPG
#==============================================================================

module RPG
  
#==============================================================================
# ■ RPG::Actor
#==============================================================================

  class Actor < BaseItem
    #------------------------------------------------------------------------
    # ○ キャッシュを生成
    #------------------------------------------------------------------------
    def create_gambit_cache
      @gambit_slot = GamBit::GamBit_Slot
      @gambit_maxslot = GamBit::GamBit_MaxSlot
      define = false
      self.note.each_line{|line|
        case line
        when GamBit_System_Word::GamBit_Define
          define = true
        when GamBit_System_Word::GamBit_Define_End
          define = false
        when GamBit_System_Word::Slot
          next unless define
          @gambit_slot = $1.to_i
        when GamBit_System_Word::MaxSlot
          next unless define
          @gambit_maxslot = $1.to_i
        end
      }
    end
    #------------------------------------------------------------------------
    # ○ GamBitスロット数
    #------------------------------------------------------------------------
    def gambit_slot
      create_gambit_cache if @gambit_slot.nil?
      return @gambit_slot
    end
    #------------------------------------------------------------------------
    # ○ GamBit最大スロット数
    #------------------------------------------------------------------------
    def gambit_maxslot
      create_gambit_cache if @gambit_maxslot.nil?
      return @gambit_maxslot
    end
  end
  
#==============================================================================
# ■ RPG::Item
#==============================================================================

  class Item < UsableItem
    #------------------------------------------------------------------------
    # ○ GamBitのキャッシュを生成
    #------------------------------------------------------------------------
    def create_gambit_cache
      @add_slot = 0
      @gambit = Game_GamBit.new
      @is_gambit = false
      define = false
      self.note.each_line{|line|
        case line
        when GamBit_System_Word::GamBit_Define
          define = true
          @is_gambit = true
          @gambit.description = self.name
        when GamBit_System_Word::GamBit_Define_End
          next unless define
          define = false
        when GamBit_System_Word::Condition
          next unless define
          @gambit.condition = $1
        when GamBit_System_Word::Targets
          next unless define
          case $1.upcase
          when "自分","SELF"
            @gambit.scope = :self
          when "味方","PARTY"
            @gambit.scope = :party
          when "敵","TROOP"
            @gambit.scope = :troop
          end
        when GamBit_System_Word::BackColor
          next unless define
          @gambit.backcolor = $1.to_i
        when GamBit_System_Word::Add_Slot
          @add_slot = $1.to_i
        end
      }
    end
    #------------------------------------------------------------------------
    # ○ ガンビット
    #------------------------------------------------------------------------
    def gambit
      create_gambit_cache if @gambit.nil?
      return @gambit
    end
    #------------------------------------------------------------------------
    # ○ スロットの追加
    #------------------------------------------------------------------------
    def add_slot
      create_gambit_cache if @add_slot.nil?
      return @add_slot
    end
    #------------------------------------------------------------------------
    # ○ ガンビット判定
    #------------------------------------------------------------------------
    def is_gambit?
      create_gambit_cache if @is_gambit.nil?
      return @is_gambit
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_System
#------------------------------------------------------------------------------
# 　システム周りのデータを扱うクラスです。セーブやメニューの禁止状態などを保存
# します。このクラスのインスタンスは $game_system で参照されます。
#==============================================================================

class Game_System
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader :gambit_backcolors
  attr_reader :gambit_off_backcolor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias gambit_initialize initialize
  def initialize
    gambit_initialize
    @gambit_backcolors = []
    GamBit::GamBit_BackColors.each{|color| @gambit_backcolors << Tone.new(color[0], color[1], color[2], color[3]) }
    @gambit_off_backcolor = @gambit_backcolors[GamBit::GamBit_OFF_BackColor]
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Action
#------------------------------------------------------------------------------
# 　戦闘行動を扱うクラスです。このクラスは Game_Battler クラスの内部で使用され
# ます。
#==============================================================================

class Game_Action
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_writer :gambit
  #--------------------------------------------------------------------------
  # ● クリア
  #--------------------------------------------------------------------------
  alias gambit_clear clear
  def clear
    gambit_clear
    @gambit = nil
  end
  #--------------------------------------------------------------------------
  # ● 何もしないを設定
  #--------------------------------------------------------------------------
  def set_nothing
    set_skill(subject.nothing_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 逃げるを設定
  #--------------------------------------------------------------------------
  def set_escape
    set_skill(subject.escape_skill_id)
    self
  end
  #--------------------------------------------------------------------------
  # ● 行動：逃げる
  #--------------------------------------------------------------------------
  def escape?
    @gambit && @gambit.escape?
  end
  #--------------------------------------------------------------------------
  # ● ターゲットの配列作成
  #--------------------------------------------------------------------------
  alias gambit_make_targets make_targets
  def make_targets
    return gambit_make_targets unless subject.use_gambit
    if !forcing && subject.confusion?
      [confusion_target]
    elsif item.for_user?
      [subject]
    elsif item.for_one?
      targets_for_one
    elsif item.for_all?
      targets_for_all
    elsif item.for_random?
      targets_for_ramdom
    else
      []
    end
  end
  #--------------------------------------------------------------------------
  # ● ターゲット単体
  #--------------------------------------------------------------------------
  def targets_for_one
    if item.for_dead_friend?
      [@gambit.unit.smooth_dead_target(@target_index)]
    else
      num = 1 + (attack? ? subject.atk_times_add.to_i : 0)
      if @target_index < 0
        [targets_for_ramdom] * num
      else
        [@gambit.unit.smooth_target(@target_index)] * num
      end
    end
  end
  #--------------------------------------------------------------------------
  # ● ターゲット全体
  #--------------------------------------------------------------------------
  def targets_for_all
    if item.for_dead_friend?
      @gambit.unit.dead_members
    else
      @gambit.unit.alive_members
    end
  end
  #--------------------------------------------------------------------------
  # ● ターゲットランダム
  #--------------------------------------------------------------------------
  def targets_for_ramdom
    @gambit.unit.random_target
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_BattlerBase
#------------------------------------------------------------------------------
# 　バトラーを扱う基本のクラスです。主に能力値計算のメソッドを含んでいます。こ
# のクラスは Game_Battler クラスのスーパークラスとして使用されます。
#==============================================================================

class Game_BattlerBase
  #--------------------------------------------------------------------------
  # ● 何もしないのスキル ID を取得
  #--------------------------------------------------------------------------
  def nothing_skill_id
    return GamBit::Nothing_Skill_ID
  end
  #--------------------------------------------------------------------------
  # ● 逃げるのスキル ID を取得
  #--------------------------------------------------------------------------
  def escape_skill_id
    return GamBit::Escape_Skill_ID
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Battler
#------------------------------------------------------------------------------
# 　バトラーを扱うクラスです。このクラスは Game_Actor クラスと Game_Enemy クラ
# スのスーパークラスとして使用されます。
#==============================================================================

class Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :use_gambit
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  alias gambit_initialize initialize
  def initialize
    @use_gambit = false
    gambit_initialize
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの適用テスト
  #    使用対象が全快しているときの回復禁止などを判定する。
  #--------------------------------------------------------------------------
  alias gambit_item_test item_test
  def item_test(user, item)
    if item.is_a?(RPG::Item)
      return true if (item.add_slot > 0 && gambit_slot_add_test)
    end
    gambit_item_test(user, item)
  end
  #--------------------------------------------------------------------------
  # ● ガンビットスロットの追加判定
  #--------------------------------------------------------------------------
  def gambit_slot_add_test
    (gambit_slots.size < actor.gambit_maxslot)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_Actor
#------------------------------------------------------------------------------
# 　アクターを扱うクラスです。このクラスは Game_Actors クラス ($game_actors)
# の内部で使用され、Game_Party クラス ($game_party) からも参照されます。
#==============================================================================

class Game_Actor < Game_Battler
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :gambit_slots
  #--------------------------------------------------------------------------
  # ● セットアップ
  #     actor_id : アクター ID
  #--------------------------------------------------------------------------
  alias gambit_setup setup
  def setup(actor_id)
    gambit_setup(actor_id)
    @gambit_slots = []
    actor.gambit_slot.times{ @gambit_slots << Game_GamBit.new }
  end
  #--------------------------------------------------------------------------
  # ● コマンド入力可能判定
  #--------------------------------------------------------------------------
  def inputable?
    super && !use_gambit
  end
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの効果適用
  #--------------------------------------------------------------------------
  def item_apply(user, item)
    super(user, item)
    if item.is_a?(RPG::Item)
      Commands.gambit_add_slot(@actor_id, item.add_slot) if item.add_slot > 0
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #--------------------------------------------------------------------------
  alias gambit_make_actions make_actions
  def make_actions
    if gambit_auto_battle?
      super
      make_gambit_battle_actions
    else
      gambit_make_actions
    end
  end
  #--------------------------------------------------------------------------
  # ● 戦闘行動の作成
  #--------------------------------------------------------------------------
  def gambit_auto_battle?
    normal? && use_gambit
  end
  #--------------------------------------------------------------------------
  # ● ガンビットでの自動行動の作成
  #--------------------------------------------------------------------------
  def make_gambit_battle_actions
    _actions = gambit_actions_list
    @actions.size.times do |i|
      @actions[i] = _actions[[i, _actions.size - 1].min]
    end
  end
  #--------------------------------------------------------------------------
  # ● ガンビットに沿った行動リスト
  #--------------------------------------------------------------------------
  def gambit_actions_list
    actions = []
    for gambit in @gambit_slots
      next unless gambit.evaluation
      actions << gambit.action.clone
    end
    return actions.size > 0 ? actions : [Game_Action.new(self)]
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Game_GamBit
#==============================================================================

class Game_GamBit
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_accessor :condition
  attr_accessor :scope
  attr_accessor :description
  attr_accessor :valid
  attr_accessor :action
  attr_accessor :backcolor
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize
    @condition = ""
    @scope = :troop
    @description = ""
    @valid = false
    @action = nil
    @backcolor = GamBit::GamBit_OFF_BackColor
  end
  #--------------------------------------------------------------------------
  # ● 行動の取得
  #--------------------------------------------------------------------------
  def action_escape
    $data_skills[GamBit::Escape_Skill_ID]
  end
  #--------------------------------------------------------------------------
  # ● 行動の取得
  #--------------------------------------------------------------------------
  def action_item
    @action && @action.item
  end
  #--------------------------------------------------------------------------
  # ● 逃走判定
  #--------------------------------------------------------------------------
  def escape?
    action_item == action_escape
  end
  #--------------------------------------------------------------------------
  # ● Unitの取得
  #--------------------------------------------------------------------------
  def unit
    case @scope
    when :troop
      $game_troop
    when :self, :party
      $game_party
    end
  end
  #--------------------------------------------------------------------------
  # ● 行動者の取得
  #--------------------------------------------------------------------------
  def myself
    @action && @action.subject
  end
  #--------------------------------------------------------------------------
  # ● 行動の判定
  #--------------------------------------------------------------------------
  def evaluation
    return false if @condition.empty?
    return false if action_item.nil?
    return false unless @action.valid?
    return false if escape? && !BattleManager.can_escape?
    return false unless @valid
    result = eval("GamBit.#{@condition}")
    if result["condition"]
      target = result["target"]
      @action.target_index = unit.members.index(target)
      return false unless target.item_test(myself, action_item)
      @action.gambit = self
      return true
    else
      return false
    end
  end
  #--------------------------------------------------------------------------
  # ● 比較
  #--------------------------------------------------------------------------
  def ==(gambit)
    return false if self.condition == gambit.condition
    return false if self.scope == gambit.scope
    return false if self.valid == gambit.valid
    return false if self.action_item == gambit.action_item
    return false if self.backcolor == gambit.backcolor
    super
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Sprite_GamBit_Cursor
#==============================================================================

class Sprite_GamBit_Cursor < Sprite
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #     viewport : ビューポート
  #--------------------------------------------------------------------------
  def initialize
    bitmap = Cache.system(GamBit::GamBit_Cursor)
    viewport = Viewport.new(0, 0, bitmap.width, bitmap.height / GamBit::GamBit_Cursor_Animation)
    super(viewport)
    self.bitmap = bitmap
    @wait = 0
    @index = 0
    self.hide
  end
  #--------------------------------------------------------------------------
  # ● 解放
  #--------------------------------------------------------------------------
  def dispose
    self.viewport.dispose
    super
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの表示
  #--------------------------------------------------------------------------
  def show
    self.visible = true
    self
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの非表示
  #--------------------------------------------------------------------------
  def hide
    self.visible = false
    self
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @wait += 1
    return if @wait < GamBit::GamBit_Cursor_Speed
    @wait = 0
    @index = (@index + 1) % GamBit::GamBit_Cursor_Animation
    self.oy = @index * self.viewport.rect.height
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_Base
#------------------------------------------------------------------------------
# 　ゲーム中の全てのウィンドウのスーパークラスです。
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # ● 各種文字色の取得
  #--------------------------------------------------------------------------
  def gambit_switch_on_color; text_color(GamBit::Switch_ON);   end;
  def gambit_switch_off_color; text_color(GamBit::Switch_OFF);   end;
end
  
#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_MenuCommand
#------------------------------------------------------------------------------
# 　メニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # ● 独自コマンドの追加用
  #--------------------------------------------------------------------------
  alias gambit_add_original_commands add_original_commands
  def add_original_commands
    gambit_add_original_commands
    add_command(Vocab.gambit,   :gambit,   main_commands_enabled)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_ItemList
#------------------------------------------------------------------------------
# 　アイテム画面で、所持アイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_ItemList < Window_Selectable
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  alias gambit_include? include?
  def include?(item)
    if item.is_a?(RPG::Item)
      return false if item.is_gambit?
    end
    gambit_include?(item)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_Label
#------------------------------------------------------------------------------
# 　各画面で指定したテキストを表示するウィンドウです。
#   デフォルトでは中央揃え。0:左揃え　1:中央揃え　2:右揃え
#==============================================================================

class Window_Label < Window_Base
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, text = "", align = 1)
    super(x, y, width, height)
    refresh(text, align)
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウの矩形取得
  #--------------------------------------------------------------------------
  def rect
    return Rect.new(x, y, width, height)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh(text = "", align = 1)
    self.contents.clear
    draw_text(contents.rect, text, align)
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Actor
#------------------------------------------------------------------------------
# 　ガンビット設定画面でアクターを選択ウィンドウです。
#==============================================================================

class Window_GamBit_Actor < Window_Selectable
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, actor)
    super(x, y, width, height)
    @actor = actor
    refresh
    activate
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_switch if handle?(:switch) && Input.trigger?(:A)
    return process_left if handle?(:prev) && Input.trigger?(:LEFT)
    return process_right   if handle?(:next)   && Input.trigger?(:RIGHT)
    super
  end
  #--------------------------------------------------------------------------
  # ● Aキーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_switch
    Sound.play_gambit_switch
    Input.update
    deactivate
    call_handler(:switch)
  end
  #--------------------------------------------------------------------------
  # ● 左キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_left
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:prev)
  end
  #--------------------------------------------------------------------------
  # ● 右キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_right
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:next)
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    self.contents.clear
    draw_actor_face(@actor, 4, 0)
    y = 102
    draw_actor_name(@actor, 0, y)
    draw_actor_class(@actor, 0, y + line_height)
    draw_basic_info(x, y + line_height * 2)
    draw_gambit_info(x, y + line_height * 5)
  end
  #--------------------------------------------------------------------------
  # ● 基本情報の描画
  #--------------------------------------------------------------------------
  def draw_basic_info(x, y)
    draw_actor_level(@actor, x, y)
    draw_actor_hp(@actor, x, y + line_height * 1, 90)
    draw_actor_mp(@actor, x, y + line_height * 2, 90)
  end
  #--------------------------------------------------------------------------
  # ● ガンビット情報の描画
  #--------------------------------------------------------------------------
  def draw_gambit_info(x, y)
    draw_text(x, y, contents_width, line_height, "Gambit", 1)
    text = ""
    if @actor.use_gambit
      text = "ON"
      change_color(gambit_switch_on_color)
    else
      text = "OFF"
      change_color(gambit_switch_off_color)
    end      
    draw_text(x, y + line_height, contents_width, line_height, text, 1)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● Help Text 1
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("←→：Change Actor \n Shift: Turn on/off X: Back Z: Confirm")
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_SlotBase
#------------------------------------------------------------------------------
# ガンビット設定画面のスロットベースウィンドウです。
#==============================================================================

class Window_GamBit_SlotBase < Window_Selectable
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  SLOT_HEIGHT = 48
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, gambit, use_gambit)
    @gambit = gambit
    @use_gambit = use_gambit
    super(x, y, width, height)
    refresh
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● 色調の更新
  #--------------------------------------------------------------------------
  def update_tone
    if @gambit.valid && @use_gambit
      self.tone.set($game_system.gambit_backcolors[@gambit.backcolor])
    else
      self.tone.set($game_system.gambit_off_backcolor)
    end
  end
  #--------------------------------------------------------------------------
  # ● 決定やキャンセルなどのハンドリング処理
  #--------------------------------------------------------------------------
  def process_handling
    return unless open? && active
    return process_left if handle?(:left) && Input.repeat?(:LEFT)
    return process_right if handle?(:right) && Input.repeat?(:RIGHT)
    return process_up if handle?(:up) && Input.repeat?(:UP)
    return process_down if handle?(:down) && Input.repeat?(:DOWN)
    return process_sort_start if handle?(:sort) && Input.trigger?(:A)
    super
  end
  #--------------------------------------------------------------------------
  # ● 左キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_left
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:left)
  end
  #--------------------------------------------------------------------------
  # ● 右キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_right
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:right)
  end
  #--------------------------------------------------------------------------
  # ● 上キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_up
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:up)
  end
  #--------------------------------------------------------------------------
  # ● 下キーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_down
    Sound.play_cursor
    Input.update
    deactivate
    call_handler(:down)
  end
  #--------------------------------------------------------------------------
  # ● Aキーが押されたときの処理
  #--------------------------------------------------------------------------
  def process_sort_start
    Sound.play_ok
    Input.update
    deactivate
    call_handler(:sort)
  end
  #--------------------------------------------------------------------------
  # ● ガンビット設定
  #--------------------------------------------------------------------------
  def gambit=(gambit)
    return if @gambit == gambit
    @gambit = gambit
    refresh
  end
  #--------------------------------------------------------------------------
  # ● ガンビット許可設定
  #--------------------------------------------------------------------------
  def use_gambit=(use_gambit)
    return if @use_gambit == use_gambit
    @use_gambit = use_gambit
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Rank
#------------------------------------------------------------------------------
# ガンビット設定画面で行動順位を表示するウィンドウです。
#==============================================================================

class Window_GamBit_Rank < Window_Label
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height, gambit, use_gambit, text = "")
    @gambit = gambit
    @use_gambit = use_gambit
    super(x, y, width, height, text)
  end
  #--------------------------------------------------------------------------
  # ● 色調の更新
  #--------------------------------------------------------------------------
  def update_tone
    if @gambit.valid && @use_gambit
      self.tone.set($game_system.gambit_backcolors[@gambit.backcolor])
    else
      self.tone.set($game_system.gambit_off_backcolor)
    end
  end
  #--------------------------------------------------------------------------
  # ● ガンビット設定
  #--------------------------------------------------------------------------
  def gambit=(gambit)
    return if @gambit == gambit
    @gambit = gambit
  end
  #--------------------------------------------------------------------------
  # ● ガンビット許可設定
  #--------------------------------------------------------------------------
  def use_gambit=(use_gambit)
    return if @use_gambit == use_gambit
    @use_gambit = use_gambit
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Condition
#------------------------------------------------------------------------------
# ガンビット設定画面で行動条件を設定するウィンドウです。
#==============================================================================

class Window_GamBit_Condition < Window_GamBit_SlotBase
  #--------------------------------------------------------------------------
  # ● 公開インスタンス
  #--------------------------------------------------------------------------
  attr_accessor :process_sort
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(base_rect, index, gambit, use_gambit)
    super(base_rect.x, SLOT_HEIGHT * index, base_rect.width, base_rect.height, gambit, use_gambit)
    @process_sort = false
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    draw_text(self.contents.rect, @gambit.description, 1)
  end
  #--------------------------------------------------------------------------
  # ● Help Window (Shift/Hover on Gambit)
  #--------------------------------------------------------------------------
  def update_help
    if @process_sort
      @help_window.set_text("Changing Gambit Order...\n↑↓： Slot X: Cancel Z: Confirm")
    else
      @help_window.set_text("↑↓： Slot ←： Setting →： Action\n X: Cancel Z: Confirm Shift: Reorder")
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Action
#------------------------------------------------------------------------------
# ガンビット設定画面で行動を設定するウィンドウです。
#==============================================================================

class Window_GamBit_Action < Window_GamBit_SlotBase
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(base_rect, index, gambit, use_gambit)
    super(base_rect.x, SLOT_HEIGHT * index, base_rect.width, base_rect.height, gambit, use_gambit)
  end
  #--------------------------------------------------------------------------
  # ● リフレッシュ
  #--------------------------------------------------------------------------
  def refresh
    super
    text = @gambit.action.nil? ? "" : @gambit.action_item.name
    draw_text(self.contents.rect, text, 1)
  end
  #--------------------------------------------------------------------------
  # ● Help Window (Hover on Action)
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("↑↓： Slot ←：Gambit →： Setting\n X: Cancel Z: Confirm Shift: Reorder")
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Switch
#------------------------------------------------------------------------------
# ガンビット設定画面でガンビット有効設定するウィンドウです。
#==============================================================================

class Window_GamBit_Switch < Window_GamBit_SlotBase
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(base_rect, index, gambit, use_gambit)
    super(base_rect.x, SLOT_HEIGHT * index, base_rect.width, base_rect.height, gambit, use_gambit)
  end  
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    Sound.play_gambit_switch
    Input.update
    deactivate
    call_ok_handler
  end
  #--------------------------------------------------------------------------
  # ● Gambit ON/OFF text
  #--------------------------------------------------------------------------
  def refresh
    super
    text = ""
    if @gambit.valid
      text = "ON"
      change_color(gambit_switch_on_color)
    else
      text = "OFF"
      change_color(gambit_switch_off_color)
    end
    draw_text(contents.rect, text, 1)
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # ● Help Window (Hover on Setting)
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("↑↓： Slot ←：Action →：Gambit\n X: Cancel Z: Confirm Shift: Reorder")
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_Command
#------------------------------------------------------------------------------
# 　ガンビット設定画面の行動選択
#==============================================================================

class Window_GamBit_Command < Window_Command
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super
    self.openness = 0
    self.z = 500
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● コマンド選択位置の初期化（クラスメソッド）
  #--------------------------------------------------------------------------
  def self.init_command_position
    @@last_command_symbol = nil
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::attack, :attack)
    add_command(Vocab::guard, :guard)
    add_command(Vocab::escape, :escape)
    add_command(Vocab::nothing, :nothing)
    add_command(Vocab::skill, :skill)
    add_command(Vocab::item, :item)
    add_command("", :none)
  end
  #--------------------------------------------------------------------------
  # ● 決定ボタンが押されたときの処理
  #--------------------------------------------------------------------------
  def process_ok
    @@last_command_symbol = current_symbol
    super
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    select_symbol(@@last_command_symbol)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの更新 (内容は継承先で定義する)
  #--------------------------------------------------------------------------
  def update_help
    @help_window.set_text("↑↓：Select Action X: Cancel X: Confirm")
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_List
#------------------------------------------------------------------------------
# 　所持しているガンビットの一覧を表示するウィンドウです。
#==============================================================================

class Window_GamBit_List < Window_ItemList
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.openness = 0
    self.z = 500
    self.category = :item
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    return false unless item.is_a?(RPG::Item)
    item.is_gambit?
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
  #--------------------------------------------------------------------------
  # ● アイテムリストの作成
  #--------------------------------------------------------------------------
  def make_item_list
    @data = $game_party.all_items.select {|item| include?(item) }
    @data.push(nil)
  end
  #--------------------------------------------------------------------------
  # ● 項目の描画
  #--------------------------------------------------------------------------
  def draw_item(index)
    item = @data[index]
    if item
      rect = item_rect(index)
      rect.width -= 4
      draw_item_name(item, rect.x, rect.y)
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_GamBit_ItemList
#------------------------------------------------------------------------------
# 　ガンビット設定画面でアイテムの一覧を表示するウィンドウです。
#==============================================================================

class Window_GamBit_ItemList < Window_ItemList
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.z = 500
    self.category = :item
    self.openness = 0
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● アイテムをリストに含めるかどうか
  #--------------------------------------------------------------------------
  def include?(item)
    if item.is_a?(RPG::Item)
      return false if [2, 3].include?(item.occasion)
    end
    super
  end
  #--------------------------------------------------------------------------
  # ● アイテムを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_SkillCommand
#------------------------------------------------------------------------------
# 　スキル画面で、コマンド（特技や魔法など）を選択するウィンドウです。
#==============================================================================

class Window_GamBit_SkillCategory < Window_HorzCommand
  #--------------------------------------------------------------------------
  # ● 公開インスタンス変数
  #--------------------------------------------------------------------------
  attr_reader   :skill_window
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y)
    super(x, y)
    @actor = nil
    self.openness = 0
    self.z = 500
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● ウィンドウ幅の取得
  #--------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #--------------------------------------------------------------------------
  # ● 桁数の取得
  #--------------------------------------------------------------------------
  def col_max
    return 4
  end
  #--------------------------------------------------------------------------
  # ● アクターの設定
  #--------------------------------------------------------------------------
  def actor=(actor)
    return if @actor == actor
    @actor = actor
    refresh
    select_last
  end
  #--------------------------------------------------------------------------
  # ● コマンドリストの作成
  #--------------------------------------------------------------------------
  def make_command_list
    return unless @actor
    @actor.added_skill_types.sort.each do |stype_id|
      name = $data_system.skill_types[stype_id]
      add_command(name, :skill, true, stype_id)
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @skill_window.stype_id = current_ext if @skill_window
  end
  #--------------------------------------------------------------------------
  # ● スキルウィンドウの設定
  #--------------------------------------------------------------------------
  def skill_window=(skill_window)
    @skill_window = skill_window
    update
  end
  #--------------------------------------------------------------------------
  # ● 前回の選択位置を復帰
  #--------------------------------------------------------------------------
  def select_last
    skill = @actor.last_skill.object
    if skill
      select_ext(skill.stype_id)
    else
      select(0)
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Window_SkillList
#------------------------------------------------------------------------------
# 　スキル画面で、使用できるスキルの一覧を表示するウィンドウです。
#==============================================================================

class Window_GamBit_SkillList < Window_SkillList
  #--------------------------------------------------------------------------
  # ● オブジェクト初期化
  #--------------------------------------------------------------------------
  def initialize(x, y, width, height)
    super
    self.openness = 0
    self.z = 500
    deactivate
  end
  #--------------------------------------------------------------------------
  # ● スキルを許可状態で表示するかどうか
  #--------------------------------------------------------------------------
  def enable?(item)
    true
  end  
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

if $imported["Call_MenuCommand_In_Battle"]
  
#==============================================================================
# ■ Window_Battle_MenuCommand
#------------------------------------------------------------------------------
# 　戦闘時のメニュー画面で表示するコマンドウィンドウです。
#==============================================================================

class Window_Battle_MenuCommand < Window_MenuCommand
  #--------------------------------------------------------------------------
  # ● 主要コマンドをリストに追加
  #--------------------------------------------------------------------------
  alias gambit_add_original_commands add_original_commands
  def add_original_commands
    gambit_add_original_commands
    add_command(Vocab.gambit, :gambit, main_commands_enabled)
  end  
end

end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Menu
#------------------------------------------------------------------------------
# 　メニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias gambit_create_command_window create_command_window
  def create_command_window
    gambit_create_command_window
    @command_window.set_handler(:gambit, method(:command_personal))
  end
  #--------------------------------------------------------------------------
  # ● 個人コマンド［決定］
  #--------------------------------------------------------------------------
  alias gambit_on_personal_ok on_personal_ok
  def on_personal_ok
    gambit_on_personal_ok
    case @command_window.current_symbol
    when :gambit
      SceneManager.call(Scene_GamBit)
    end
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_Battle
#------------------------------------------------------------------------------
# 　バトル画面の処理を行うクラスです。
#==============================================================================

class Scene_Battle < Scene_Base  
  #--------------------------------------------------------------------------
  # ● スキル／アイテムの使用
  #--------------------------------------------------------------------------
  alias gambit_use_item use_item
  def use_item
    return BattleManager.process_escape if @subject.actor? && @subject.current_action.escape?      
    gambit_use_item
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

if $imported["Call_MenuCommand_In_Battle"]
  
#==============================================================================
# ■ Scene_BattleMenu
#------------------------------------------------------------------------------
# 　戦闘時のメニュー画面の処理を行うクラスです。
#==============================================================================

class Scene_BattleMenu < Scene_Menu
  #--------------------------------------------------------------------------
  # ● コマンドウィンドウの作成
  #--------------------------------------------------------------------------
  alias gambit_create_command_window create_command_window
  def create_command_window
    gambit_create_command_window
    @command_window.set_handler(:gambit, method(:command_personal))
  end
  #--------------------------------------------------------------------------
  # ● 個人コマンド［決定］
  #--------------------------------------------------------------------------
  alias gambit_on_personal_ok on_personal_ok
  def on_personal_ok
    gambit_on_personal_ok
    case @command_window.current_symbol
    when :gambit
      SceneManager.call(Scene_GamBit)
    end
  end
end

end
#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★

#==============================================================================
# ■ Scene_GamBit
#------------------------------------------------------------------------------
# 　ガンビット設定画面の処理を行うクラスです。
#==============================================================================

class Scene_GamBit < Scene_MenuBase
  #--------------------------------------------------------------------------
  # ● 定数
  #--------------------------------------------------------------------------
  WINDOW_WIDTH = 54
  WINDOW_HEIGHT = 48
  #--------------------------------------------------------------------------
  # ● 開始処理
  #--------------------------------------------------------------------------
  def start
    super
    @process_sort = false
    @prior_cursor_position = {}
    create_cursor_sprite
    create_help_window
    create_gambit_actor_window
    create_gambit_slot_label_window
    create_viewport
    create_gambit_slot_window
    create_gambit_list_window
    create_actioncommand_list_window
    create_gambit_item_list_window
    create_gambit_skill_list_window
  end
  #--------------------------------------------------------------------------
  # ● 終了処理
  #--------------------------------------------------------------------------
  def terminate
    super
    @gambit_slots_viewport.dispose
    dispose_gambit_slots
  end
  #--------------------------------------------------------------------------
  # ● ガンビットスロットウィンドウの破棄
  #--------------------------------------------------------------------------
  def dispose_gambit_slots
    for windows in @gambit_slots_windows
      windows.each_value {|window| window.dispose }
      windows.clear
    end
  end
  #--------------------------------------------------------------------------
  # ● フレーム更新
  #--------------------------------------------------------------------------
  def update
    super
    @cursor_sprite.update if @cursor_sprite.visible
    for windows in @gambit_slots_windows
      windows.each_value {|window| window.update }
      next if windows.empty?
      windows[:condition].process_sort = @process_sort
    end
  end
  #--------------------------------------------------------------------------
  # ● カーソルスプライトの作成
  #--------------------------------------------------------------------------
  def create_cursor_sprite
    @cursor_sprite = Sprite_GamBit_Cursor.new
    @cursor_sprite.hide
    @cursor_sprite.viewport.z = 400
    @cursor_position = { :index => 0, :window => :condition }
  end
  #--------------------------------------------------------------------------
  # ● ビューポートの作成
  #--------------------------------------------------------------------------
  def create_viewport
    height = Graphics.height - (@gambit_label_rank_window.y + @gambit_label_rank_window.height)
    vh = height - (height % WINDOW_HEIGHT)
    vy = @gambit_label_rank_window.y + @gambit_label_rank_window.height + ((height % WINDOW_HEIGHT) / 2)
    @gambit_slots_viewport = Viewport.new(0, vy, Graphics.width, vh)
    @gambit_slots_viewport.z = 300
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウの作成
  #--------------------------------------------------------------------------
  def create_help_window
    @help_window = Window_Help.new
    @help_window.set_text(help_window_text)
  end
  #--------------------------------------------------------------------------
  # ● ヘルプウィンドウのテキストを取得
  #--------------------------------------------------------------------------
  def help_window_text
    return ""
  end
  #--------------------------------------------------------------------------
  # ● アクター選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gambit_actor_window
    wy = @help_window.y + @help_window.height
    wh = Graphics.height - wy
    @gambit_actor_window = Window_GamBit_Actor.new(0, wy, 128, wh, @actor)
    @gambit_actor_window.help_window = @help_window
    @gambit_actor_window.set_handler(:cancel, method(:return_scene))
    @gambit_actor_window.set_handler(:ok, method(:on_actor_ok))
    @gambit_actor_window.set_handler(:switch, method(:on_actor_switch))
    @gambit_actor_window.set_handler(:next, method(:next_actor))
    @gambit_actor_window.set_handler(:prev, method(:prev_actor))
  end
  #--------------------------------------------------------------------------
  # ● Gambit Slot Labels
  #--------------------------------------------------------------------------
  def create_gambit_slot_label_window
    wx = @gambit_actor_window.x + @gambit_actor_window.width
    wy = @gambit_actor_window.y
    ww = WINDOW_WIDTH
    wh = WINDOW_HEIGHT
    @gambit_label_rank_window = Window_Label.new(wx, wy, ww, wh, "#")
    @gambit_label_switch_window = Window_Label.new(Graphics.width - ww, wy, ww, wh, "On?")
    @gambit_label_action_window = Window_Label.new(@gambit_label_switch_window.x - ww * 2, wy, ww * 2, wh,"Action")
    wx += @gambit_label_rank_window.width
    ww = @gambit_label_action_window.x - wx
    @gambit_label_condition = Window_Label.new(wx, wy, ww, wh, "Gambit")
  end
  #--------------------------------------------------------------------------
  # ● ガンビットスロットウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gambit_slot_window
    ww = WINDOW_WIDTH
    wh = WINDOW_HEIGHT
    @gambit_slots_windows = []
    wy = 0
    @gambit_slots_viewport.oy = 0
    @actor.gambit_slots.size.times do |n|
      gambit = @actor.gambit_slots[n]
      gambit_rank_label = Window_GamBit_Rank.new(@gambit_label_rank_window.x, wy, ww, wh, gambit, @actor.use_gambit, (n + 1).to_s)
      gambit_condition = Window_GamBit_Condition.new(@gambit_label_condition.rect, n, gambit, @actor.use_gambit)
      gambit_action = Window_GamBit_Action.new(@gambit_label_action_window.rect, n, gambit, @actor.use_gambit)
      gambit_switch = Window_GamBit_Switch.new(@gambit_label_switch_window.rect, n, gambit, @actor.use_gambit)
      gambit_rank_label.viewport = gambit_condition.viewport = gambit_action.viewport = gambit_switch.viewport = @gambit_slots_viewport
      windows = {
        :rank_label => gambit_rank_label,
        :condition => gambit_condition,
        :action => gambit_action,
        :switch => gambit_switch
      }
      set_event_handler(windows)
      @gambit_slots_windows.push(windows)
      wy += @gambit_label_rank_window.height
    end
  end
  #--------------------------------------------------------------------------
  # ● ガンビットリストウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gambit_list_window
    wy = @help_window.y + @help_window.height
    @gambit_list_window = Window_GamBit_List.new(0, wy, Graphics.width, Graphics.height - wy)
    @gambit_list_window.help_window = @help_window
    @gambit_list_window.set_handler(:ok, method(:on_gambit_list_ok))
    @gambit_list_window.set_handler(:cancel, method(:on_gambit_list_cancel))
  end
  #--------------------------------------------------------------------------
  # ● アクションコマンドリストウィンドウの作成
  #--------------------------------------------------------------------------
  def create_actioncommand_list_window
    wx = @gambit_label_action_window.x
    wy = @gambit_slots_viewport.rect.y
    @actioncommand_list_window = Window_GamBit_Command.new(wx, wy)
    @actioncommand_list_window.x -= @actioncommand_list_window.width
    @actioncommand_list_window.help_window = @help_window
    @actioncommand_list_window.set_handler(:attack, method(:command_basic_action))
    @actioncommand_list_window.set_handler(:guard, method(:command_basic_action))
    @actioncommand_list_window.set_handler(:escape, method(:command_basic_action))
    @actioncommand_list_window.set_handler(:nothing, method(:command_basic_action))
    @actioncommand_list_window.set_handler(:skill, method(:command_skill))
    @actioncommand_list_window.set_handler(:item, method(:command_item))
    @actioncommand_list_window.set_handler(:none, method(:command_basic_action))
    @actioncommand_list_window.set_handler(:cancel, method(:on_actioncommand_list_cancel))
  end
  #--------------------------------------------------------------------------
  # ● アイテム選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gambit_item_list_window
    wy = @help_window.y + @help_window.height
    @gambit_item_list_window = Window_GamBit_ItemList.new(0, wy, Graphics.width, Graphics.height - wy)
    @gambit_item_list_window.set_handler(:ok, method(:on_item_list_ok))
    @gambit_item_list_window.set_handler(:cancel, method(:on_item_list_cancel))
    @gambit_item_list_window.help_window = @help_window
  end
  #--------------------------------------------------------------------------
  # ● スキル選択ウィンドウの作成
  #--------------------------------------------------------------------------
  def create_gambit_skill_list_window
    wy = @help_window.y + @help_window.height
    @gambit_skill_category_window = Window_GamBit_SkillCategory.new(0, wy)
    @gambit_skill_list_window = Window_GamBit_SkillList.new(0, wy + @gambit_skill_category_window.height, Graphics.width, Graphics.height - (wy + @gambit_skill_category_window.height))
    @gambit_skill_list_window.help_window = @help_window
    @gambit_skill_category_window.skill_window = @gambit_skill_list_window
    @gambit_skill_category_window.set_handler(:skill, method(:on_skill_category_ok))
    @gambit_skill_category_window.set_handler(:cancel, method(:on_skill_category_cancel))
    @gambit_skill_list_window.set_handler(:ok, method(:on_skill_list_ok))
    @gambit_skill_list_window.set_handler(:cancel, method(:on_skill_list_cancel))
  end
  #--------------------------------------------------------------------------
  # ● イベントハンドラの設定
  #--------------------------------------------------------------------------
  def set_event_handler(windows)
    windows.each_pair{|symble, window|
      case symble
      when :rank_label
        next
      when :condition
        window.set_handler(:ok, method(:on_condition_ok))
      when :action
        window.set_handler(:ok, method(:on_action_ok))
      when :switch
        window.set_handler(:ok, method(:on_switch_ok))
      end
      window.set_handler(:cancel, method(:return_select_actor))
      window.set_handler(:left, method(:left_key))
      window.set_handler(:right, method(:right_key))
      window.set_handler(:up, method(:up_key))
      window.set_handler(:down, method(:down_key))
      window.set_handler(:sort, method(:process_sort_start))
      window.help_window = @help_window
    }
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の取得
  #--------------------------------------------------------------------------
  def top_slot
    @gambit_slots_viewport.oy / WINDOW_HEIGHT
  end
  #--------------------------------------------------------------------------
  # ● 先頭の行の設定
  #--------------------------------------------------------------------------
  def top_slot=(index)
    index = 0 if index < 0
    index = @gambit_slots_windows.size - page_slots if index > @gambit_slots_windows.size - page_slots
    @gambit_slots_viewport.oy = index * WINDOW_HEIGHT
  end
  #--------------------------------------------------------------------------
  # ●末尾の行の取得
  #--------------------------------------------------------------------------
  def bottom_slot
    top_slot + page_slots - 1
  end
  #--------------------------------------------------------------------------
  # ● 末尾の行の設定
  #--------------------------------------------------------------------------
  def bottom_slot=(index)
    self.top_slot = index - (page_slots - 1)
  end
  #--------------------------------------------------------------------------
  # ● 表示可能スロットの最大数
  #--------------------------------------------------------------------------
  def page_slots
    @gambit_slots_viewport.rect.height / WINDOW_HEIGHT
  end
  #--------------------------------------------------------------------------
  # ● アクターの切り替え
  #--------------------------------------------------------------------------
  def on_actor_change
    @gambit_actor_window.actor = @actor
    dispose_gambit_slots
    create_gambit_slot_window
    @gambit_actor_window.activate
  end
  #--------------------------------------------------------------------------
  # ● カーソルの移動
  #--------------------------------------------------------------------------
  def move_cursor
    window =  @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]]
    cx = @gambit_slots_viewport.rect.x + window.x + [@cursor_sprite.viewport.rect.width / 2, window.width / 12].min
    cy = @gambit_slots_viewport.rect.y - @cursor_sprite.viewport.rect.height / 4 + (@cursor_position[:index] - top_slot) * WINDOW_HEIGHT
    @cursor_sprite.viewport.rect.x = cx; @cursor_sprite.viewport.rect.y = cy
  end
  #--------------------------------------------------------------------------
  # ● カーソル位置が画面内になるようにスクロール
  #--------------------------------------------------------------------------
  def ensure_cursor_visible
    self.top_slot = @cursor_position[:index] if @cursor_position[:index] < top_slot
    self.bottom_slot = @cursor_position[:index] if @cursor_position[:index] > bottom_slot
  end
  #--------------------------------------------------------------------------
  # ● アクター［決定］
  #--------------------------------------------------------------------------
  def on_actor_ok
    if @actor.gambit_slots.size > 0
      @gambit_actor_window.deactivate
      @cursor_position[:index] = [@cursor_position[:index], @actor.gambit_slots.size - 1].min
      @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
      @cursor_sprite.show
      ensure_cursor_visible
      move_cursor
    else
      Sound.play_buzzer
    end
  end
  #--------------------------------------------------------------------------
  # ● アクター［Ａキー］
  #--------------------------------------------------------------------------
  def on_actor_switch
    @actor.use_gambit = (not @actor.use_gambit)
    @gambit_actor_window.refresh
    for gambit_slot in @gambit_slots_windows
      gambit_slot.each_value{|window| window.use_gambit = @actor.use_gambit }
    end
    @gambit_actor_window.activate
  end
  #--------------------------------------------------------------------------
  # ● 条件/行動/スイッチ［キャンセル］
  #--------------------------------------------------------------------------
  def return_select_actor
    if @process_sort
      process_sort_cancel
    else
      @gambit_actor_window.activate
      @cursor_sprite.hide
    end
  end
  #--------------------------------------------------------------------------
  # ● 条件［決定］
  #--------------------------------------------------------------------------
  def on_condition_ok
    if @process_sort
      execute_sort
    else
      @gambit_list_window.open.activate
      @gambit_list_window.select_last
    end
  end
  #--------------------------------------------------------------------------
  # ● 行動［決定］
  #--------------------------------------------------------------------------
  def on_action_ok
    y = @gambit_slots_windows[@cursor_position[:index]][:rank_label].y - @gambit_slots_viewport.oy + @gambit_slots_viewport.rect.y
    y = [y, Graphics.height - @actioncommand_list_window.height].min
    @actioncommand_list_window.y = y
    @actioncommand_list_window.open.activate
  end
  #--------------------------------------------------------------------------
  # ● スイッチ［決定］
  #--------------------------------------------------------------------------
  def on_switch_ok
    gambit = @actor.gambit_slots[@cursor_position[:index]]
    gambit.valid = (not gambit.valid)
    @gambit_slots_windows[@cursor_position[:index]].each_value{|window| window.gambit = gambit }
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
  end
  #--------------------------------------------------------------------------
  # ● 条件/行動/スイッチ［左キー］
  #--------------------------------------------------------------------------
  def left_key
    unless @process_sort
      window = @cursor_position[:window]
      case window
      when :condition
        @cursor_position[:window] = :switch
      when :action
        @cursor_position[:window] = :condition
      when :switch
        @cursor_position[:window] = :action
      end
    end
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    move_cursor
  end
  #--------------------------------------------------------------------------
  # ● 条件/行動/スイッチ［右キー］
  #--------------------------------------------------------------------------
  def right_key
    unless @process_sort
      window = @cursor_position[:window]
      case window
      when :condition
        @cursor_position[:window] = :action
      when :action
        @cursor_position[:window] = :switch
      when :switch
        @cursor_position[:window] = :condition
      end
    end
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    move_cursor
  end
  #--------------------------------------------------------------------------
  # ● 条件/行動/スイッチ［上キー］
  #--------------------------------------------------------------------------
  def up_key
    @cursor_position[:index] = (@cursor_position[:index] - 1 + @gambit_slots_windows.size) % @gambit_slots_windows.size
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    ensure_cursor_visible
    move_cursor
  end
  #--------------------------------------------------------------------------
  # ● 条件/行動/スイッチ［下キー］
  #--------------------------------------------------------------------------
  def down_key
    @cursor_position[:index] = (@cursor_position[:index] + 1) % @gambit_slots_windows.size
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    ensure_cursor_visible
    move_cursor
  end 
  #--------------------------------------------------------------------------
  # ● ガンビットリスト［決定］
  #--------------------------------------------------------------------------
  def on_gambit_list_ok
    gambit = Game_GamBit.new
    _gambit =  @actor.gambit_slots[@cursor_position[:index]]
    item = @gambit_list_window.item
    gambit = item.gambit.clone if item.is_a?(RPG::Item)
    gambit.action = _gambit.action
    gambit.valid = _gambit.valid
    @gambit_list_window.close
    $game_party.last_item.object = item
    @actor.gambit_slots[@cursor_position[:index]] = gambit
    @gambit_slots_windows[@cursor_position[:index]].each_value{|window| window.gambit = gambit }
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
  end
  #--------------------------------------------------------------------------
  # ● ガンビットリスト［キャンセル］
  #--------------------------------------------------------------------------
  def on_gambit_list_cancel
    @gambit_list_window.close
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
  end
  #--------------------------------------------------------------------------
  # ● アクションコマンドリスト［キャンセル］
  #--------------------------------------------------------------------------
  def on_actioncommand_list_cancel
    @actioncommand_list_window.close
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate    
  end
  #--------------------------------------------------------------------------
  # ● アクションコマンドリスト［戦う/防御/逃げる/待機］
  #--------------------------------------------------------------------------
  def command_basic_action
    action = Game_Action.new(@actor)
    gambit = @actor.gambit_slots[@cursor_position[:index]]
    case @actioncommand_list_window.current_symbol
    when :attack; action.set_attack;
    when :guard; action.set_guard;
    when :escape; action.set_escape;
    when :nothing; action.set_nothing;
    when :none; action = nil;
    end
    gambit.action = action
    @actioncommand_list_window.close
    @gambit_slots_windows[@cursor_position[:index]].each_value{|window| window.gambit = gambit }
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate    
  end
  #--------------------------------------------------------------------------
  # ● アクションコマンドリスト［スキル］
  #--------------------------------------------------------------------------
  def command_skill
    @gambit_skill_category_window.actor = @actor
    @gambit_skill_list_window.actor = @actor
    @gambit_skill_list_window.open
    @gambit_skill_category_window.open.activate
    @gambit_skill_category_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● アクションコマンドリスト［アイテム］
  #--------------------------------------------------------------------------
  def command_item
    @gambit_item_list_window.open.activate
    @gambit_item_list_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● アイテムリスト［決定］
  #--------------------------------------------------------------------------
  def on_item_list_ok
    action = Game_Action.new(@actor)
    gambit = @actor.gambit_slots[@cursor_position[:index]]
    item = @gambit_item_list_window.item
    if item.nil?
      action = nil
    else
      action.set_item(item.id)
    end
    gambit.action = action
    @gambit_item_list_window.close
    @actioncommand_list_window.close
    @gambit_slots_windows[@cursor_position[:index]].each_value{|window| window.gambit = gambit }
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate    
  end
  #--------------------------------------------------------------------------
  # ● アイテムリスト［キャンセル］
  #--------------------------------------------------------------------------
  def on_item_list_cancel
    @gambit_item_list_window.close
    @actioncommand_list_window.activate
  end
  #--------------------------------------------------------------------------
  # ● スキルカテゴリー［決定］
  #--------------------------------------------------------------------------
  def on_skill_category_ok
    @gambit_skill_list_window.activate
    @gambit_skill_list_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● スキルカテゴリー［キャンセル］
  #--------------------------------------------------------------------------
  def on_skill_category_cancel
    @gambit_skill_category_window.close
    @gambit_skill_list_window.close
    @actioncommand_list_window.activate
    @actioncommand_list_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● スキルカテゴリー［決定］
  #--------------------------------------------------------------------------
  def on_skill_list_ok
    action = Game_Action.new(@actor)
    gambit = @actor.gambit_slots[@cursor_position[:index]]
    skill = @gambit_skill_list_window.item
    if skill.nil?
      action = nil
    else
      action.set_skill(skill.id)
    end
    gambit.action = action
    @gambit_skill_category_window.close
    @gambit_skill_list_window.close
    @actioncommand_list_window.close
    @gambit_slots_windows[@cursor_position[:index]].each_value{|window| window.gambit = gambit }
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
  end
  #--------------------------------------------------------------------------
  # ● スキルカテゴリー［キャンセル］
  #--------------------------------------------------------------------------
  def on_skill_list_cancel
    @gambit_skill_category_window.activate
    @gambit_skill_category_window.select_last
  end
  #--------------------------------------------------------------------------
  # ● 並び替え［開始］
  #--------------------------------------------------------------------------
  def process_sort_start
    unless @process_sort
      @process_sort = true
      @prior_cursor_position = @cursor_position.clone
      @gambit_slots_viewport.ox -= WINDOW_WIDTH / 2
      @gambit_slots_windows[@cursor_position[:index]].each_value do |window|
        window.x -= WINDOW_WIDTH / 2
      end
      @cursor_position[:window] = :condition
    end
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    move_cursor
  end
  #--------------------------------------------------------------------------
  # ● 並び替え［実行］
  #--------------------------------------------------------------------------
  def execute_sort
    index1 = @cursor_position[:index]
    index2 = @prior_cursor_position[:index]
    @actor.gambit_slots[index1], @actor.gambit_slots[index2] = @actor.gambit_slots[index2], @actor.gambit_slots[index1]
    dispose_gambit_slots
    create_gambit_slot_window
    process_sort_end
  end
  #--------------------------------------------------------------------------
  # ● 並び替え［キャンセル］
  #--------------------------------------------------------------------------
  def process_sort_cancel
    @gambit_slots_windows[@prior_cursor_position[:index]].each_value do |window|
      window.x += WINDOW_WIDTH / 2
    end
    process_sort_end
  end
  #--------------------------------------------------------------------------
  # ● 並び替え［終了］
  #--------------------------------------------------------------------------
  def process_sort_end
    @process_sort = false
    @cursor_position = @prior_cursor_position.clone
    @prior_cursor_position = {}
    @gambit_slots_viewport.ox = 0
    @gambit_slots_windows[@cursor_position[:index]][@cursor_position[:window]].activate
    move_cursor
  end
end

#★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★☆★