extends TabContainer
class_name ShopMenu

var items_to_buttons: Dictionary[String, Button]
@onready var basic_weapon_items_container: HFlowContainer = $Weapon/VBoxContainer/BasicWeaponItemsContainer
@onready var advanced_weapon_items_container: HFlowContainer = $Weapon/VBoxContainer/AdvancedWeaponItemsContainer
@onready var master_weapon_items_container: HFlowContainer = $Weapon/VBoxContainer/MasterWeaponItemsContainer

@onready var basic_vitality_items_container: HFlowContainer = $Vitality/VBoxContainer/BasicVitalityItemsContainer
@onready var advanced_vitality_items_container: HFlowContainer = $Vitality/VBoxContainer/AdvancedVitalityItemsContainer
@onready var master_vitality_items_container: HFlowContainer = $Vitality/VBoxContainer/MasterVitalityItemsContainer

@onready var basic_magic_items_container: HFlowContainer = $Magic/VBoxContainer/BasicMagicItemsContainer
@onready var advanced_magic_items_container: HFlowContainer = $Magic/VBoxContainer/AdvancedMagicItemsContainer
@onready var master_magic_items_container: HFlowContainer = $Magic/VBoxContainer/MasterMagicItemsContainer

func _ready() -> void:
	
