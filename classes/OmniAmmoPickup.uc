class OmniAmmoPickup extends Pickup;

// Share of each weapon's MaxAmmo that one pickup gives, per fire mode.
var() float AmmoFraction;

// Tops up every ammo type the pawn carries. Returns true if any ammo was added.
// Ammo is read from the pawn's Ammunition inventory, so weapons with several
// ammo types (e.g. ChaosUT cgl) are covered without referencing their package.
// Weapons that keep ammo in AmmoCharge (bNoAmmoInstances) have no Ammunition item,
// so they are topped up through their fire modes.
function bool GiveOmniAmmo(Pawn P)
{
	local Inventory Inv;
	local Ammunition A;
	local Weapon W;
	local int Mode, Amount, Before;
	local bool bGave;

	for (Inv = P.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		A = Ammunition(Inv);
		if (A != None)
		{
			if (A.AmmoAmount >= A.MaxAmmo)
				continue;

			Amount = Max(1, int(float(A.MaxAmmo) * AmmoFraction));
			Before = A.AmmoAmount;
			A.AddAmmo(Amount);
			if (A.AmmoAmount > Before)
				bGave = true;
			continue;
		}

		W = Weapon(Inv);
		if (W == None || !W.bNoAmmoInstances)
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
