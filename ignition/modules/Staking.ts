import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import Addresses from "../deployments/chain-1337/deployed_addresses.json";

const StakingModule = buildModule("StakingModule", (m) => {
	const mtAddress = Addresses["KataTokenModule#KataToken"];
	const rtAddress = Addresses["RewardTokenModule#RewardToken"];

	const Staking = m.contract("Staking", [
		"kataStaking",
		mtAddress,
		rtAddress,
		5,
	]);

	return { Staking };
});

export default StakingModule;
