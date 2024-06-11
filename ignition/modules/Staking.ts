import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const StakingModule = buildModule("StakingModule", (m) => {
	const Staking = m.contract("Staking");

	return { Staking };
});

export default StakingModule;
