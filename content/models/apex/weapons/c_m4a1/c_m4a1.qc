$modelname "apex/weapons/c_m4a1.mdl"

$bodygroup "gun"
{
	studio "gun.smd"
	blank
}

$bodygroup "sight"
{
	studio "sight.smd"
	blank
}

$bodygroup "gadget"
{
	studio "gadget.smd"
	blank
}

$bodygroup "hand_left"
{
	studio "hand_left.smd"
	blank
}

$bodygroup "hand_right"
{
	studio "hand_right.smd"
	blank
}

$bodygroup "laser"
{
	studio "laser.smd"
	blank
}

$bodygroup "laser_gadget"
{
	studio "laser_gadget.smd"
	blank
}

$bodygroup "magazine"
{
	studio "magazine.smd"
	blank
}

$bodygroup "stock"
{
	studio "stock.smd"
	blank
}

$surfaceprop "default"

$contents "solid"

$illumposition 0 20 -0.2

$cdmaterials "models\Weapons\V_Hand\"
$cdmaterials "models\Weapons\v-w_M4A1\"

$attachment "muzzle" "G3" 0.15 -16.5 0.7 rotate -2 -90 90
$attachment "1" "G3" -0.2 4.6 0.75 rotate -5 -170 90

$cbox 0 0 0 0 0 0

$bbox -6.665 -128.308 -108.582 6012.442 108.844 108.833

$hboxset "default"

$definebone "G3" "" 0 1.614135 -0.604254 0 0 0 0 0 0 0 0 0
$definebone "Bolt" "G3" -0.482858 3.191451 0.444396 0 0 0 0 0 0 0 0 0
$definebone "Magazine" "" 0.013271 5.064266 -5.030553 0 0 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Clavicle" "" -11.353105 31.817913 -6.656322 -89.999982 0 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_UpperArm" "ValveBiped.Bip01_R_Clavicle" 0.000196 0.000145 -0.000387 27.880356 -123.229412 157.634387 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Forearm" "ValveBiped.Bip01_R_UpperArm" 11.692555 0 0.000002 -0.000002 -67.649984 -0.000001 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Hand" "ValveBiped.Bip01_R_Forearm" 11.4817 0.000002 0.000001 54.384702 53.939968 -79.276565 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger4" "ValveBiped.Bip01_R_Hand" 3.859671 -0.132571 1.193108 -9.982245 -82.146275 13.944075 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger41" "ValveBiped.Bip01_R_Finger4" 1.312563 0.000002 0 -0.000002 -53.21564 0.000001 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger42" "ValveBiped.Bip01_R_Finger41" 0.729364 0.000001 0 -0.000002 -19.659041 0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger3" "ValveBiped.Bip01_R_Hand" 3.942294 0.050327 0.431043 -6.748929 -64.725953 3.873424 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger31" "ValveBiped.Bip01_R_Finger3" 1.539095 0.000001 0 -0.000001 -62.935467 0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger32" "ValveBiped.Bip01_R_Finger31" 1.196321 0.000003 0 0.000001 -47.148864 0.000003 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger2" "ValveBiped.Bip01_R_Hand" 3.883655 -0.050329 -0.431043 -8.552599 -53.649934 0.886996 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger21" "ValveBiped.Bip01_R_Finger2" 1.719576 0.000002 0.000001 -0.456877 -76.871873 0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger22" "ValveBiped.Bip01_R_Finger21" 1.209182 -0.000001 0 -0.255595 -53.335714 0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger1" "ValveBiped.Bip01_R_Hand" 3.859828 -0.148938 -1.331281 5.602034 -31.292713 -2.001972 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger11" "ValveBiped.Bip01_R_Finger1" 1.719426 -0.000001 -0.000001 -0.378899 -48.296961 0.000003 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger12" "ValveBiped.Bip01_R_Finger11" 1.099665 0.000001 0 -0.241271 -50.287302 0.000004 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger0" "ValveBiped.Bip01_R_Hand" 0.806014 -0.359834 -1.318334 27.063658 -49.19009 62.02893 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger01" "ValveBiped.Bip01_R_Finger0" 1.789783 -0.000001 0.000001 -1.815817 19.265249 2.292742 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_R_Finger02" "ValveBiped.Bip01_R_Finger01" 1.207 0 -0.000002 0.000004 49.595284 -0.000005 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Clavicle" "" 17.169052 14.646191 -10.754388 23.434603 -179.999964 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_UpperArm" "ValveBiped.Bip01_L_Clavicle" -0.000194 -0.000145 0.000387 29.611547 -153.788293 166.203419 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Forearm" "ValveBiped.Bip01_L_UpperArm" -11.692555 -0.000003 -0.000002 0.000001 -42.839537 0 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Hand" "ValveBiped.Bip01_L_Forearm" -11.481699 0 -0.000002 18.851402 27.423537 -83.598094 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger4" "ValveBiped.Bip01_L_Hand" -3.859672 0.132571 -1.193108 7.230098 -94.158912 9.401726 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger41" "ValveBiped.Bip01_L_Finger4" -1.312563 -0.000001 0 0.000003 -22.144307 0.000007 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger42" "ValveBiped.Bip01_L_Finger41" -0.729364 -0.000001 0.000001 0.000004 -1.858273 0.000008 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger3" "ValveBiped.Bip01_L_Hand" -3.942294 -0.050327 -0.431043 7.732523 -72.730805 3.992893 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger31" "ValveBiped.Bip01_L_Finger3" -1.539095 0 0 0.000005 -36.816608 0.000008 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger32" "ValveBiped.Bip01_L_Finger31" -1.196321 -0.000002 0 0.000007 -26.670212 0.000005 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger2" "ValveBiped.Bip01_L_Hand" -3.883655 0.050328 0.431043 1.559072 -60.26084 5.8322 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger21" "ValveBiped.Bip01_L_Finger2" -1.719577 -0.000002 0 -0.456875 -50.491166 0.000006 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger22" "ValveBiped.Bip01_L_Finger21" -1.209182 0.000001 0 -0.255592 -26.349408 0.000003 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger1" "ValveBiped.Bip01_L_Hand" -3.859829 0.148937 1.331282 -1.468037 -46.468659 1.523614 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger11" "ValveBiped.Bip01_L_Finger1" -1.719426 0.000001 0.000001 -0.378897 -48.314436 0.000005 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger12" "ValveBiped.Bip01_L_Finger11" -1.099665 -0.000001 0 -0.241267 -39.456794 0.000002 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger0" "ValveBiped.Bip01_L_Hand" -0.806016 0.359834 1.318334 40.601168 -34.89629 69.000914 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger01" "ValveBiped.Bip01_L_Finger0" -1.789784 0.000001 -0.000001 -0.000005 6.543691 0.000003 0 0 0 0 0 0
$definebone "ValveBiped.Bip01_L_Finger02" "ValveBiped.Bip01_L_Finger01" -1.207001 -0.000001 0.000002 -0.000004 -9.237515 0.000004 0 0 0 0 0 0


$sequence "idle01" {
	"c_m4a1_anims\idle01.smd"
	activity "ACT_VM_IDLE" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
	loop
}

$sequence "fire01" {
	"c_m4a1_anims\fire01.smd"
	activity "ACT_VM_PRIMARYATTACK" 1
	{ event AE_MUZZLEFLASH 0 "SMG1 MUZZLE" }
	{ event 6001 0 "1" }
	fadein 0.2
	fadeout 0.2
	node "Fire"
	snap
	fps 30
}

$sequence "fire02" {
	"c_m4a1_anims\fire02.smd"
	activity "ACT_VM_RECOIL1" 1
	{ event AE_MUZZLEFLASH 0 "SMG1 MUZZLE" }
	{ event 6001 0 "1" }
	fadein 0.2
	fadeout 0.2
	node "Fire"
	snap
	fps 30
}

$sequence "fire03" {
	"c_m4a1_anims\fire03.smd"
	activity "ACT_VM_RECOIL2" 1
	{ event AE_MUZZLEFLASH 0 "SMG1 MUZZLE" }
	{ event 6001 0 "1" }
	fadein 0.2
	fadeout 0.2
	node "Fire"
	snap
	fps 32.5
}

$sequence "fire04" {
	"c_m4a1_anims\fire04.smd"
	activity "ACT_VM_RECOIL3" 1
	{ event AE_MUZZLEFLASH 0 "SMG1 MUZZLE" }
	{ event 6001 0 "1" }
	fadein 0.2
	fadeout 0.2
	node "Fire"
	snap
	fps 35
}

$sequence "altfire" {
	"c_m4a1_anims\altfire.smd"
	activity "ACT_VM_SECONDARYATTACK" 1
	{ event AE_MUZZLEFLASH 0 "SHOTGUN MUZZLE" }
	fadein 0.2
	fadeout 0.2
	node "Fire"
	snap
	fps 29
}

$sequence "draw" {
	"c_m4a1_anims\draw.smd"
	activity "ACT_VM_DRAW" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 30
}

$sequence "reload" {
	"c_m4a1_anims\reload.smd"
	activity "ACT_VM_RELOAD" 1
	fadein 0.2
	fadeout 0.2
	node "Ready"
	fps 37.83
}

$sequence "dryfire" {
	"c_m4a1_anims\dryfire.smd"
	activity "ACT_VM_DRYFIRE" 1
	fadein 0.2
	fadeout 0.2
	node "Fire"
	fps 21.43
}

$sequence "idletolow" {
	"c_m4a1_anims\idletolow.smd"
	activity "ACT_VM_LOWERED_TO_IDLE" 1
	fadein 0.2
	fadeout 0.2
	transition "Ready" "Low"
	fps 46.37
}

$sequence "lowtoidle" {
	"c_m4a1_anims\lowtoidle.smd"
	activity "ACT_VM_IDLE_TO_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	transition "Low" "Ready"
	fps 46.37
}

$sequence "lowidle" {
	"c_m4a1_anims\lowidle.smd"
	activity "ACT_VM_IDLE_LOWERED" 1
	fadein 0.2
	fadeout 0.2
	node "Low"
	fps 30
	loop
}
