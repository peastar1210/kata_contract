import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";
import Addresses from "../deployments/chain-1337/deployed_addresses.json";

const JobBoardModule = buildModule("JobBoardModule", (m) => {
	const mtAddress = Addresses["KataTokenModule#KataToken"];
	const rtAddress = Addresses["RewardTokenModule#RewardToken"];

	const jobBoard = m.contract("JobBoard", [mtAddress, rtAddress]);

	return { jobBoard };
});

export default JobBoardModule;
