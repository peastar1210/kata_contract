import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

const KataTokenModule = buildModule("KataTokenModule", (m) => {
	const kataToken = m.contract("KataToken");

	return { kataToken };
});

export default KataTokenModule;
