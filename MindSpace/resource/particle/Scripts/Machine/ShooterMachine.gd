extends Node2D

var bulletScene
var muzzlePos
var animatedSprite
var isShooting
export (Vector2) var bulletSpeed


#子弹和机关的大小都直接调这个预制件的根节点的Scale,在编辑器调子弹射出的方向和速度（同一个变量），
#并且要调整枪口位置（Muzzle：枪口，就是子弹生成的位置），在计时器调发射间隔，注意不要太短，
#子弹的扫描层不要扫到自己的碰撞层，不然会和别的子弹相撞（除非就希望这么做）


# Called when the node enters the scene tree for the first time.
func _ready():
	bulletScene = preload("res://resource/particle/Scene/Bullet.tscn")
	animatedSprite = get_node("AnimatedSprite")
	pass
	
func _process(_delta):
	if isShooting:
		if animatedSprite.get_frame() == 7:
			animatedSprite.play('Idle')

func Shoot():
	var bullet = bulletScene.instance()
	self.add_child(bullet)
	bullet.position = muzzlePos	
	bullet.velocity = bulletSpeed	
	bullet.scale = Vector2(1 if bulletSpeed.x > 0 else -1,1)

func _on_Timer_timeout():
	Shoot()
	PlayShootAnim()

func PlayShootAnim():
	animatedSprite.play('Shoot')
	isShooting = true
