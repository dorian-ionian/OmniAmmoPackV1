class OmniAmmoPickup extends Pickup;

// Share of each weapon's MaxAmmo that one pickup gives, per fire mode.
var() float AmmoFraction;

// Tops up every weapon the pawn carries. Returns true if any ammo was added.
function bool GiveOmniAmmo(Pawn P)
{
	local Inventory Inv;
	local Weapon W;
	local int Mode, Amount;
	local bool bGave;

	for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		W = Weapon(Inv);
		if (W == None)
			continue;

		for (Mode = 0; Mode < 2; Mode++)
		{
			if (W.GetAmmoClass(Mode) == None)
				continue;
			// Both modes share one ammo pool, so don't add it twice.
			if (Mode == 1 && W.GetAmmoClass(1) == W.GetAmmoClass(0))
				continue;
			if (W.AmmoMaxed(Mode))
				continue;

			Amount = Max(1, int(float(W.MaxAmmo(Mode)) * AmmoFraction));
			if (W.AddAmmo(Amount, Mode))
				bGave = true;
		}
	}
	return bGave;
}

auto state Pickup
{
	function Touch(Actor Other)
	{
		if (!ValidTouch(Other))
			return;

		if (GiveOmniAmmo(Pawn(Other)))
		{
			AnnouncePickup(Pawn(Other));
			SetRespawn();
		}
	}
}

defaultproperties
{
     AmmoFraction=0.500000
     MaxDesireability=0.700000
     RespawnTime=30.000000
     PickupMessage="You picked up an ammo cache."
     MessageClass=Class'UnrealGame.PickupMessagePlus'
     PickupSound=Sound'PickupSounds.MinigunAmmoPickup'
     PickupForce="MinigunAmmoPickup"
     StaticMesh=StaticMesh'X_MiscPhysicsMeshes.Crate'
     DrawType=DT_StaticMesh
     bCollideWorld=True
     bUseCylinderCollision=True
     CollisionRadius=88.000000
     CollisionHeight=17.000000
     Physics=PHYS_Falling
}
