import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const RewardTokenModule = buildModule("RewardTokenModule", (m) => {
	const rewardToken = m.contract("RewardToken");

	return { rewardToken };
});

export default RewardTokenModule;
