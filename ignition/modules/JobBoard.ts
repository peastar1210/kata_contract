import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const JobBoardModule = buildModule("JobBoard", (m) => {
	const jobBoard = m.contract("JobBoard");

	return { jobBoard };
});

export default JobBoardModule;
