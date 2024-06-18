import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JobBoardModule = buildModule("JobBoardModule", (m) => {
	const jobBoard = m.contract("JobBoard");

	return { jobBoard };
});

export default JobBoardModule;
